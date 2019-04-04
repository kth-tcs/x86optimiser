local torch = require 'torch'
local ffi = require 'lua/ffi'
local conf = require 'lua/conf'
local dataset = require 'lua/dataset'
local network = require 'lua/network'
local vis = require 'lua/vis'
local dbg = require 'lua/debug'
require 'lua/mcmc_loss' -- For nn.MCMCCriterion
torch.setdefaulttensortype('torch.FloatTensor')

ffi.load_stoke(conf.path_to_lib)

-- print("Loading dataset...")
-- local samples = dataset.collect_max_sp(conf.path_to_dataset, 1)
-- local sample = samples[1] -- We have a single sample here
-- print("Dataset loaded")
local nb_inst_dim = ffi.C.nb_possible_instruction()
local nb_operation_type = 9

local path_to_clustering_file = "all_valid_splitted.ini"
local network_generating_function = network[conf.network_to_use]
local net = network_generating_function(nb_inst_dim, {conf.nb_operation_type, nb_inst_dim}, conf.path_to_clustering_file)
local mcmc_criterion = nn.MCMCCriterion(200)

local visualiser = vis.VisualisationHandler(conf, nb_inst_dim)

local param, gradParam = net:getParameters()
param:fill(0)


local debugger = require('fb.debugger')
debugger.enter()


local nb_gradient_step = 10000
local nb_samples_per_gradient = 500

for gd_step=1, nb_gradient_step do
  -- Setup of the iteration
  net:zeroGradParameters()
  visualiser:start_iteration()

  local net_input = sample.bag_of_words:float():view(1,-1)
  local proba = net:forward(net_input)
  -- print("Move Proba:\n", proba[1]:view(1,-1))
  -- print("Instr Proba start:\n", proba[2]:narrow(1,1,10):view(1,-1))
  -- print("Clusters proba:\n" nn.SoftMax:forward(bias_network:get(2):get(1).output):view(1,-1))
  local reward_sum = 0
  local grad_output
  local grad_output_acc = {
    torch.Tensor(proba[1]:size()):fill(0),
    torch.Tensor(proba[2]:size()):fill(0)
  }
  for sp=1,nb_samples_per_gradient do
    local unbatched_proba = {proba[1][1],
                             proba[2][1]}
    local final_reward = mcmc_criterion:forward(sample,unbatched_proba)
    reward_sum = reward_sum + final_reward
    if sp % (nb_samples_per_gradient/10) == 0 then
      visualiser:collect_score_trace(mcmc_criterion.mcmc_history,
                                     mcmc_criterion.mcmc_history_size)
    end
    grad_output = mcmc_criterion:backward(sample, unbatched_proba)
    grad_output_acc[1][1]:add(grad_output[1])
    grad_output_acc[2][1]:add(grad_output[2])

    dbg.debug_if_hasnan(grad_output[1])
    dbg.debug_if_hasnan(grad_output[2])
    dbg.debug_if_hasnan(grad_output_acc[1][1])
    dbg.debug_if_hasnan(grad_output_acc[2][1])
  end
  net:backward(net_input, grad_output_acc)
  local average_reward = reward_sum / nb_samples_per_gradient
  visualiser:flush_iter(net, average_reward)
  -- print("Param: " , param:view(1,-1))
  -- print("GradParam: ", gradParam:view(1,-1))
  print("Average Reward: ", average_reward)
  param:add(-0.001*gradParam)
  --param:add(-0.1*gradParam:div(torch.norm(gradParam)))

  print("\n\n\n")
end
print("Lua taking back control")
