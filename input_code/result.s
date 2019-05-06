  .text
  .globl _Z6popcntm
  .type _Z6popcntm, @function

#! file-offset 0x5f0
#! rip-offset  0x4005f0
#! capacity    48 bytes

# Text                #  Line  RIP       Bytes  Opcode               
._Z6popcntm:          #        0x4005f0  0      OPC=<label>          
  popcntq %rdi, %rax  #  1     0x4005f0  5      OPC=popcntq_r64_r64  
  retq                #  2     0x4005f5  1      OPC=retq             
                                                                     
.size _Z6popcntm, .-_Z6popcntm
	
