local torch = require 'torch'
local debugger = require('fb.debugger')
local dataset = require 'lua/dataset'
local nn = require 'nn'
local conf = require 'lua/conf'
local network = require 'lua/network'
local dbg = require 'lua/debug'
local lapp = require 'pl.lapp'
local ffi = require 'lua/ffi'
local vis = require 'lua/vis'

conf.experiment_name = "debugging"

require 'lua/mcmc_loss'
torch.setdefaulttensortype('torch.FloatTensor')

local opt = lapp [[
Debugging failed run of learning MCMC
Main options
  <path-to-dump> (string)  path to the iteration you want to start again from
  ]]


-- Setup the ffi
ffi.load_stoke(conf.path_to_lib)
local nb_inst_dim = ffi.C.nb_possible_instruction()

local samples = dataset.collect_max_sp(conf.path_to_dataset, 1)
local sample = samples[1] -- We have a single sample here
print("Dataset loaded")

-- Setup the loss
local mcmc_criterion = nn.MCMCCriterion(conf.nb_mcmc_steps)


-- Setup the network
local net
if opt.path_to_dump=="bias_network" or opt.path_to_dump=="mlp_network" then
  local network_generating_function = network[conf.network_to_use]
  net = network_generating_function(nb_inst_dim, {conf.nb_operation_type, nb_inst_dim}, conf.path_to_clustering_file)
  local param, gradParam = net:getParameters()
  if conf.network_to_use == "bias_network" then
    param:fill(0)
  else
    local stdv = 0.2
    param:uniform(-stdv, stdv)
  end
else
    net = torch.load(opt.path_to_dump)
end

-- local net = network.bias_network(nb_inst_dim, {conf.nb_operation_type, nb_inst_dim}, conf.path_to_clustering_file)
-- local param, gradParam = net:getParameters()
-- param:fill(0)

local visualiser = vis.VisualisationHandler(conf, nb_inst_dim)

local nb_gradient_step = 10

for gd_step=1, nb_gradient_step do
  -- Setup of the iteration
  net:zeroGradParameters()
  local c_object, feat = dataset.load_sample(sample, nb_inst_dim)


  local net_input = feat:float():view(1,-1)
  local proba = net:forward(net_input)
  --debugger.enter()
  local move_proba = proba[1]

  local move_picked_hist = torch.Tensor(move_proba:size(2)):fill(0)
  --print("Move Proba:\n", move_proba:view(1,-1))
  local reward_sum = 0
  local grad_output_acc = {
    torch.Tensor(proba[1]:size(1), proba[1]:size(2)):fill(0),
    torch.Tensor(proba[2]:size(1), proba[2]:size(2)):fill(0)
  }

  for sample_idx=1, proba[1]:size(1) do
    visualiser:start_iteration()
    for _=1,conf.nb_run_grad_est do
      local sample_proba = {proba[1][sample_idx],
                            proba[2][sample_idx]}
      local final_reward = mcmc_criterion:forward(c_object, sample_proba)
      visualiser:collect_score_trace(mcmc_criterion.mcmc_history,
                                     mcmc_criterion.mcmc_history_size)
      --debugger.enter()
      reward_sum = reward_sum + final_reward
      -- for i=0,4 do
      --   local picked = mcmc_criterion.mcmc_history[i].move_picked+1
      --   move_picked_hist[picked] = move_picked_hist[picked]+1
      -- end
      --local grad_output = mcmc_criterion:backward(c_object, sample_proba)
      --grad_output_acc[1][sample_idx]:add(grad_output[1])
      --grad_output_acc[2][sample_idx]:add(grad_output[2])

      -- dbg.debug_if_hasnan(grad_output[1])
      -- dbg.debug_if_hasnan(grad_output[2])
      -- dbg.debug_if_hasnan(grad_output_acc[1])
      -- dbg.debug_if_hasnan(grad_output_acc[2])
    end
    visualiser:flush_iter(net, reward_sum)
  end
  --move_picked_hist = move_picked_hist:div(move_picked_hist:sum())
  --net:backward(net_input, grad_output_acc)

  -- print("Param: " , param:view(1,-1))
  -- print("GradParam: ", gradParam:view(1,-1))
  -- debugger.enter()
  local average_reward = reward_sum / conf.nb_run_grad_est
  print("Average Reward: ", average_reward)
  -- param:add(-0.001*gradParam)

  print("\n\n\n")
end
print("Lua taking back control")
