#! file-offset 0x580
#! rip-offset  0x400580
#! capacity    48 bytes

# Text              #  Line  RIP       Bytes  Opcode             
._Z6popcntm:        #        0x400580  0      OPC=<label>        
  testq %rdi, %rdi  #  1     0x400580  3      OPC=testq_r64_r64  
  je .L_40059f      #  2     0x400583  2      OPC=je_label       
  xorl %eax, %eax   #  3     0x400585  2      OPC=xorl_r32_r32   
  nop               #  4     0x400587  1      OPC=nop            
  nop               #  5     0x400588  1      OPC=nop            
  nop               #  6     0x400589  1      OPC=nop            
  nop               #  7     0x40058a  1      OPC=nop            
  nop               #  8     0x40058b  1      OPC=nop            
  nop               #  9     0x40058c  1      OPC=nop            
  nop               #  10    0x40058d  1      OPC=nop            
  nop               #  11    0x40058e  1      OPC=nop            
  nop               #  12    0x40058f  1      OPC=nop            
.L_400590:          #        0x400590  0      OPC=<label>        
  movl %edi, %edx   #  13    0x400590  2      OPC=movl_r32_r32   
  andl $0x1, %edx   #  14    0x400592  3      OPC=andl_r32_imm8  
  addl %edx, %eax   #  15    0x400595  2      OPC=addl_r32_r32   
  shrq $0x1, %rdi   #  16    0x400597  3      OPC=shrq_r64_one   
  jne .L_400590     #  17    0x40059a  2      OPC=jne_label      
  cltq              #  18    0x40059c  2      OPC=cltq           
  retq              #  19    0x40059e  1      OPC=retq           
.L_40059f:          #        0x40059f  0      OPC=<label>        
  xorl %eax, %eax   #  20    0x40059f  2      OPC=xorl_r32_r32   
  retq              #  21    0x4005a1  1      OPC=retq           
  nop               #  22    0x4005a2  1      OPC=nop            
  nop               #  23    0x4005a3  1      OPC=nop            
  nop               #  24    0x4005a4  1      OPC=nop            
  nop               #  25    0x4005a5  1      OPC=nop            
  nop               #  26    0x4005a6  1      OPC=nop            
  nop               #  27    0x4005a7  1      OPC=nop            
  nop               #  28    0x4005a8  1      OPC=nop            
  nop               #  29    0x4005a9  1      OPC=nop            
  nop               #  30    0x4005aa  1      OPC=nop            
  nop               #  31    0x4005ab  1      OPC=nop            
  nop               #  32    0x4005ac  1      OPC=nop            
  nop               #  33    0x4005ad  1      OPC=nop            
  nop               #  34    0x4005ae  1      OPC=nop            
  nop               #  35    0x4005af  1      OPC=nop            

.size _Z6popcntm, .-_Z6popcntm

