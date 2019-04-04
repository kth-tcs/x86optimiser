local sys = require 'sys'
local filex = require 'pl.file'
local stringx = require 'pl.stringx'
local torch = require 'torch'
local ffi = require 'lua/ffi'
local path = require 'pl.path'

torch.setdefaulttensortype('torch.FloatTensor')


local path_to_lib = "bin/stoke-slave.so"
ffi.load_stoke(path_to_lib)

local nb_inst_dim = ffi.C.nb_possible_instruction()

local function_and_testcases_generate = function(instruction_distribution)

  -- Generate a random program
  ffi.C.randomly_generate_stuff(instruction_distribution:data(), instruction_distribution:nElement())

  -- Generate a file containing its def_ins
  local def_ins_creation = "./bin/stoke testcase --out new_dataset/testcases --target new_dataset/new_one.s --in_file new_dataset/def_in --out_file new_dataset/live_out"
  local res_defins = sys.execute(def_ins_creation)

  -- Attempt to generate testcases using those def_ins
  local defins_file = io.open("new_dataset/def_in")
  local def_ins_all = defins_file:read()
  defins_file:close()

  local live_out_file = io.open("new_dataset/live_out")
  local live_out_all = live_out_file:read()
  live_out_file:close()

  local command = "./bin/stoke testcase --out new_dataset/testcases --target new_dataset/new_one.s  --max_testcases 1024 --def_in \"" .. def_ins_all .. "\" --live_out \"".. live_out_all  .. "\""

  local res = sys.execute(command)

  local is_success = path.exists("new_dataset/testcases")
  if not is_success then
    local faulty_instruction = string.match(res, "undefined location: Instruction '([^']+)' reads { }")
    if faulty_instruction then
      local trimmed_faulty = stringx.strip(faulty_instruction)
      return false, trimmed_faulty
    else
      print("Error")
      print(res)
      return false, nil
    end
  else
    return true, nil
  end

end


local path_to_list = "List_instructions.txt"

local get_name_to_index = function(path)
  local file_content = io.open(path)
  local name_to_index = {}
  for line in file_content:lines() do
    local pattern = "(%d+)\t+(.*)\t%d"
    local pos, instr = string.match(line, pattern)
    pos = tonumber(pos)
    if pos > 0 then
      local existing = name_to_index[instr] or {}
      table.insert(existing, pos)
      name_to_index[instr] = existing
    end
  end
  return name_to_index
end

local store_results = function()
  local root_target_directory = "new_dataset/"
  local idx = 1
  local target_directory
  while true do
    target_directory = path.join(root_target_directory, tostring(idx))
    if path.isdir(target_directory) then
      idx = idx + 1
    else
      break
    end
  end
  path.mkdir(target_directory)
  filex.move("new_dataset/new_one.s", path.join(target_directory, "sample.s"))
  filex.move("new_dataset/def_in", path.join(target_directory, "def_in"))
  filex.move("new_dataset/testcases", path.join(target_directory, "test.tc"))
  filex.move("new_dataset/live_out", path.join(target_directory, "live_out"))
end

local mapping = get_name_to_index(path_to_list)

local path_to_random_synthesis_proposal = "new_dataset/proposal_for_synthesis.t7"
local instruction_distribution
if path.exists(path_to_random_synthesis_proposal)  then
  instruction_distribution = torch.load(path_to_random_synthesis_proposal)
else
  instruction_distribution = torch.Tensor(nb_inst_dim):fill(1)
end

local loop_on_example_generation = function()
  while true do
    local success, to_change = function_and_testcases_generate(instruction_distribution)
    if not success then
      if mapping[to_change] ~= nil then
        for _, val in pairs(mapping[to_change]) do
          print("Dropping the suggestion for" .. to_change .. ", removing instruction " .. val)
          instruction_distribution[val] = 0
        end
      end
      torch.save("new_dataset/proposal_for_synthesis.t7", instruction_distribution)
    else
      print("Successful program")
      store_results()
    end
  end
end


loop_on_example_generation()
