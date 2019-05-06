  .text
  .globl _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc_constprop_2
  .type _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc_constprop_2, @function

#! file-offset 0xa20
#! rip-offset  0x400a20
#! capacity    80 bytes

# Text                                                                                      #  Line  RIP       Bytes  Opcode              
._ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc_constprop_2:                       #        0x400a20  0      OPC=<label>         
  testq %rdi, %rdi                                                                          #  1     0x400a20  3      OPC=testq_r64_r64   
  pushq %rbx                                                                                #  2     0x400a23  1      OPC=pushq_r64_1     
  movq %rdi, %rbx                                                                           #  3     0x400a24  3      OPC=movq_r64_r64    
  je .L_400a48                                                                              #  4     0x400a27  2      OPC=je_label        
  callq ._ZNSt11char_traitsIcE6lengthEPKc                                                   #  5     0x400a29  5      OPC=callq_label     
  movq %rbx, %rsi                                                                           #  6     0x400a2e  3      OPC=movq_r64_r64    
  movq %rax, %rdx                                                                           #  7     0x400a31  3      OPC=movq_r64_r64    
  movl $0x601080, %edi                                                                      #  8     0x400a34  5      OPC=movl_r32_imm32  
  callq ._ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l_plt  #  9     0x400a39  5      OPC=callq_label     
  movl $0x601080, %eax                                                                      #  10    0x400a3e  5      OPC=movl_r32_imm32  
  popq %rbx                                                                                 #  11    0x400a43  1      OPC=popq_r64_1      
  retq                                                                                      #  12    0x400a44  1      OPC=retq            
  nop                                                                                       #  13    0x400a45  1      OPC=nop             
  nop                                                                                       #  14    0x400a46  1      OPC=nop             
  nop                                                                                       #  15    0x400a47  1      OPC=nop             
.L_400a48:                                                                                  #        0x400a48  0      OPC=<label>         
  movq 0x200631(%rip), %rax                                                                 #  16    0x400a48  7      OPC=movq_r64_m64    
  movl $0x1, %esi                                                                           #  17    0x400a4f  5      OPC=movl_r32_imm32  
  movq -0x18(%rax), %rdi                                                                    #  18    0x400a54  4      OPC=movq_r64_m64    
  addq $0x601080, %rdi                                                                      #  19    0x400a58  7      OPC=addq_r64_imm32  
  callq ._ZNSt9basic_iosIcSt11char_traitsIcEE8setstateESt12_Ios_Iostate_plt                 #  20    0x400a5f  5      OPC=callq_label     
  movl $0x601080, %eax                                                                      #  21    0x400a64  5      OPC=movl_r32_imm32  
  popq %rbx                                                                                 #  22    0x400a69  1      OPC=popq_r64_1      
  retq                                                                                      #  23    0x400a6a  1      OPC=retq            
  nop                                                                                       #  24    0x400a6b  1      OPC=nop             
  nop                                                                                       #  25    0x400a6c  1      OPC=nop             
  nop                                                                                       #  26    0x400a6d  1      OPC=nop             
  nop                                                                                       #  27    0x400a6e  1      OPC=nop             
  nop                                                                                       #  28    0x400a6f  1      OPC=nop             
                                                                                                                                          
.size _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc_constprop_2, .-_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc_constprop_2
