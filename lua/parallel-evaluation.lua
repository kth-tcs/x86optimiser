local torch = require 'torch'
local parallel = require 'parallel'
local loss_process = require 'lua/loss_process'


local trainer = function()
  local network = require 'lua/network'
  local ffi = require 'lua/ffi'
  local conf = require 'lua/conf'
  local optim = require 'optim'

  ffi.load_stoke(conf.path_to_lib)
  parallel.print("Starting the Parent Process")
  local nb_inst_dim = ffi.C.nb_possible_instruction()

  -- local network_generating_function = network[conf.network_to_use]
  -- local net = network_generating_function(nb_inst_dim, {conf.nb_operation_type, nb_inst_dim}, conf.path_to_clustering_file)

  -- local param, gradParam = net:getParameters()
  -- if conf.network_to_use == "bias_network" then
  --   param:fill(0)
  -- else
  --   -- Set all the weights from a uniform distribution over -0.2 .. 0.2
  --   local stdv = 0.2
  --   param:uniform(-stdv, stdv)
  --   -- Still set the biases of the final layer to zero to have a similar starting point
  --   net.modules[2].modules[1].modules[1].bias:fill(0)
  --   net.modules[2].modules[2].modules[1].bias:fill(0)
  -- end


   local path_to_network = "exp/bias_adam_synthetic_dataset_superlarge_grad_1/Weights/Iter_8.dump"
   local net = torch.load(path_to_network)
   local param, gradParam = net:getParameters()

  -- Define a function that evaluates the score and the gradient
  local function feval(params)
        net:zeroGradParameters()
        local start_pos
        -- Preparing the batch to forward through
        local feats = {}
        local batch_actual_size = 0
        -- Get each childs process samples
        -- parallel.print("Going to wait for feature input")
        for i, child in ipairs(parallel.children) do
          feats[i] = child:receive()
          if feats[i]:dim() ~= 0 then
            batch_actual_size = batch_actual_size + feats[i]:size(1)
          end
        end
        -- Put all of it into one single tensor
        local net_input = torch.Tensor(batch_actual_size, nb_inst_dim)
        start_pos = 1
        for _, feat in ipairs(feats) do
          if feat:dim() ~= 0 then
            net_input:narrow(1, start_pos, feat:size(1)):copy(feat:float())
            start_pos = start_pos + feat:size(1)
          end
        end


        -- Get the corresponding probabilities
        local probas = net:forward(net_input)
        -- Send them to the child workers
        -- Send the corresponding proba to each
        start_pos = 1
        for i, child in ipairs(parallel.children) do
          if feats[i]:dim() ~= 0 then
            child:send({probas[1]:narrow(1, start_pos, feats[i]:size(1)),
                        probas[2]:narrow(1, start_pos, feats[i]:size(1))})
            start_pos = start_pos + feats[i]:size(1)
          end
        end
        local grad_outputs = {
          torch.Tensor(batch_actual_size, conf.nb_operation_type),
          torch.Tensor(batch_actual_size, nb_inst_dim)
        }

        -- Get the gradients and reward back
        local reward_sum = 0
        start_pos = 1
        for i, child in ipairs(parallel.children) do
          if feats[i]:dim() ~= 0 then
            local rep = child:receive()
            reward_sum = reward_sum + rep.rew
            grad_outputs[1]:narrow(1, start_pos, feats[i]:size(1)):copy(rep.grad[1])
            grad_outputs[2]:narrow(1, start_pos, feats[i]:size(1)):copy(rep.grad[2])
            start_pos = start_pos + feats[i]:size(1)
          end
        end

        -- Backpropagate them
        net:backward(net_input, grad_outputs)

        return reward_sum, gradParam
      end

    parallel.nfork(conf.nb_child_process)
    parallel.children:exec(loss_process)
    parallel.children:send({stoke_lib = conf.path_to_lib,
                            conf = conf.path_to_conf})
    parallel.children:join()

    -- How many samples does each child has to go through
    -- Both in the training case and in the validation case
    local max_training_samples = 0
    local max_testing_samples = 0
    local nb_train = {}
    local nb_test = {}
    for i, child in ipairs(parallel.children) do
      local counts = child:receive()
      parallel.print("Child " .. tostring(i) .. " has " .. tostring(counts.train) .. " training samples and " .. tostring(counts.test) .. " testing samples")
      max_training_samples = math.max(max_training_samples, counts.train)
      max_testing_samples = math.max(max_testing_samples, counts.test)
      nb_train[i] = counts.train
      nb_test[i] = counts.test
    end
    parallel.print("Started the child processes.")

    parallel.print("Starting an train_eval")
    parallel.children:send("train_eval")
    local test_loss = 0
    while true do
      parallel.children:send("batch")
      -- parallel.print("Doing a testing minibatch")
      local batch_loss, _ = feval(param)
      test_loss = test_loss + batch_loss
      local keep_batching = false
      for _, child in ipairs(parallel.children) do
        local child_keep = child:receive()
        keep_batching = keep_batching or (child_keep=="keep")
      end
      if not keep_batching then
        parallel.children:send("break")
        break
      end
    end
    parallel.print("Trainval loss is " .. test_loss)

    parallel.children:send("break")
    parallel.children:sync()
    parallel.reset()
    collectgarbage()
    collectgarbage()

end


local ok, err = xpcall(trainer, debug.traceback)
if not ok then
  print(err)
  parallel.close()
end
