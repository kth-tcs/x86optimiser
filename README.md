:+1:-**Starting docker container for Stoke Project** 
*( Contents referred from official github page of stoke )*


<strong>Step 1.</strong> You will need docker installed on your system either Linux or Ubuntu. Latest version can be found here: (https://www.docker.com/get-started)

<strong>Step 2.</strong> You will need to ssh to the latest image of the stoke project. For this you first need to pull the image from the server which can be done as:
   ```
    sudo docker pull stanfordpl/stoke:latest
   ```
<strong>Step 3.</strong> This will pull the latest images from the already published contents for the stanfordpl project on the server. Then you need to give a name to your container and start run.
    ```
    sudo docker run -d -P --name yourownname stanfordpl/stoke:latest
    ```
<strong>Step 4.</strong> Then you can SSH to the container as: This will give you output for port number XXXXX
   
  ```
  sudo docker port yourownname 22
  ```
<strong>Step 5.</strong>  Then 
  ```
     ssh -pXXXXX stoke@127.0.0.1
  ```
  Note: Password is stoke
  
<strong>Step 6</strong> (incase you get an error message that your docker container is already running). To stop and remove the docker container follow the steps as below:

```
     docker system prune
     docker system prune --volumes
     sudo docker container ls -a
```
Check for the number of the container and then stop using 

```
   docker stop (number)
   
```

And finally remove it using

``` 
   docker container rm (number)
```
Alternatively you can also make sure that you prune all the volumes by:

```
docker system prune --volumes

```

  
- :+1: <strong>For Assembly codes</strong><ol>https://www.nasm.us/doc/nasmdoc2.html#section-2.1.23</ol>
                          <ol>https://www3.nd.edu/~dthain/courses/cse40243/fall2015/intel-intro.html</ol> 
                          <ol>https://www.imada.sdu.dk/~kslarsen/dm546/Material/IntelnATT.html </ol>
                         <ol>https://github.com/Dman95/SASM/issues </ol>
                          <ol>www.rosettacode.org</ol>
  <br>
  
  </br>
-  :+1:**Instructions on assembly coding**
  
  Step 1: Please use any of the above mentioned methods for compiling your files in the .s format. I would suggest nasm since it is simple to work with on the Linux based Systems and comes with a wide range of applications. 
  
  To compile your code create a asm file and run as follows: 
  ```
  nasm -f elf myfile.asm
  
  ```
  This will help you to assemble your code
  
  Then, 
   
   ```
   nasm -f bin myfile.asm -o myfile.com
   
   ```
   Output file can be given in any of the formats supported by nasm. Complete list of commands for testing and results can be found on this link: 
   (https://www.nasm.us/doc/nasmdoc2.html#section-2.1.23)
   
   If you happen to have gcc and want to test your code, run:
   ```
   nm hello.o
   
   ```
   This will give you a run time analysis of the executed code snippets.
   
   Some Links on Optimisations: 
      <ul>
   
   **PLEASE NOTE: Specify the path to the stoke to get 'stoke' commands in your system. As such:**
   **Further: Also specify the following -Og command for full optimisations on the algorithm in g++**
   
   ```
   $ export PATH=$PATH:/<path_to_stoke>/bin
   $ g++ -std=c++11 -Og -finline-limit=15 main2.cc -o b.out
   
   The optimisations obtained from the above line give 1 magntiude improved time based performance on the timings: 
   
   time ./b.out 1000000
89789
real	0m0.006s
user	0m0.001s
sys	0m0.005s

   
   ```
<br>
</br>
      Links: <ol>https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html</ol>
             <ol>http://www.wisdom.weizmann.ac.il/~ethanf/MCMC/stochastic%20optimization.pdf</ol>
             <ol>http://llvm.org/docs/GettingStarted.html#getting-a-modern-host-c-toolchain</ol>

<br>

</br>

 :+1:  ***The output for the Stoke search Result sample***
   Things to note: The Statistics update and the progress update are the two types of results. The progress update will give you the lowest cost result whereas the Statistics update will give you the Result table. Finally run make check and test time ./a.out to see actually whether optimisation is successful.
   
   
   <strong>The Result is stored in resulttext.txt</strong>
   <strong>Explanation in explanation.txt</strong>
   
   <strong><h>OPTIMISATIONS</strong></h>
   <ol> -O0 This level (that is the letter "O" followed by a zero) turns off optimization entirely and is the default if no -O level is specified in CFLAGS or CXXFLAGS. This reduces compilation time and can improve debugging info, but some applications will not work properly without optimization enabled. This option is not recommended except for debugging purposes</ol>
   <ol> -O1 the most basic optimization level. The compiler will try to produce faster, smaller code without taking much compilation time. It is basic, but it should get the job done all the time.</ol>
   <ol> -O2 A step up from -O1. The recommended level of optimization unless the system has special needs. -O2 will activate a few more flags in addition to the ones activated by -O1. With -O2, the compiler will attempt to increase code performance without compromising on size, and without taking too much compilation time. SSE or AVX may be be utilized at this level but no YMM registers will be used unless -ftree-vectorize is also enabled.</ol>
   <ol> -O3 the highest level of optimization possible. It enables optimizations that are expensive in terms of compile time and memory usage. Compiling with -O3 is not a guaranteed way to improve performance, and in fact, in many cases, can slow down a system due to larger binaries and increased memory usage. -O3 is also known to break several packages. Using -O3 is not recommended. However, it also enables -ftree-vectorize so that loops in the code get vectorized and will use AVX YMM registers </ol>


 ***irrelavant: path to git from source laptop: shrinish@shrinish-Inspiron-13-5378 ── ~/stoke-Superoptimisation/learning-superoptimize ── ‹master*›; and from source PC: shrinish@shrinish-desktop ── ~/branch/learning-superoptimize ── ‹master*› 
 ***



<br>


</br>

<p><strong>STOKE REPO:</strong>https://github.com/StanfordPL/stoke</p>
<p><strong>SOUPER GOOGLE:</strong>https://github.com/google/souper</p>



-----------------------------------------------------PART 2 of Project----------------------------------------------------------------


<h2>Applying ML on Optimiser</h2>

