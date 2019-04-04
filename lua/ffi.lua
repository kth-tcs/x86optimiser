local ffi = require 'ffi'
local torch = require 'torch'


ffi.cdef[[
// Functions to control the signal handler
  typedef void (*sighandler_t)(int signum);
  sighandler_t signal(int signum, sighandler_t handler);

// Stoke stuff (paste the .h content here)
  typedef struct iter_data {
  float score_before;
  float score_after;
  float proposal_proba_unlearned;
  int instr_picked;
  int move_picked;
  int* instr_normalising;
  int nb_instr_normalising;
  bool accepted;
  bool is_invalid;
  } iter_data;

  void slave_init(const char *path_to_in_file,
                  const char *path_to_out_file,
                  const char *path_to_test_file,
                  const char *path_to_target_func,
                  void **search_container,
                  THIntTensor *bag_of_words);

  void clear(void **search_container);

  void run(void **search_container,
  float *move_proba, int move_proba_size,
  float *inst_proba, int inst_proba_size,
  int nb_iter, int update_proposal_distribution,
  // outputs
  float *final_reward,
  iter_data **MCMC_history, int *MCMC_history_size);

  int nb_possible_instruction();

  int get_score(void **search_container);

  void randomly_generate_stuff(float *inst_proba, int inst_proba_size);
 ]]
ffi.load_stoke = function(path_to_lib)
  ffi.load("src/ext/cvc4-1.4-build/lib/libcvc4.so.3", true)
  ffi.load("boost_system", true)
  ffi.C = ffi.load(path_to_lib)
end

local sigint_callback = ffi.cast('sighandler_t', function(signal)
                                   ffi.sigint_handler_restore()
                                   error("Why did you killed me? :'(")
end)

local old_sig_handler
ffi.sigint_handler_fix = function()
  -- 2 = SIGINT
  old_sig_handler = ffi.C.signal(2, sigint_callback)
end
ffi.sigint_handler_restore = function()
  ffi.C.signal(2, old_sig_handler)
end

return ffi
