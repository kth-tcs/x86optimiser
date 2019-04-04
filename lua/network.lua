local network = {}
local torch = require 'torch'
local nn = require 'nn'

-- Data independent bias module
local DA_bias, parent = torch.class('nn.DABias', 'nn.Module')

function DA_bias:__init(output_size, gradient_scaling)
  parent.__init(self)
  self.bias = torch.Tensor(output_size)
  self.bias:fill(0)
  self.gradBias = torch.Tensor(output_size)
  self.gradInput = torch.Tensor()
  self.gradient_scaling = gradient_scaling
end

function DA_bias:updateOutput(input)
  -- The output is constant but gives the correct number of output for the batch
  self.output:resize(input:size(1), self.bias:size(1))
  for i = 1, input:size(1) do
    self.output[i] = self.bias
  end
  return self.output
end

function DA_bias:updateGradInput(input, gradOutput)
  -- This is a dumb module that return a constant bias.
  -- There is therefore no gradients to its input
  self.gradInput:resizeAs(input):fill(0)
  return self.gradInput
end


function DA_bias:accGradParameters(input, gradOutput, scale)
  local unbatched_gradOutput = gradOutput:sum(1):squeeze()
  self.gradBias:add(self.gradient_scaling*scale, unbatched_gradOutput)
end

function DA_bias:zeroGradParameters()
  self.gradBias:fill(0)
end

function DA_bias:parameters()
  return {self.bias}, {self.gradBias}
end


-- Proba cluster module
local PCluster, parent = torch.class('nn.PCluster', 'nn.Module')

local parse_clustering_file = function(path_to_clustering_file)
  local file = io.open(path_to_clustering_file)
  local cluster_association = {}
  local max_cluster = 1
  if file then
    for line in file:lines() do
      local instr_id, cluster_id = unpack(line:split("\t"))
      cluster_id = tonumber(cluster_id)
      max_cluster = math.max(max_cluster, cluster_id)
      table.insert(cluster_association, {tonumber(instr_id)+1, tonumber(cluster_id)})
    end
  end
  return cluster_association, max_cluster
end


function PCluster:__init(input_size, output_size, cluster_association)
  parent.__init(self)
  self.input_size = input_size
  self.output_size = output_size
  self.transfo_matrix = torch.Tensor(output_size, input_size):fill(0)
  self.transfo_matrix:select(2,input_size):fill(1) -- By default, the default cluster leads to everything
  for _, ass_pair in ipairs(cluster_association) do
    local instr_id = ass_pair[1]
    local cluster_id = ass_pair[2]
    self.transfo_matrix:select(1,instr_id):fill(0)
    self.transfo_matrix[instr_id][cluster_id] = 1
  end
end

function PCluster:updateOutput(input)
  self.output:resize(input:size(1), self.output_size):fill(0)
  self.output:addmm(0, self.output, 1, input, self.transfo_matrix:t())
  return self.output
end

function PCluster:updateGradInput(input, gradOutput)
  self.gradInput:resizeAs(input):fill(0)
  self.gradInput:addmm(0, 1, gradOutput, self.transfo_matrix)
  return self.gradInput
end

network.bias_network = function (in_dimension, out_dimensions, path_to_clustering_file)
  local outputter = nn.ConcatTable()

  -- Move type
  local move_proba = nn.Sequential()
  move_proba:add(nn.DABias(out_dimensions[1], 1))
  move_proba:add(nn.SoftMax())
  outputter:add(move_proba)

  -- Proba on Instsruction
  local cluster_association, max_cluster = parse_clustering_file(path_to_clustering_file)
  local instr_proba = nn.Sequential()
  instr_proba:add(nn.DABias(max_cluster+1, 1))
  instr_proba:add(nn.PCluster(max_cluster+1, out_dimensions[2], cluster_association))
  instr_proba:add(nn.SoftMax())
  outputter:add(instr_proba)

  return outputter
end

