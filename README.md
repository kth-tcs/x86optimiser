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

  
- :+1: **For Assembly codes** :--(https://www.nasm.us/doc/nasmdoc2.html#section-2.1.23) <br />
                          --(https://www3.nd.edu/~dthain/courses/cse40243/fall2015/intel-intro.html) <br /> 
                          --(https://www.imada.sdu.dk/~kslarsen/dm546/Material/IntelnATT.htm)<br />
                          --(https://github.com/Dman95/SASM/issues) <br />
                          --(www.rosettacode.org) <br />
  
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
   
   ***PLEASE NOTE: Specify the path to the stoke to get 'stoke' commands in your system. As such:***
   
   ```
   $ export PATH=$PATH:/<path_to_stoke>/bin
   
   ```
<br>
</br>

 :+1:  ***The output for the Stoke search Result sample***
   Things to note: The Statistics update and the progress update are the two types of results. The progress update will give you the lowest cost result whereas the Statistics update will give you the Result table. Finally run make check and test time ./a.out to see actually whether optimisation is successful.
   
   
   ***The Result is stored in resulttext.txt***

 -:+1:  ------->**_Explanation for output.tc_**<------------
   
  STOKE uses random search to explore the extremely high-dimensional space of all possible program transformations. For a way to give a backbone to the Stoke Search methods we need to generate a set of test-cases. One of the them is Random Generation and Backtracking. I selected this since it was good head start for someone who is looking to generate their own cases for the algorithm.

The one in the attachment 'output.tc' has generated a similar testcase. The nehalem system ( core i7) has 16 registers from %rax to %r15. The following argument 'testcase' will put random values in registers, and then try to fill in dereferenced memory locations with random values. The function popcntm() gives the number of 1s when set to search the space. The .s program which I have used uses this function. Just that it gives a mangled name to it as _z6popcnt to avoid it's name collision. 

To know the current status of the processor in an intel make, the processors have some flags  for eg. https://www.shsu.edu/~csc_tjm/fall2005/cs272/flags.html. & http://www.c-jump.com/CIS77/ASM/Instructions/I77_0070_eflags_bits.htm. The further flag names such as vm and ac and vif concern with the second link since they do not fall in the category for the flags but qualify as eflags.

The Intel makes (Sandybridge - i5; Haswell - i3 ) make use of AVX (Advanced Vector Extension) instruction set and the registers (YMM0 to YMM15) represent the condition of the registers just before execution of the test. The new make (Nehalem - i7) however, uses the MMX instruction set. The technical data of registers that concerns these systems is generally packed in file format (technical Data) and so the weird extension (output.tc).

Finally the last set of result in output.tc gives a set of valid and invalid contents of flag on stack and heap. Bytes will be segregated in valid and invalid. This brings me to the Final Configuration of the Stoke project as explained below. 


When STOKE finishes generating the search from the testcases provided it generates a low-cost verified version of the same program. The generated function _Z6popcntm.s which is stored in bins directory is a compiled version of the main.cc and main2.cc programs pushed on Github. To go in-depth, the popcnt function is the function which is used in main.cc and main2.cc programs. It is a built-in function which is used for counting the population of the number of bits. This function was created because it gave a way for optimising the programs for eg. Replacing serial-shifting operation. This is used in operations where large amount of memory is used, to sort the contents and to get a lookup table of the population count.
Link : (https://en.wikichip.org/wiki/population_count)

This program is compiled via g++ and gets stored in a mangled name _Z6popcntm. When _Z6popcntm function is passed as a testcase, i.e after the testcase arg., when we implement (stoke synthesis), we have input target as _Z6popcntm.s, the generated testcases as --testcases and the output in the desired location via -o <path/to/output>.

When the project discovers a low-cost verified rewrite code it will take its output and log under, Progress Update and consequently the statistics table. The replace.conf file can be used for patching the result in the original binary. One more thing to cross verify, the execution time, i.e runtime measurement stats are also several magnitudes lesser than the previous found run-times.
 Command: time ./a.out 1000000 (the last figure is the number of iterations which can be kept constant for comparison

 ***irrelavant: path to git from source laptop: shrinish@shrinish-Inspiron-13-5378 ── ~/stoke-Superoptimisation/learning-superoptimize ── ‹master*›; and from source PC: shrinish@shrinish-desktop ── ~/branch/learning-superoptimize ── ‹master*› 
 ***
