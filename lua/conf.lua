local path = require 'pl.path'
local dataset = require 'lua/dataset'

local conf =  {}
local torch = require 'torch'
torch.setdefaulttensortype('torch.FloatTensor')

-- Constants that shouldn't change
conf.nb_operation_type = 9

-- Training parameters
conf.nb_child_process = 6
conf.minibatch_size = 32
conf.nb_run_grad_est = 100
conf.nb_epochs = 100
conf.nb_samples_per_child_per_minibatch = conf.minibatch_size / conf.nb_child_process
conf.learningRate = 0.001 / (conf.minibatch_size * conf.nb_run_grad_est)

-- conf.network_to_use = "linear_model"
-- conf.network_to_use = "mlp_network"
-- conf.network_to_use = "bias_network"
-- conf.network_to_use = "restricted_linear"
conf.network_to_use = "big_mlp_network"

conf.experiment_name = "big_mlp_network_on_hd"

-- Problem parameters
conf.nb_mcmc_steps = 200

conf.path_to_clustering_file = "all_valid_splitted.ini"

-- conf.start_from_it = 3
-- conf.path_to_start_net = "exp/mlp_adam_synthetic_dataset_largergrad_1/Weights/Iter_2.dump"
-- conf.path_to_existing_exp = "exp/mlp_adam_synthetic_dataset_largergrad_1/"

conf.path_to_conf = "lua/conf.lua"
conf.path_to_lib = "bin/stoke-slave.so"

local mod = conf.nb_child_process

local combine_predicate = function (pred1, pred2)
  local comb_pred  = function(split_id, task_id, sample_id)
    local should_1 = pred1(split_id, task_id, sample_id)
    local should_2 = pred2(split_id, task_id, sample_id)
    return should_1 and should_2
  end
  return comb_pred
end

local synthetic_dataset_functions = function()
  local sample_modulus = function(split_id, task_id, sample_id)
    return ((task_id % mod) == (split_id % mod))
  end

  local train_predicate = function(split_id, task_id, sample_id)
    return (task_id < 301)
  end

  local test_predicate = function(split_id, task_id, sample_id)
    return (task_id < 301) -- There is only 300 tests anyway
  end

  return sample_modulus, train_predicate, test_predicate
end

local hd_dataset_functions = function()
  local sample_modulus = function(split_id, task_id, sample_id)
    return ((sample_id % mod) == (split_id % mod))
  end

  local is_train = function(split_id, task_id, sample_id)
    return (task_id % 2 == 0 ) and (sample_id < 200)
  end

  local is_test = function (split_id, task_id, sample_id)
    return (task_id % 2 == 1 ) and (sample_id < 100)
  end

  return sample_modulus, is_train, is_test
end

-- Synthetic Dataset
-- conf.path_to_dataset = "/data/program_samples/folded_dataset/"
-- conf.path_to_train_dataset = conf.path_to_dataset .. "train_0/"
-- conf.path_to_test_dataset = conf.path_to_dataset .. "test/"
-- local sample_modulus, train_predicate, test_predicate = synthetic_dataset_functions()

-- Hacker's Delight dataset
conf.path_to_dataset = "/data/program_samples/new-tested-synth/"
conf.path_to_train_dataset = conf.path_to_dataset
conf.path_to_test_dataset = conf.path_to_dataset
local sample_modulus, train_predicate, test_predicate = hd_dataset_functions()


conf.predicate_train = dataset.make_dataset_filter(combine_predicate(sample_modulus, train_predicate))
conf.predicate_test = dataset.make_dataset_filter(combine_predicate(sample_modulus, test_predicate))

return conf
