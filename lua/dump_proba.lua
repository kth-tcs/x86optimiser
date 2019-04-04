local ffi = require 'lua/ffi'
local torch = require 'torch'
torch.setdefaulttensortype('torch.FloatTensor')
local dataset = require 'lua/dataset'
local path = require 'pl.path'
local dir = require 'pl.dir'
local tablex = require 'pl.tablex'
local stringx = require 'pl.stringx'
local conf = require 'lua/conf'
local network = require 'lua/network'

local path_to_lib = "bin/stoke-slave.so"
ffi.load_stoke(path_to_lib)
local nb_inst_dim = ffi.C.nb_possible_instruction()


local nb_most_instr = 10
local experiment_folder = 'exp/'

local path_to_dataset_folder = "/data/program_samples/new-tested-synth/"

local all_directories = dir.getdirectories(experiment_folder)

local prefix = "exp/bias_task_by_task"
tablex.transform(
  function(path)
    if stringx.startswith(path, prefix) then
      -- Remove the prefix
      local id = stringx.replace(path, prefix, '')
      -- Remove the index of the experiments
      id = id:sub(1,-3)
      id = tonumber(id)
      return {path=path,task_id=id}
    else
      return nil
    end
  end,
  all_directories
)

local nb_elt = tablex.size(all_directories)

local get_model = function(dir_path)
  local last_iter = 1
  local path_to_model
  while true do
    path_to_model = dir_path .. "/Weights/Iter_" .. last_iter .. ".dump"
    if path.exists(path_to_model) then
      last_iter = last_iter + 1
    else
      last_iter = last_iter - 1
      break
    end
  end
  path_to_model = dir_path .. "/Weights/Iter_" .. last_iter .. ".dump"
  return torch.load(path_to_model)
end

for _, v in pairs(all_directories) do
  local path_to_analysis = "analysis/mlp_" .. tostring(v.task_id) .. ".t7"
  print("Doing " .. tostring(v.task_id))
  if not path.exists(path_to_analysis) then
    local model = get_model(v.path)
    local samples = dataset.collect_task(path_to_dataset_folder, v.task_id)
    local move_probas = torch.zeros(#samples, conf.nb_operation_type)
    local most_likely_instructions = torch.IntTensor(#samples, nb_most_instr):fill(0)

    for i, sample in ipairs(samples) do
      local _, feat = dataset.load_sample(sample, nb_inst_dim)
      feat = feat:view(1,-1):float()
      local out = model:forward(feat)

      move_probas[i] = out[1]
      for j=1, nb_most_instr do
        local _, argmax = out[2]:max(2)
        argmax = argmax:squeeze()
        out[2][1][argmax] = 0
        most_likely_instructions[i][j] = argmax
      end
    end

    local analysis = {moves=move_probas, inst=most_likely_instructions}
    torch.save(path_to_analysis, analysis)
  end
end
