-- To export
local dataset = {}
-- Imports
local ffi = require 'lua/ffi'
local dir = require 'pl.dir'
local path = require 'pl.path'
local torch = require 'torch'

dataset.make_dataset_filter = function(split_function)
  -- Make_dataset_filter simplifies the writing of the predicate

  -- If you give it a function taking as argument,
  --         split_id  -> The id of this process/ this separation unit
  --         task_id   -> The id of the task of the sample
  --         sample_id -> The id of the sample

  -- And returning a boolean on whether to take or not, this returns a proper
  -- predicate function that can work with dataset.collect_predicate
  local dataset_filter = function(split_id, task, sample, all_samples)
    -- I assume the sample will be of the form '/bla/bla/01.s'
    local sample_id = tonumber(string.match(sample, "(%d+)%.s$"))
    local task_id = tonumber(string.match(task, "(%d+)$"))

    -- Should go to this thread
    local should_do = split_function(split_id, task_id, sample_id)

    return should_do
  end
  return dataset_filter
end


dataset.collect_predicate = function(split_id, path_to_dataset_folder, predicate)
  -- Predicate is a function to decide which training samples to use.

  --     - split_id is to be used to share some of the training samples, this is
  -- going to be the id of the child in the case of parallel training
  --     - task is the path to the task folder of the sample
  -- ('/data/program_samples/new-proven-synth/p01')
  --     - sample is the path to the starting program
  -- ('/data/program_samples/new-proven-synth/p01/samples/1.s')
  --     - all_samples is the list of all already loaded samples by this thread
  local all_samples = {}
  local all_tasks = dir.getdirectories(path_to_dataset_folder)
  for _, task in pairs(all_tasks) do
    local task_folder = path.join(path_to_dataset_folder, task)
    local def_in_file = path.join(task_folder, "def_in")
    local live_out_file = path.join(task_folder, "live_out")
    local test_file = path.join(task_folder, "test.tc")
    local task_samples = dir.getfiles(path.join(task_folder, "samples"))
    for _, sample in pairs(task_samples) do
      local target_file = path.join(task_folder, "samples", sample)

      local should_load = predicate(split_id, task, sample, all_samples)

      if should_load then
        table.insert(all_samples, {
                       def_in_file = def_in_file,
                       live_out_file = live_out_file,
                       test_file = test_file,
                       target_file = target_file,
        })
      end
    end
  end
  return all_samples

end

dataset.load_sample = function(sample_tab, nb_inst_dim)
  local c_object = ffi.new("void*[1]")
  local bag_of_words = torch.IntTensor(nb_inst_dim):zero()
  ffi.sigint_handler_fix()
  ffi.C.slave_init(sample_tab.def_in_file,
                   sample_tab.live_out_file,
                   sample_tab.test_file,
                   sample_tab.target_file,
                   c_object,
                   bag_of_words:cdata())
  ffi.sigint_handler_restore()
  return c_object, bag_of_words
end

dataset.collect_max_sp = function(path_to_dataset_folder, max_samples)
  local predicate = function(split_id, task, sample, all_samples)
    return #all_samples < max_samples
  end
  return dataset.collect_predicate(0, path_to_dataset_folder, predicate)
end

dataset.collect_task = function(path_to_dataset_folder, which_task)
  local filter = function(split_id, task_id, sample_id)
    return split_id == task_id
  end
  local predicate = dataset.make_dataset_filter(filter)
  return dataset.collect_predicate(which_task, path_to_dataset_folder, predicate)
end

return dataset
