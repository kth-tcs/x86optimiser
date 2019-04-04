local torch = require 'torch'
local gnuplot = require 'gnuplot'
local path = require 'pl.path'

local lapp = require 'pl.lapp'

local opt = lapp([[
  Plot maker 2016 - ICLR edition
  Main options
  <exp_dir>          (string)      Path to the experiment directory
  --train_scale      (default 1)
  --test_scale       (default 1)
  --ymin             (default 0)
  --ymax             (default 1)
  --nb_points        (default 0)
  --path_to_output   (default nil)
  ]], arg)

-- filter off dumb points
local path_to_train_dump = path.join(opt.exp_dir, "train_dump.th")
local path_to_test_dump = path.join(opt.exp_dir, "test_dump.th")

local path_to_output
if opt.path_to_output=="nil" then
  path_to_output = path.join(opt.exp_dir, "training_curves.eps")
else
  path_to_output = opt.path_to_output
end


local train_val = torch.load(path_to_train_dump)
local test_val = torch.load(path_to_test_dump)
if opt.nb_points ~= 0  and opt.nb_points < train_val:size(1) then
  train_val = train_val:narrow(1,1,opt.nb_points)
  test_val = test_val:narrow(1,1,opt.nb_points)
else
  opt.nb_points = train_val:size(1)
end

local renormed_train = train_val / opt.train_scale
local renormed_test = test_val / opt.test_scale

-- Filter out the weird point that are experimental failures

local train_x = torch.Tensor(opt.nb_points)
local train_y = torch.Tensor(opt.nb_points)
local test_x = torch.Tensor(opt.nb_points)
local test_y = torch.Tensor(opt.nb_points)
local train_idx = 1
local test_idx = 1
local off_point_threshold = 0.07
for i=1, opt.nb_points do
  local take_point = true
  if train_idx>3 then
    -- Average of the last three points:
    local average = train_y:narrow(1, train_idx-3, 3):mean()
    if renormed_train[i]-average > off_point_threshold then
      take_point = false
    end
  end
  if take_point then
    train_x[train_idx] = i
    train_y[train_idx] = renormed_train[i]
    train_idx = train_idx + 1
  end

  take_point = true
  if test_idx>3 then
    -- Average of the last three points:
    local average = test_y:narrow(1, test_idx-3, 3):mean()
    if renormed_test[i]-average > off_point_threshold  then
      take_point = false
    end
  end
  if take_point then
    test_x[test_idx] = i
    test_y[test_idx] = renormed_test[i]
    test_idx = test_idx + 1
  end
end

train_x = train_x:narrow(1,1,train_idx-1)
test_x = test_x:narrow(1,1,test_idx-1)
train_y = train_y:narrow(1,1,train_idx-1)
test_y = test_y:narrow(1,1,test_idx-1)

print(path_to_output)
print("Using " .. tostring(opt.nb_points) .. " points")
print("At initialisation : Train / Test")
print(tostring(train_y[1]) .. " / " .. tostring(test_y[1]) )
print("Training loss:")
print(renormed_train[renormed_train:size(1)])
print("Testing loss:")
print(renormed_test[renormed_test:size(1)])
print("\n\n")

gnuplot.setterm('epslatex')
gnuplot.epsfigure(path_to_output)
gnuplot.raw('set key font ",30')
gnuplot.axis({0, test_val:nElement(),
              opt.ymin, opt.ymax})
gnuplot.xlabel("Nb epochs")
gnuplot.ylabel("Average Normalised score")
gnuplot.plot({'Training', train_x, train_y, 'with lines ls 1 lw 8'},
  {'Testing', test_x, test_y, 'with lines ls 2 lw 8'})
gnuplot.plotflush()
gnuplot.closeall()


local path_to_png_output = string.gsub(path_to_output, ".eps", ".png")
gnuplot.setterm('pngcairo')
gnuplot.pngfigure(path_to_png_output)
gnuplot.raw('set key font ",30')
gnuplot.axis({0, test_val:nElement(),
              opt.ymin, opt.ymax})
gnuplot.xlabel("Nb epochs")
gnuplot.ylabel("Average Normalised score")
gnuplot.plot({'Training', train_x, train_y, 'with lines ls 1 lw 8'},
  {'Testing', test_x, test_y, 'with lines ls 2 lw 8'})
gnuplot.plotflush()
gnuplot.closeall()
