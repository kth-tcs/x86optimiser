local dbg = {}

local saferequire = function(module)
  local function requiref(module)
    return require(module)
  end
  local status_ok, mod = pcall(requiref,module)
  if not(status_ok) then
    -- Do Stuff when no module
    print("Module " .. module .. " not found")
  else
    return mod
  end
end
local debugger = saferequire('fb.debugger')
local torch = require 'torch'

dbg.has_nan = function(ten)
  local has_nan = ten:ne(ten):sum() > 0
  return has_nan
end

dbg.debug_if_nan = function(ten)
  local is_nan = (ten ~= ten)
  if is_nan then
    debugger.enter()
  end
end

dbg.debug_if_hasnan = function (ten)
  if dbg.has_nan(ten) then
    debugger.enter()
  end
end

dbg.run_debugger = function()
  debugger.enter()
end


dbg.check_probabilities = function (sampled_traces, trace_length, accumulator)
  for i=0, trace_length-1 do
    local picked_move = sampled_traces[i].move_picked
    accumulator[picked_move+1] = accumulator[picked_move+1] + 1
  end
end


return dbg
