local dir = require 'pl.dir'
local gnuplot = require 'gnuplot'
--local clust = require 'lua/clusterer'
local image = require 'image'
local path = require 'pl.path'
local torch = require 'torch'
local vis = {}


local VisualisationHandler = torch.class('VisualisationHandler', vis)


local print_proba = function(title, proba, max_width, per_line, filename)
  local nb_line = math.ceil(proba:nElement()/per_line)


  local img_proba = proba:view(1,1,proba:nElement())
  local proba_minmaxed = image.minmax({tensor=img_proba})


  local container = torch.Tensor(per_line * nb_line):zero()
  container:narrow(1, 1, img_proba:nElement()):copy(img_proba)
  container = container:view(1, nb_line, per_line)

  local container_minmax = torch.Tensor(per_line * nb_line):zero()
  container_minmax:narrow(1, 1, img_proba:nElement()):copy(proba_minmaxed)
  container_minmax = container_minmax:view(1, nb_line, per_line)


  local sized_img = image.scale(container, tostring(max_width), "simple")
  local sized_img_minmax = image.scale(container_minmax, tostring(max_width), "simple")

  image.save("proba.png", sized_img)
  image.save("proba_norm.png", sized_img_minmax)

  local whitespace_line = "-background white -fill white label:empty -fill black "

  local cmd = "convert "
  cmd = cmd .. "-background white -pointsize 24 label:" .. title .. " -gravity center -pointsize 16 "
  cmd = cmd .. whitespace_line
  cmd = cmd .. "proba.png label:Unnormalized -gravity center "
  cmd = cmd .. whitespace_line
  cmd = cmd .. "proba_norm.png label:Rescaled -gravity center "
  cmd = cmd .. "-append '" .. filename .. "'"
  os.execute(cmd)
  os.remove("proba.png")
  os.remove("proba_norm.png")
end




function VisualisationHandler:__init(conf)
  self.path_to_experiment_folder = "exp/"

  local idx = 1
  local target_directory
  if conf.path_to_start_net ~= nil then
    target_directory = conf.path_to_existing_exp
  else
    while true do
      local numbered_exp_name = conf.experiment_name .. "_" .. tostring(idx)
      target_directory = path.join(self.path_to_experiment_folder, numbered_exp_name)
      if path.isdir(target_directory) then
        idx = idx + 1
      else
        break
      end
    end
  end
    -- Create the directory of the experiment, containing everything
  self.target_dir = target_directory
  dir.makepath(target_directory)

  local stoke_lib_name = path.basename(conf.path_to_lib)
  local stoke_lib_path = path.join(target_directory, stoke_lib_name)
  if path.exists(conf.path_to_lib) and not path.exists(stoke_lib_path) then
    dir.copyfile(conf.path_to_lib, stoke_lib_path)
  end
  -- Modify the path in the conf so that it is properly obtained
  conf.path_to_lib = stoke_lib_path

  -- Contains plot of MCMC traces
  self.mcmc_traces_dir = path.join(target_directory, "MCMC_Traces")
  dir.makepath(self.mcmc_traces_dir)

  -- Contains weight dumps
  self.weights_dir = path.join(target_directory, "Weights")
  dir.makepath(self.weights_dir)

  -- Plot with all the rewards
  self.reward_tracking_file = path.join(target_directory, "online_train_rewards.png")
  self.loss_tracking_file = path.join(target_directory, "test_rewards.png")
  self.trainloss_tracking_file = path.join(target_directory, "train_eval_rewards.png")

  self.loss_val_dump = path.join(target_directory, "test_dump.th")
  self.trainloss_val_dump = path.join(target_directory, "train_dump.th")
  self.onlinetrain_val_dump = path.join(target_directory, "online_train_dump.th")


  -- Probability visualisation
  self.proba_dir = path.join(target_directory, "probabilities")
  dir.makepath(self.proba_dir)

  -- Copy the cluster file that was used so that we know which one it was
  local name_of_cluster_file = path.basename(conf.path_to_clustering_file)
  local stored_cluster_file_path = path.join(self.target_dir, name_of_cluster_file)
  print(conf.path_to_clustering_file)
  print(stored_cluster_file_path)
  dir.copyfile(conf.path_to_clustering_file, stored_cluster_file_path)

  local path_to_conf = "lua/conf.lua"
  if path.exists(path_to_conf) then
    local stored_conf_file = path.join(self.target_dir, "conf.lua")
    dir.copyfile(path_to_conf, stored_conf_file)
    conf.path_to_conf = stored_conf_file
  end

  -- Setup a log file, counting how many times each instruction is used.
  local instr_usage = path.join(target_directory, "Instr_usage.log")
  --self.clusterer = clust.Clusterer(instr_usage, nb_inst_dim)

  gnuplot.setterm('pngcairo')
  self.mcmc_traces = {}
  if conf.path_to_start_net ~= nil then
    self.current_iter = conf.start_from_it
    local train_tensor = torch.load(self.trainloss_val_dump)
    local test_tensor = torch.load(self.loss_val_dump)
    local onlinetrain_tensor = torch.load(self.onlinetrain_val_dump)
    self.train_rewards = {}
    self.test_rewards = {}
    self.trainval_rewards = {}
    for i=1,onlinetrain_tensor:nElement() do
      self.trainval_rewards[i] = onlinetrain_tensor[i]
      self.train_rewards[i] = train_tensor[i]
      self.test_rewards[i] = test_tensor[i]
    end
  else
    self.current_iter = 0
    self.train_rewards = {}
    self.test_rewards = {}
    self.trainval_rewards = {}
  end
