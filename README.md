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


