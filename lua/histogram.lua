local torch = require 'torch'
local path = require 'pl.path'
local network = require 'lua/network'
require 'lua/mcmc_loss' -- For nn.MCMCCriterion
torch.setdefaulttensortype('torch.FloatTensor')

local ffi = require 'lua/ffi'
ffi.load_stoke("bin/stoke-slave.so")
local nb_inst_dim = ffi.C.nb_possible_instruction()

local lapp = require 'pl.lapp'
local opt = lapp([[
  Getting an histogram of the values achieved by optimizing a program
  Main options
  <path_to_sample_dir>   (string)        Path to the sample directory
  <network_to_use>       (string)        Path to the network to load or name of the network to initialise
  <nb_iter>              (number)        Number of iterations to do the optimisation for
  --nb_samples           (default 500)   How many samples to put in the histogram
  --path_to_output       (default nil)   Where to store the output
  ]], arg)


local path_to_output
if not opt.path_to_output then
  path_to_output = path.join(opt.path_to_sample_dir, "bins.dat")
else
  path_to_output = opt.path_to_output
end

-- Load the sample
local c_object = ffi.new("void*[1]")
local bag_of_words = torch.IntTensor(nb_inst_dim):zero()
ffi.sigint_handler_fix()
ffi.C.slave_init(
  path.join(opt.path_to_sample_dir, "def_in"),
  path.join(opt.path_to_sample_dir, "live_out"),
  path.join(opt.path_to_sample_dir, "test.tc"),
  path.join(opt.path_to_sample_dir, "sample.s"),
  c_object,
  bag_of_words:cdata()
)
ffi.sigint_handler_restore()


local net
if opt.network_to_use=="bias_network" or opt.network_to_use=="mlp_network" then
  local network_generating_function = network[opt.network_to_use]
  net = network_generating_function(nb_inst_dim, {9, nb_inst_dim}, "all_valid_splitted.ini")

  local param, gradParam = net:getParameters()
  if opt.network_to_use == "bias_network" then
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
  net = torch.load(opt.network_to_use)
end


local mcmc_criterion = nn.MCMCCriterion(opt.nb_iter)
local net_input = bag_of_words:float():view(1,-1)
local proba = net:forward(net_input)
local all_scores = {}
for sp=1, opt.nb_samples do
  local unbatched_proba = {proba[1][1],
                           proba[2][1]}
  mcmc_criterion:forward(c_object,unbatched_proba)
  local score = mcmc_criterion.final_reward / mcmc_criterion.initial_score
  table.insert(all_scores, score)
end

-- Perform the binning
local all_bins = {}
for i=1,10 do
  all_bins[i] = 0
end

for _, score in ipairs(all_scores) do
  -- print(score)
  local bin = math.floor(score * 10 - 0.001) + 1
  all_bins[bin] = all_bins[bin] + 1
end

for bin, nb_in_bin in ipairs(all_bins) do
  all_bins[bin] = nb_in_bin / opt.nb_samples
end

local target_file = io.open(path_to_output, 'w')
for bin_idx, nb_in_bin in ipairs(all_bins) do
  target_file:write((bin_idx - 1)/10, "\t", nb_in_bin, "\n")
end
target_file:close()
