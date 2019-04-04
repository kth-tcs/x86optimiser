-- Imports
local ffi = require 'lua/ffi'
local torch = require 'torch'
local dbg = require 'lua/debug'

local MCMCCriterion, parent = torch.class('nn.MCMCCriterion', 'nn.Criterion')

function MCMCCriterion:__init(nb_iter)
  parent.__init(self)
  self.nb_iter = nb_iter
  self.gradInput = {torch.Tensor(), torch.Tensor()}
  self.update_proposal_distribution = 1
end

function MCMCCriterion:keep_proposal_distribution()
  self.update_proposal_distribution = 0
end

function MCMCCriterion:need_update_proposal_distribution()
  self.update_proposal_distribution = 1
end

function MCMCCriterion:updateOutput(c_object, proba)
  local c_final_reward = ffi.new("float[1]")
  local c_MCMC_history = ffi.new("iter_data*[1]")
  local c_MCMC_history_size = ffi.new("int[1]")

  ffi.sigint_handler_fix()
  ffi.C.run(c_object,
            proba[1]:data(), proba[1]:nElement(),
            proba[2]:data(), proba[2]:nElement(),
            self.nb_iter, self.update_proposal_distribution,
            c_final_reward,
            c_MCMC_history, c_MCMC_history_size)
  ffi.sigint_handler_restore()

  local final_reward = c_final_reward[0]
  self.mcmc_history_size = c_MCMC_history_size[0]
  self.mcmc_history = c_MCMC_history[0]
  self.initial_score = self.mcmc_history[0].score_before
  self.final_reward = final_reward
  self.update_proposal_distribution = 1
  return (final_reward / self.initial_score)
end

function MCMCCriterion:updateGradInput(c_object, proba)
  assert(self.mcmc_history_size and self.mcmc_history and self.final_reward)
  for i=1,2 do
    self.gradInput[i]:resize(proba[i]:size()):zero()
  end

  -- Build up the loss for each iteration: (we use the term loss to be clear
  -- that we are going to minimise it, this is equivalent to reward.)

  -- The loss that we are interested in minimizing is the one contained in self.final_reward
  -- We are going to distribute the credit.

  -- At each iteration, the loss is the difference between the best seen score
  -- and the score achieved, clamped at zero. (Note that this loss is negative)

  -- l_t = min(0, cost(R_t, T) - min_{i=1..t-1}[cost(R_i, T)])

  -- The only non-zero ones are going to be the improvements. If we take a
  -- summation, this is going to be a telescopic sum resulting in

  -- \sum_t l_t = min_{t} cost(R_t, T) - cost(R_0, T)

  -- which we want to be as low as possible (in order for the best cost to be as low as possible).

  -- Based on REINFORCE, we need to use all the future rewards that comes from this choice.
  -- r_t = \sum_{i>=t} l_i = min_{t} cost(R_t, T) - min_{t<i} cost(R_i,T)
  local epsilon = 1e-12
  local initial_value = self.mcmc_history[0].score_before
  local best_so_far = initial_value

  -- If we discount the factors, we need to precompute the lossses.
  -- This is negative, and this corresponds to what we want to minimize.
  local all_loss = {}
  local discount_factor = 1
  for path_index =0, self.mcmc_history_size-1 do
    local iter = self.mcmc_history[path_index]
    if (not iter.accepted) or iter.is_invalid then
      -- The score wouldn't have changed
      all_loss[path_index] = 0
    else
      all_loss[path_index] = math.pow(discount_factor, path_index) * math.min(0, (iter.score_after - best_so_far)/self.initial_score)
      best_so_far = math.min(iter.score_after, best_so_far)
    end
  end
  for path_index = self.mcmc_history_size-2, 0, -1 do
    all_loss[path_index] = all_loss[path_index] + all_loss[path_index+1]
  end

  local safe_move_proba = torch.add(proba[1], epsilon)
  local safe_instr_proba = torch.add(proba[2], epsilon)

  local nb_accepted = 0
  for path_index = 0, self.mcmc_history_size-1 do
    local iter = self.mcmc_history[path_index]
    if true or iter.accepted then -- graph rewriting
      nb_accepted = nb_accepted + 1
      -- If there was no discount factor, we could just use the following
      -- sequence to avoid doing a forward backward pass

      -- local incremental_loss = best_loss - best_so_far
      -- local after_score = (iter.accepted and iter.score_after) or iter.score_before
      -- best_so_far = math.min(after_score, best_so_far)

      local baselined_loss = all_loss[path_index]

      local norm_proba = 1
      if iter.nb_instr_normalising > 0 then
        for norm_inst = 0, iter.nb_instr_normalising-1  do
          norm_proba = norm_proba + safe_instr_proba[iter.instr_normalising[norm_inst]+1]
        end
      end

      local mv_update = (baselined_loss / safe_move_proba[iter.move_picked+1])
      dbg.debug_if_nan(mv_update)
      self.gradInput[1][iter.move_picked+1] = self.gradInput[1][iter.move_picked+1] + mv_update
      -- Note: The move_proposal terms cancel each-other out. This is equivalent
      -- to directly doing the REINFORCE on each of the independant sampling
      -- steps.

      if iter.instr_picked < proba[2]:size(1) then
        -- If there was an instruction that was picked.
        if iter.nb_instr_normalising == 0 then
          -- Sampled directly from the probability distribution
          local instr_update = (baselined_loss / safe_instr_proba[iter.instr_picked+1])
          dbg.debug_if_nan(instr_update)
          self.gradInput[2][iter.instr_picked+1] = self.gradInput[2][iter.instr_picked+1] + instr_update
        else
          local coherent_proba = false
          for norm_inst_idx=0, iter.nb_instr_normalising-1 do
            local norm_inst = iter.instr_normalising[norm_inst_idx]
            if norm_inst == iter.instr_picked then
              coherent_proba = true
              local picked_update = (norm_proba - safe_instr_proba[iter.instr_picked])*baselined_loss/
                (safe_instr_proba[iter.instr_picked]*norm_proba)
              dbg.debug_if_nan(picked_update)
              self.gradInput[2][norm_inst] = self.gradInput[2][norm_inst] + picked_update
            else
              local unpicked_update = - baselined_loss / norm_proba
              dbg.debug_if_nan(unpicked_update)
              self.gradInput[2][norm_inst] = self.gradInput[2][norm_inst] + unpicked_update
            end
          end
          if not coherent_proba then
            dbg.run_debugger()
          end
        end
      end

    end
  end
  dbg.debug_if_hasnan(self.gradInput[1])
  dbg.debug_if_hasnan(self.gradInput[2])
  for i=1, 2 do
    self.gradInput[i]:div(self.mcmc_history_size)
  end
  return self.gradInput
end
