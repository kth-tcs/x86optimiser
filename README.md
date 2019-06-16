<h3> Project Part 1: Super_Optimization Algorithm </h3>
<strong>Step 1.</strong> You will need docker installed on your system either Linux or Ubuntu. Latest version can be found here: https://www.docker.com/get-started

<strong>Step 2.</strong> You will need to ssh to the latest image of the stoke project. For this you first need to pull the image from the server which can be done as:
   ```
    sudo docker pull stanfordpl/stoke:latest
   ```
<strong>Step 3.</strong> This will pull the latest images from the already published contents for the stanfordpl project on the server. Then you need to give a name to your container and start run.
    ```
    sudo docker run -d -P --name yourownname stanfordpl/stoke:latest
    ```
<br></br>    
<strong>Step 4.</strong> Then you can SSH to the container as: This will give you output for port number XXXXX
   
  ```
  sudo docker port yourownname 22
  ```
<br> </br>
<strong>Step 5.</strong> 
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

  
-<strong>Examples on Assembly codes</strong><ul>1. https://www.nasm.us/doc/nasmdoc2.html#section-2.1.23</ul>
                          <ol>2. https://www3.nd.edu/~dthain/courses/cse40243/fall2015/intel-intro.html</ol> 
                          <ol>3. https://www.imada.sdu.dk/~kslarsen/dm546/Material/IntelnATT.html </ol>
                         <ol>4. https://github.com/Dman95/SASM/issues </ol>
                          <ol>5. www.rosettacode.org</ol>
  <br>
  
  </br>
-<h2>Some Instructions on assembly codes</h2>
  
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
   Output file can be given in any of the formats supported by nasm. Complete list of commands for testing and results can be found on this link: <br></br>
   https://www.nasm.us/doc/nasmdoc2.html#section-2.1.23
   
   If you happen to have gcc and want to test your code, run:
   ```
   nm hello.o
   
   ```
   This will give you a run time analysis of the executed code snippets.
   
   
   
   

 <h2>The output for the Stoke search Result sample</h2>  
   Things to note: The Statistics update and the progress update are the two types of results. The progress update will give you the lowest cost result whereas the Statistics update will give you the Result table. Finally run make check and test time ./a.out to see actually whether optimisation is successful.
   <br>
   
   </br>
   
   <strong>The Result is stored in resulttext.txt</strong><br></br>
   <strong>Explanation is stored in explanation.txt</strong>
   
   <strong><h>OPTIMISATIONS</strong></h>
   <ol>1.  -O0 This level (that is the letter "O" followed by a zero) turns off optimization entirely and is the default if no -O level is specified in CFLAGS or CXXFLAGS. This reduces compilation time and can improve debugging info, but some applications will not work properly without optimization enabled. This option is not recommended except for debugging purposes</ol><br></br>
   
   <ol>2. -O1 the most basic optimization level. The compiler will try to produce faster, smaller code without taking much compilation time. It is basic, but it should get the job done all the time.</ol><br></br>
   
   <ol>3. -O2 A step up from -O1. The recommended level of optimization unless the system has special needs. -O2 will activate a few more flags in addition to the ones activated by -O1. With -O2, the compiler will attempt to increase code performance without compromising on size, and without taking too much compilation time. SSE or AVX may be be utilized at this level but no YMM registers will be used unless -ftree-vectorize is also enabled.</ol><br></br>
   
   <ol>4. -O3 the highest level of optimization possible. It enables optimizations that are expensive in terms of compile time and memory usage. Compiling with -O3 is not a guaranteed way to improve performance, and in fact, in many cases, can slow down a system due to larger binaries and increased memory usage. -O3 is also known to break several packages. Using -O3 is not recommended. However, it also enables -ftree-vectorize so that loops in the code get vectorized and will use AVX YMM registers </ol><br></br>

<h3>Some Useful Repos on Github</h3>
<p><strong>STOKE REPO:</strong>https://github.com/StanfordPL/stoke</p>
<p><strong>SOUPER GOOGLE:</strong>https://github.com/google/souper</p>


<h1>Part 2 of Project</h1>
<h2>Applying Learning Algorithms on Optimiser</h2>

![ML on optimiser](https://user-images.githubusercontent.com/23298265/58791057-cf1e6900-85f1-11e9-85e9-f55baa3babd4.png)


