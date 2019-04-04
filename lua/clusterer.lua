local clusterer = {}

local Clusterer = torch.class('Clusterer', clusterer)


function Clusterer:__init(target_filename, max_instructions)
  self.counts_accepted = {}
  self.max_instructions = max_instructions
  self.target_filename = target_filename
end


function Clusterer:collect_trace(mcmc_history, mcmc_history_size)
  for i=0, mcmc_history_size -1 do
    if mcmc_history[i].accepted then
      local instr_picked = mcmc_history[i].instr_picked
      if instr_picked <= self.max_instructions then
        if self.counts_accepted[instr_picked] then
          self.counts_accepted[instr_picked] = self.counts_accepted[instr_picked] + 1
        else
          self.counts_accepted[instr_picked] = 1
        end
      end
    end
  end
end


function Clusterer:dump_clusters_on_off()
  local  target_file = io.open(self.target_filename, 'w')
  for instr_picked, count in pairs(self.counts_accepted)  do
    target_file:write(instr_picked, "\t", count, "\n")
  end
  target_file:close()
end

return clusterer
