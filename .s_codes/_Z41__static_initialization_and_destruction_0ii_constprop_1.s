#_Z41__static_initialization_and_destruction_0ii_constprop_1.s 
  .text
  .globl _Z41__static_initialization_and_destruction_0ii_constprop_1
  .type _Z41__static_initialization_and_destruction_0ii_constprop_1, @function

#! file-offset 0x770
#! rip-offset  0x400770
#! capacity    48 bytes

# Text                                                         #  Line  RIP       Bytes  Opcode              
._Z41__static_initialization_and_destruction_0ii_constprop_1:  #        0x400770  0      OPC=<label>         
  subq $0x8, %rsp                                              #  1     0x400770  4      OPC=subq_r64_imm8   
  movl $0x601191, %edi                                         #  2     0x400774  5      OPC=movl_r32_imm32  
  callq ._ZNSt8ios_base4InitC1Ev_plt                           #  3     0x400779  5      OPC=callq_label     
  movl $0x601068, %edx                                         #  4     0x40077e  5      OPC=movl_r32_imm32  
  movl $0x601191, %esi                                         #  5     0x400783  5      OPC=movl_r32_imm32  
  movl $0x400730, %edi                                         #  6     0x400788  5      OPC=movl_r32_imm32  
  addq $0x8, %rsp                                              #  7     0x40078d  4      OPC=addq_r64_imm8   
  jmpq .__cxa_atexit_plt                                       #  8     0x400791  5      OPC=jmpq_label_1    
  nop                                                          #  9     0x400796  1      OPC=nop             
  nop                                                          #  10    0x400797  1      OPC=nop             
  nop                                                          #  11    0x400798  1      OPC=nop             
  nop                                                          #  12    0x400799  1      OPC=nop             
  nop                                                          #  13    0x40079a  1      OPC=nop             
  nop                                                          #  14    0x40079b  1      OPC=nop             
  nop                                                          #  15    0x40079c  1      OPC=nop             
  nop                                                          #  16    0x40079d  1      OPC=nop             
  nop                                                          #  17    0x40079e  1      OPC=nop             
  nop                                                          #  18    0x40079f  1      OPC=nop             
                                                                                                             
.size _Z41__static_initialization_and_destruction_0ii_constprop_1, .-_Z41__static_initialization_and_destruction_0ii_constprop_1