network.mlp_network = function(in_dimension, out_dimensions, path_to_clustering_file)
  local feature_encoder = nn.Sequential()
  feature_encoder:add(nn.Linear(in_dimension, 100))
  feature_encoder:add(nn.ReLU())
  feature_encoder:add(nn.Linear(100, 300))
  feature_encoder:add(nn.ReLU())
  feature_encoder:add(nn.Linear(300, 300))
  feature_encoder:add(nn.ReLU())

  local outputter = nn.ConcatTable()

  -- Move type
  local move_proba = nn.Sequential()
  move_proba:add(nn.Linear(300, out_dimensions[1]))
  move_proba:add(nn.SoftMax())
  outputter:add(move_proba)
  -- Instruction proba
  local cluster_association, max_cluster = parse_clustering_file(path_to_clustering_file)
  local instr_proba = nn.Sequential()
  instr_proba:add(nn.Linear(300, max_cluster+1))
  instr_proba:add(nn.PCluster(max_cluster+1, out_dimensions[2], cluster_association))
  instr_proba:add(nn.SoftMax())
  outputter:add(instr_proba)


  local whole_net = nn.Sequential()
  whole_net:add(feature_encoder)
  whole_net:add(outputter)

  return whole_net
end

network.big_mlp_network = function(in_dimension, out_dimensions, path_to_clustering_file)
  local feature_encoder = nn.Sequential()
  feature_encoder:add(nn.Linear(in_dimension, 1000))
  feature_encoder:add(nn.ReLU())
  feature_encoder:add(nn.Linear(1000, 1000))
  feature_encoder:add(nn.ReLU())
  feature_encoder:add(nn.Linear(1000, 1500))
  feature_encoder:add(nn.ReLU())

  local outputter = nn.ConcatTable()

  -- Move type
  local move_proba = nn.Sequential()
  move_proba:add(nn.Linear(1500, out_dimensions[1]))
  move_proba:add(nn.SoftMax())
  outputter:add(move_proba)
  -- Instruction proba
  local cluster_association, max_cluster = parse_clustering_file(path_to_clustering_file)
  local instr_proba = nn.Sequential()
  instr_proba:add(nn.Linear(1500, max_cluster+1))
  instr_proba:add(nn.PCluster(max_cluster+1, out_dimensions[2], cluster_association))
  instr_proba:add(nn.SoftMax())
  outputter:add(instr_proba)


  local whole_net = nn.Sequential()
  whole_net:add(feature_encoder)
  whole_net:add(outputter)

  return whole_net
end


network.restricted_linear = function(in_dimension, out_dimensions, path_to_clustering_file)
  local feature_encoder = nn.Sequential()
  feature_encoder:add(nn.Linear(in_dimension, 100))
  --feature_encoder:add(nn.ReLU())
  feature_encoder:add(nn.Linear(100, 300))
  --feature_encoder:add(nn.ReLU())
  feature_encoder:add(nn.Linear(300, 300))
  --feature_encoder:add(nn.ReLU())

  local outputter = nn.ConcatTable()

  -- Move type
  local move_proba = nn.Sequential()
  move_proba:add(nn.Linear(300, out_dimensions[1]))
  move_proba:add(nn.SoftMax())
  outputter:add(move_proba)
  -- Instruction proba
  local cluster_association, max_cluster = parse_clustering_file(path_to_clustering_file)
  local instr_proba = nn.Sequential()
  instr_proba:add(nn.Linear(300, max_cluster+1))
  instr_proba:add(nn.PCluster(max_cluster+1, out_dimensions[2], cluster_association))
  instr_proba:add(nn.SoftMax())
  outputter:add(instr_proba)


  local whole_net = nn.Sequential()
  whole_net:add(feature_encoder)
  whole_net:add(outputter)

  return whole_net
end



network.linear_model = function(in_dimension, out_dimensions, path_to_clustering_file)
  local outputter = nn.ConcatTable()

  -- Move type
  local move_proba = nn.Sequential()
  move_proba:add(nn.Linear(in_dimension, out_dimensions[1]))
  move_proba:add(nn.SoftMax())
  outputter:add(move_proba)

  -- Instruction proba
  local cluster_association, max_cluster = parse_clustering_file(path_to_clustering_file)
  local instr_proba = nn.Sequential()
  instr_proba:add(nn.Linear(in_dimension, max_cluster+1))
  instr_proba:add(nn.PCluster(max_cluster+1, out_dimensions[2],cluster_association))
  instr_proba:add(nn.SoftMax())
  outputter:add(instr_proba)

  return outputter
end


return network
