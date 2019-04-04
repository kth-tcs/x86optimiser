local torch = require 'torch'
local gnuplot = require 'gnuplot'
local path = require 'pl.path'
local network = require 'lua/network'
require 'lua/mcmc_loss'
torch.setdefaulttensortype('torch.FloatTensor')

local ffi = require 'lua/ffi'
ffi.load_stoke("bin/stoke-slave.so")
local nb_inst_dim = ffi.C.nb_possible_instruction()

local lapp = require 'pl.lapp'

local opt = lapp([[
  Stochastic traces plot maker 2016 - ICLR edition
  Main options
  <weights>            (string)        Path to the weights, or name of the network for an init
  <path_to_task>        (string)        Path to the task folder on which to running
  --path_to_output         (default nil)
  --nb_traces              (default 100)
  ]], arg)


local path_to_output
if not opt.path_to_output then
  path_to_output = path.join(opt.path_to_task, "traces.png")
else
  path_to_output = opt.path_to_output
end


local net

if opt.weights=="bias_network" or opt.weights=="mlp_network" then
  local network_generating_function = network[opt.weights]
  net = network_generating_function(nb_inst_dim, {9, nb_inst_dim}, "all_valid_splitted.ini")

  local param, gradParam = net:getParameters()
  if opt.weights == "bias_network" then
    param:fill(0)
  else
    -- Set all the weights from a uniform distribution over -0.2 .. 0.2
    local stdv = 0.2
    param:uniform(-stdv, stdv)
    -- Still set the biases of the final layer to zero to have a similar starting point
    net.modules[2].modules[1].modules[1].bias:fill(0)
    net.modules[2].modules[2].modules[1].bias:fill(0)
  end
else
  net = torch.load(opt.weights)
end

-- Load the sample
local c_object = ffi.new("void*[1]")
local bag_of_words = torch.IntTensor(nb_inst_dim):zero()
ffi.sigint_handler_fix()
ffi.C.slave_init(
  path.join(opt.path_to_task, "def_in"),
  path.join(opt.path_to_task, "live_out"),
  path.join(opt.path_to_task, "test.tc"),
  path.join(opt.path_to_task, "sample.s"),
  c_object,
  bag_of_words:cdata()
)
ffi.sigint_handler_restore()

-- Create an MCMC Criterion
local mcmc_criterion = nn.MCMCCriterion(200)

local instruction_sampled = torch.IntTensor(nb_inst_dim):zero()
local move_sampled = torch.IntTensor(9):zero()

-- Get the traces
local mcmc_traces = {}
local net_input = bag_of_words:float():view(1,-1)
local proba = net:forward(net_input)
for sp=1, opt.nb_traces do
  local unbatched_proba = {proba[1][1],
                           proba[2][1]}
  mcmc_criterion:forward(c_object,unbatched_proba)
  local new_trace = torch.Tensor(mcmc_criterion.mcmc_history_size)
  local initial_value = mcmc_criterion.mcmc_history[0].score_before
  local smallest_so_far = 1
  for i=0, mcmc_criterion.mcmc_history_size-1 do
    local iter = mcmc_criterion.mcmc_history[i]
    smallest_so_far = math.min(smallest_so_far, iter.score_before/initial_value)
    new_trace[i+1] = smallest_so_far

    if iter.instr_picked < nb_inst_dim then
      instruction_sampled[iter.instr_picked+1] =instruction_sampled[iter.instr_picked+1] + 1
    end
    move_sampled[iter.move_picked+1] = move_sampled[iter.move_picked+1] + 1
  end
  table.insert(mcmc_traces, {new_trace})
end


-- Create the plot
gnuplot.setterm('pngcairo')
gnuplot.pngfigure(path_to_output)
gnuplot.axis({0, mcmc_criterion.mcmc_history_size,
              0, 1})
gnuplot.xlabel("Number of iterations")
gnuplot.ylabel("Score")

for _, trace in ipairs(mcmc_traces) do
  table.insert(trace, 'with lines lc rgb \"#DDFF0000\"')
end
gnuplot.plot(mcmc_traces)
gnuplot.plotflush()
gnuplot.closeall()
