local torch = require 'torch'
local ffi = require 'lua/ffi'
local dataset = require 'lua/dataset'
local network = require 'lua/network'
local vis = require 'lua/vis'
local gnuplot = require 'gnuplot'

require 'lua/mcmc_loss' -- For nn.MCMCCriterion
torch.setdefaulttensortype('torch.FloatTensor')

local path_to_dataset = "/data/program_samples/proven-synth"

print("Loading dataset...")
local samples = dataset.collect(path_to_dataset, 1)
local sample = samples[1] -- We have a single sample here
print("Dataset loaded")

local nb_inst_dim = ffi.C.nb_possible_instruction()
local nb_operation_type = 9
local bias_network = network.bias_network({nb_operation_type, nb_inst_dim})

local param, gradParam = bias_network:getParameters()
param:fill(0)

local mcmc_criterion = nn.MCMCCriterion()

local nb_step_in_mcmc = {1,3,5,10,30,50,100,300,500}
local nb_samples_for_variance = 20000

local out_file_stub = "exp/variance_studying/"

for _, nb_step in ipairs(nb_step_in_mcmc) do
  print("Studying the variance " .. nb_step .. " steps.")
  local out_file = out_file_stub .. tostring(nb_step) .. "-step.png"
  print("Going to generate: ", out_file)
  mcmc_criterion.nb_iter = nb_step
  local rewards_tensor = torch.Tensor(nb_samples_for_variance)
  local variances = torch.Tensor(nb_samples_for_variance)

  local net_input = sample.bag_of_words:float()
  local proba = bias_network:forward(net_input)
  for sp=1,nb_samples_for_variance do
    local final_reward = mcmc_criterion:forward(sample, proba)
    rewards_tensor[sp] = final_reward
    -- Compute the variances of the first sp elements
    variances[sp] = torch.var(rewards_tensor:narrow(1,1,sp))
  end

  gnuplot.pngfigure(out_file)
  gnuplot.title("Variance when performing " .. nb_step .. " steps of MCMC")
  gnuplot.xlabel("Nb samples")
  gnuplot.ylabel("Variance")
  gnuplot.plot(variances)
  gnuplot.plotflush()

end
print("Lua taking back control")
