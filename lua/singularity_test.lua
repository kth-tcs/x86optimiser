local nn = require 'nn'
local network = require 'lua/network'
require 'lua/mcmc_loss'
local torch = require 'torch'
local path = require 'pl.path'
local ffi = require 'lua/ffi'
local dataset = require 'lua/dataset'
torch.setdefaulttensortype('torch.FloatTensor')

local stoke_lib = 'bin/stoke-slave.so'
ffi.load_stoke(stoke_lib)
local nb_inst_dim = ffi.C.nb_possible_instruction()

local nb_run_for_val_estimates = 1000

local nb_run_for_grad_estimates = 50

local evaluate_singularity = function(path_to_sample_folder)
  -- Get the scores for the original learned policy
  local path_to_og_network = "exp/bias_with_testcase_shuffle_1/Weights/Iter_13.dump"
  local og_network = torch.load(path_to_og_network)

  local sample = {
    def_in_file = path.join(path_to_sample_folder, "def_in"),
    live_out_file = path.join(path_to_sample_folder, "live_out"),
    test_file = path.join(path_to_sample_folder, "test.tc"),
    target_file = path.join(path_to_sample_folder, "sample.s")
  }

  local c_object, bag_of_words = dataset.load_sample(sample, nb_inst_dim)

  local feat = bag_of_words:view(1,-1):float()

  local mcmc_criterion = nn.MCMCCriterion(200)

  local og_probas = og_network:forward(feat)

  local og_score = 0
  for _=1, nb_run_for_val_estimates do
    og_score = og_score + mcmc_criterion:forward(c_object, og_probas)
    mcmc_criterion:keep_proposal_distribution()
  end
  og_score = og_score / nb_run_for_val_estimates
  print("Expected value: " .. og_score)
  ffi.C.clear(c_object)
  return og_score
end

local train_singularity = function(path_to_sample_folder)
  local og_score
  local new_net = network.bias_network(nb_inst_dim, {9, nb_inst_dim}, "all_valid_splitted.ini")

  local param, gradParam = new_net:getParameters()
  param:fill(0)

  local log_file = io.open(path.join(path_to_sample_folder, "log.txt"), "w")

  local sample = {
    def_in_file = path.join(path_to_sample_folder, "def_in"),
    live_out_file = path.join(path_to_sample_folder, "live_out"),
    test_file = path.join(path_to_sample_folder, "test.tc"),
    target_file = path.join(path_to_sample_folder, "sample.s")
  }

  local c_object, bag_of_words = dataset.load_sample(sample, nb_inst_dim)

  local feat = bag_of_words:view(1,-1):float()

  local mcmc_criterion = nn.MCMCCriterion(200)

  for i=1, 100 do
    new_net:zeroGradParameters()
    local new_probas = new_net:forward(feat)

    new_probas = {
      new_probas[1][1],
      new_probas[2][1]
    }
    og_score = 0

    local grad_output_acc = {
      torch.Tensor(1, 9):fill(0),
      torch.Tensor(1, nb_inst_dim):fill(0)
    }
    mcmc_criterion:need_update_proposal_distribution()
    for _=1, nb_run_for_grad_estimates do
      og_score = og_score + mcmc_criterion:forward(c_object, new_probas)
      mcmc_criterion:keep_proposal_distribution()
      local grad_output = mcmc_criterion:backward(c_object, new_probas)
      grad_output_acc[1]:add(grad_output[1])
      grad_output_acc[2]:add(grad_output[2])
    end
    og_score = og_score / nb_run_for_grad_estimates

    log_file:write("Score at epoch: " .. i .. ": " .. og_score .. "\n")
    new_net:backward(feat, grad_output_acc)

    param = param - 0.01 * gradParam
    local debugger = require('fb.debugger')
    debugger.enter()
  end

  local new_probas = new_net:forward(feat)
  og_score = 0
  for _=1, nb_run_for_val_estimates do
    og_score = og_score + mcmc_criterion:forward(c_object, new_probas)
    mcmc_criterion:keep_proposal_distribution()
  end
  og_score = og_score / nb_run_for_val_estimates

  log_file:close()
  torch.save(path.join(path_to_sample_folder, "spec.t7"), new_net)

  return og_score
end

local path_to_sample_dir = arg[1]
print("Evaluating singularity for " .. arg[1])
local path_to_og_score = path.join(path_to_sample_dir, "og_score")
if not path.exists(path_to_og_score) then
  local og_score = evaluate_singularity(path_to_sample_dir)
  local og_score_file = io.open(path_to_og_score, "w")
  og_score_file:write(tostring(og_score) .. "\n")
  og_score_file:close()
end

local path_to_new_score = path.join(path_to_sample_dir, "new_score")
if not path.exists(path_to_new_score) then
  local new_score = train_singularity(path_to_sample_dir)
  local new_score_file = io.open(path_to_new_score, "w")
  new_score_file:write(tostring(new_score) .. "\n")
  new_score_file:close()
end
