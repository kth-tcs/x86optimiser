local loss_evaluation = function()
  local torch = require 'torch'
  local parallel = require "parallel"
  local dataset = require 'lua/dataset'
  local ffi = require 'lua/ffi'

  local nn = require 'nn'
  require 'lua/mcmc_loss'

  local files_to_use = parallel.parent:receive()
  ffi.load_stoke(files_to_use.stoke_lib)
  local conf = dofile(files_to_use.conf)

  local nb_inst_dim = ffi.C.nb_possible_instruction()

  local mcmc_criterion = nn.MCMCCriterion(conf.nb_mcmc_steps)

  local all_train_samples = dataset.collect_predicate(parallel.id, conf.path_to_train_dataset, conf.predicate_train)
  local all_test_samples = dataset.collect_predicate(parallel.id, conf.path_to_test_dataset, conf.predicate_test)

  --parallel.print("Child " .. parallel.id .. " correctly setup.")
  parallel.yield()

  -- Sending the size of the datasets for the parent process to decide how many
  -- batch to do
  parallel.parent:send({train=#all_train_samples,
                        test=#all_test_samples})

  local to_sample_from
  while true do
    local dataset_which = parallel.parent:receive()
    if dataset_which=="train" or dataset_which=="train_eval" then
      to_sample_from = all_train_samples
    elseif dataset_which == "test" then
      to_sample_from = all_test_samples
    elseif dataset_which == "break" then
      break
    end
    -- parallel.print("Starting a " .. dataset_which .. " pass, need to go through " .. #to_sample_from .. "samples")
    local grad_output

    local perm = torch.randperm(#to_sample_from)
    local sample_idx = 1

    while true do
      if parallel.parent:receive() == "break" then
        break
      end
      -- We will start from sample_idx (included) and do at most nb_samples_per_child_per_minibatch
      -- Without going over the end of the dataset
      local batchend_idx = math.min(sample_idx + conf.nb_samples_per_child_per_minibatch-1, #to_sample_from)
      -- Compute the number of elements in the batch
      local batch_nb_elt = math.max(batchend_idx + 1 - sample_idx, 0)
      -- parallel.print(batch_nb_elt)
      local grad_output_acc = {
        torch.Tensor(batch_nb_elt, conf.nb_operation_type):fill(0),
        torch.Tensor(batch_nb_elt, nb_inst_dim):fill(0)
      }
      local feats = torch.IntTensor(batch_nb_elt, nb_inst_dim)
      local batch_c_objects = {}
      for idx=sample_idx, batchend_idx do
        local unperm_sample_idx = perm[idx]
        local sample = to_sample_from[unperm_sample_idx]
        local c_object, bag_of_words = dataset.load_sample(sample, nb_inst_dim)
        batch_c_objects[idx+1-sample_idx] = c_object
        feats[idx+1-sample_idx] = bag_of_words
      end

      -- parallel.print("Sending feature")
      parallel.parent:send(feats)
      if feats:dim() ~= 0 then
        local probas = parallel.parent:receive()
        local sum_reward = 0
        for idx=sample_idx, batchend_idx do
          local comm_idx = idx+1-sample_idx
          local c_object = batch_c_objects[comm_idx]
          local proba = {probas[1][comm_idx],
                         probas[2][comm_idx]}
          mcmc_criterion:need_update_proposal_distribution()
          for _=1, conf.nb_run_grad_est do
            sum_reward = sum_reward + mcmc_criterion:forward(c_object, proba)
            mcmc_criterion:keep_proposal_distribution()
            if dataset_which=="train" then
              grad_output = mcmc_criterion:backward(c_object, proba)
              grad_output_acc[1][comm_idx]:add(grad_output[1])
              grad_output_acc[2][comm_idx]:add(grad_output[2])
            end
          end
          ffi.C.clear(c_object)
        end
        parallel.parent:send({grad=grad_output_acc,
                              rew=sum_reward})
        sample_idx = sample_idx + conf.nb_samples_per_child_per_minibatch
      end
      if sample_idx < #to_sample_from then
        parallel.parent:send("keep")
      else
        parallel.parent:send("break")
      end
      collectgarbage()
      collectgarbage()
    end

    -- parallel.print("Child " .. parallel.id .. "thinks that he is done with the epoch")
  end
end

return loss_evaluation
