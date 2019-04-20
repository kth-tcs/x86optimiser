**Starting docker container for Stoke Project** 
*Contents referred from official github page of stoke*


Step 1. You will need docker installed on your system either Linux or Ubuntu. Latest version can be found here: (https://www.docker.com/get-started)

Step 2. You will need to ssh to the latest image of the stoke project. For this you first need to pull the image from the server which can be done as:
   ```
    sudo docker pull stanfordpl/stoke:latest
   ```
Step 3. This will pull the latest images from the already published contents for the stanfordpl project on the server. Then you need to give a name to your container and start run.
    ```
    sudo docker run -d -P --name yourownname stanfordpl/stoke:latest
    ```
Step 4. Then you can SSH to the container as: This will give you output for port number XXXXX
   
  ```
  sudo docker port yourownname 22
  ```
Step 5.  Then 
  ```
     ssh -pXXXXX stoke@127.0.0.1
  ```
  Note: Password is stoke
  
  **For Assembly codes** :(https://www.nasm.us/doc/nasmdoc2.html#section-2.1.23), 
                          (https://www3.nd.edu/~dthain/courses/cse40243/fall2015/intel-intro.html), 
                          (https://www.imada.sdu.dk/~kslarsen/dm546/Material/IntelnATT.htm),
                          (https://github.com/Dman95/SASM/issues)
                       
  **Instructions on assembly coding**
  
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
   
   ***PLEASE NOTE: Specify the path to the stoke to get 'stoke' commands in your system. As such:***
   
   ```
   $ export PATH=$PATH:/<path_to_stoke>/bin
   
   ```

   ***Explanation for output.tc ***
   
  STOKE uses random search to explore the extremely high-dimensional space of all possible program transformations. For a way to give a backbone to the Stoke Search methods we need to generate a set of test-cases. One of the them is Random Generation and Backtracking. I selected this since it was good head start for someone who is looking to generate their own cases for the algorithm.

The one in the attachment 'output.tc' has generated a similar testcase. The nehalem system ( core i7) has 16 registers from %rax to %r15. The following argument 'testcase' will put random values in registers, and then try to fill in dereferenced memory locations with random values. The function popcntm() gives the number of 1s when set to search the space. The .s program which I have used uses this function. Just that it gives a mangled name to it as _z6popcnt to avoid it's name collision. 

To know the current status of the processor in an intel make, the processors have some flags  for eg. https://www.shsu.edu/~csc_tjm/fall2005/cs272/flags.html. & http://www.c-jump.com/CIS77/ASM/Instructions/I77_0070_eflags_bits.htm. The further flag names such as vm and ac and vif concern with the second link since they do not fall in the category for the flags but qualify as eflags.

The Intel makes (Sandybridge - i5; Haswell - i3 ) make use of AVX (Advanced Vector Extension) instruction set and the registers (YMM0 to YMM15) represent the condition of the registers just before execution of the test. The new make (Nehalem - i7) however, uses the MMX instruction set. The technical data of registers that concerns these systems is generally packed in file format (technical Data) and so the weird extension (output.tc).

Finally the last set of result in output.tc gives a set of valid and invalid contents of flag on stack and heap. Bytes will be segregated in valid and invalid. This brings me to the Final Configuration of the Stoke project. 


