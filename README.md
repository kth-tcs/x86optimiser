**Step 1** (Just as a help for defining opcode.h file for undefined opcodes)

1. Defining your own opcode (https://docs.oracle.com/cd/E16754_01/doc.75/e16702/prg_writing_fm.htm#BRMDR297)

2. Writing perl script for the opcode (https://perldoc.perl.org/Opcode.html)

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


