all: synth opt time_llvm time_gcc time_stoke

synth: orig_llvm extract testcase search_synth
opt: orig_llvm extract testcase search_opt

time_llvm: orig_llvm time
time_gcc: orig_gcc time
time_stoke: orig_llvm rebuild replace time

orig_llvm:
	clang -std=c++11 -O0 -c fxn.cc
	g++ -std=c++11 -O3 main.cc fxn.o
orig_gcc:
	g++ -std=c++11 -O0 -c fxn.cc
	g++ -std=c++11 -O3 main.cc fxn.o

rebuild:
	rm -f stoke.s
	head -n10 loop.s >> stoke.s	
	tail -n+5 opt_result.s | head -n-3 >> stoke.s
	tail -n8 loop.s >> stoke.s

extract:
	stoke extract --config extract.conf
testcase:
	stoke testcase --config testcase.conf
search_synth:
	time stoke search --config synth.conf
search_opt:
	time stoke search --config opt.conf
replace:
	stoke replace --config replace.conf

time:
	time ./a.out 100000000

clean:
	rm -rf bins ./a.out *.tc *result.s stoke.s *.o

.PHONY: time clean rebuild extract orig_llvm orig_gcc synth opt testcase search_opt search_synth