end

function VisualisationHandler:start_iteration()
  self.current_iter = self.current_iter + 1
  self.mcmc_traces = {}
end

function VisualisationHandler:collect_score_trace(mcmc_history, mcmc_history_size)
  --self.clusterer:collect_trace(mcmc_history, mcmc_history_size)
  local trace = torch.Tensor(mcmc_history_size)
  local smallest_so_far = mcmc_history[0].score_before
  for i=0, mcmc_history_size - 1 do
    smallest_so_far = math.min(smallest_so_far, mcmc_history[i].score_before)
    trace[i+1] = smallest_so_far
  end
  table.insert(self.mcmc_traces, {trace})
end

function VisualisationHandler:finish_test_epoch(score)
  table.insert(self.test_rewards, score)

  local loss_tensor = torch.Tensor(self.test_rewards)
  gnuplot.pngfigure(self.loss_tracking_file)
  gnuplot.title("Loss rewards")
  local range_min = loss_tensor:min()
  local range_max = loss_tensor:max()
  local margin = 0.2 * (range_max - range_min)
  gnuplot.axis({0,#self.test_rewards,
                range_min - margin , range_max + margin })
  gnuplot.xlabel("Nb epochs")
  gnuplot.ylabel("Expected Reward")
  gnuplot.plot(loss_tensor)
  gnuplot.plotflush()
  torch.save(self.loss_val_dump,loss_tensor)
end

function VisualisationHandler:finish_trainval_epoch(score)
  table.insert(self.trainval_rewards, score)

  local loss_tensor = torch.Tensor(self.trainval_rewards)
  gnuplot.pngfigure(self.trainloss_tracking_file)
  gnuplot.title("Loss rewards")
  local range_min = loss_tensor:min()
  local range_max = loss_tensor:max()
  local margin = 0.2 * (range_max - range_min)
  gnuplot.axis({0,#self.trainval_rewards,
                range_min - margin , range_max + margin })
  gnuplot.xlabel("Nb epochs")
  gnuplot.ylabel("Expected Reward")
  gnuplot.plot(loss_tensor)
  gnuplot.plotflush()
  torch.save(self.trainloss_val_dump,loss_tensor)
end

function VisualisationHandler:flush_iter(network, score)
  -- Dump the instr usage
  --self.clusterer:dump_clusters_on_off()


  -- Dump the weights
  local weights_name = path.join(self.weights_dir, "Iter_" ..
                                   tostring(self.current_iter) ..
                                   ".dump")
  torch.save(weights_name, network)
  --


  -- Create the plots of the MCMC Traces
  if #(self.mcmc_traces) > 1 then
    local mcmc_traces_plot_name = path.join(self.mcmc_traces_dir, "Iter_" ..
                                              tostring(self.current_iter) ..
                                              ".png")
    -- Setup the plotting
    gnuplot.pngfigure(mcmc_traces_plot_name)
    -- Add the style option
    gnuplot.title("MCMC traces")
    local max_value = 0
    for i=1,#self.mcmc_traces do
        max_value = math.max(self.mcmc_traces[i][1]:max(), max_value)
    end 
    gnuplot.axis({0,self.mcmc_traces[1][1]:size(1), 0, max_value})
    gnuplot.xlabel("Iterations")
    gnuplot.ylabel("Score")
    for _, trace in ipairs(self.mcmc_traces) do
      table.insert(trace, 'with lines lc rgb \"#DDFF0000\"')
    end
    -- Plotting
    gnuplot.plot(self.mcmc_traces)
    -- And flushing to file
    gnuplot.plotflush()
    --
  end

  -- Add to the tracking of the average reward
  table.insert(self.train_rewards, score)
  local rewards_tensor = torch.Tensor(self.train_rewards)
  -- Setup plotting
  gnuplot.pngfigure(self.reward_tracking_file)
  -- Styles
  gnuplot.title("Rewards over time")
  gnuplot.axis({0, self.current_iter,
                rewards_tensor:min()-1, rewards_tensor:max()+1})
  gnuplot.xlabel("Nb epochs")
  gnuplot.ylabel("Expected Reward")
  -- Plotting
  gnuplot.plot(rewards_tensor)
  -- Flushing to file
  gnuplot.plotflush()
  torch.save(self.onlinetrain_val_dump,rewards_tensor)
  --


  -- Dump the probabilities
  -- Only in the case where we have single batch and it
  -- makes sense
  if network.output[1]:size(1) == 1 then
    local move_file = path.join(self.proba_dir, "Move Iter_"..
                                  tostring(self.current_iter) ..
                                  ".png")
    local instr_file = path.join(self.proba_dir, "Instr Iter_"..
                                   tostring(self.current_iter) ..
                                   ".png")


    local move_proba = network.output[1]
    local instruction_proba = network.output[2]
    print_proba("'Move Probability Iteration: " .. tonumber(self.current_iter) .. "'",
                move_proba,
                500, 9,
                move_file)
    print_proba("'Instruction Probability Iteration: " .. tonumber(self.current_iter) .. "'",
                instruction_proba,
                500, 50,
                instr_file)
  end
  --

  gnuplot.closeall()
end





return vis
