  .text
  .globl _Z5saxpyjPjS_i
  .type _Z5saxpyjPjS_i, @function

#! file-offset 0x7f0
#! rip-offset  0x4007f0
#! capacity    272 bytes

# Text                      #  Line  RIP       Bytes  Opcode              
._Z5saxpyjPjS_i:            #        0x4007f0  0      OPC=<label>         
  pushq %rbp                #  1     0x4007f0  1      OPC=pushq_r64_1     
  movq %rsp, %rbp           #  2     0x4007f1  3      OPC=movq_r64_r64    
  movl %edi, -0x4(%rbp)     #  3     0x4007f4  3      OPC=movl_m32_r32    
  movq %rsi, -0x10(%rbp)    #  4     0x4007f7  4      OPC=movq_m64_r64    
  movq %rdx, -0x18(%rbp)    #  5     0x4007fb  4      OPC=movq_m64_r64    
  movl %ecx, -0x1c(%rbp)    #  6     0x4007ff  3      OPC=movl_m32_r32    
  movl -0x1c(%rbp), %ecx    #  7     0x400802  3      OPC=movl_r32_m32    
  addl $0x0, %ecx           #  8     0x400805  6      OPC=addl_r32_imm32  
  movslq %ecx, %rdx         #  9     0x40080b  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  10    0x40080e  4      OPC=movq_r64_m64    
  movl (%rsi,%rdx,4), %ecx  #  11    0x400812  3      OPC=movl_r32_m32    
  imull -0x4(%rbp), %ecx    #  12    0x400815  4      OPC=imull_r32_m32   
  movl -0x1c(%rbp), %edi    #  13    0x400819  3      OPC=movl_r32_m32    
  addl $0x0, %edi           #  14    0x40081c  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  15    0x400822  3      OPC=movslq_r64_r32  
  movq -0x18(%rbp), %rsi    #  16    0x400825  4      OPC=movq_r64_m64    
  addl (%rsi,%rdx,4), %ecx  #  17    0x400829  3      OPC=addl_r32_m32    
  movl -0x1c(%rbp), %edi    #  18    0x40082c  3      OPC=movl_r32_m32    
  addl $0x0, %edi           #  19    0x40082f  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  20    0x400835  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  21    0x400838  4      OPC=movq_r64_m64    
  movl %ecx, (%rsi,%rdx,4)  #  22    0x40083c  3      OPC=movl_m32_r32    
  movl -0x1c(%rbp), %ecx    #  23    0x40083f  3      OPC=movl_r32_m32    
  addl $0x1, %ecx           #  24    0x400842  6      OPC=addl_r32_imm32  
  movslq %ecx, %rdx         #  25    0x400848  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  26    0x40084b  4      OPC=movq_r64_m64    
  movl (%rsi,%rdx,4), %ecx  #  27    0x40084f  3      OPC=movl_r32_m32    
  imull -0x4(%rbp), %ecx    #  28    0x400852  4      OPC=imull_r32_m32   
  movl -0x1c(%rbp), %edi    #  29    0x400856  3      OPC=movl_r32_m32    
  addl $0x1, %edi           #  30    0x400859  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  31    0x40085f  3      OPC=movslq_r64_r32  
  movq -0x18(%rbp), %rsi    #  32    0x400862  4      OPC=movq_r64_m64    
  addl (%rsi,%rdx,4), %ecx  #  33    0x400866  3      OPC=addl_r32_m32    
  movl -0x1c(%rbp), %edi    #  34    0x400869  3      OPC=movl_r32_m32    
  addl $0x1, %edi           #  35    0x40086c  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  36    0x400872  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  37    0x400875  4      OPC=movq_r64_m64    
  movl %ecx, (%rsi,%rdx,4)  #  38    0x400879  3      OPC=movl_m32_r32    
  movl -0x1c(%rbp), %ecx    #  39    0x40087c  3      OPC=movl_r32_m32    
  addl $0x2, %ecx           #  40    0x40087f  6      OPC=addl_r32_imm32  
  movslq %ecx, %rdx         #  41    0x400885  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  42    0x400888  4      OPC=movq_r64_m64    
  movl (%rsi,%rdx,4), %ecx  #  43    0x40088c  3      OPC=movl_r32_m32    
  imull -0x4(%rbp), %ecx    #  44    0x40088f  4      OPC=imull_r32_m32   
  movl -0x1c(%rbp), %edi    #  45    0x400893  3      OPC=movl_r32_m32    
  addl $0x2, %edi           #  46    0x400896  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  47    0x40089c  3      OPC=movslq_r64_r32  
  movq -0x18(%rbp), %rsi    #  48    0x40089f  4      OPC=movq_r64_m64    
  addl (%rsi,%rdx,4), %ecx  #  49    0x4008a3  3      OPC=addl_r32_m32    
  movl -0x1c(%rbp), %edi    #  50    0x4008a6  3      OPC=movl_r32_m32    
  addl $0x2, %edi           #  51    0x4008a9  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  52    0x4008af  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  53    0x4008b2  4      OPC=movq_r64_m64    
  movl %ecx, (%rsi,%rdx,4)  #  54    0x4008b6  3      OPC=movl_m32_r32    
  movl -0x1c(%rbp), %ecx    #  55    0x4008b9  3      OPC=movl_r32_m32    
  addl $0x3, %ecx           #  56    0x4008bc  6      OPC=addl_r32_imm32  
  movslq %ecx, %rdx         #  57    0x4008c2  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  58    0x4008c5  4      OPC=movq_r64_m64    
  movl (%rsi,%rdx,4), %ecx  #  59    0x4008c9  3      OPC=movl_r32_m32    
  imull -0x4(%rbp), %ecx    #  60    0x4008cc  4      OPC=imull_r32_m32   
  movl -0x1c(%rbp), %edi    #  61    0x4008d0  3      OPC=movl_r32_m32    
  addl $0x3, %edi           #  62    0x4008d3  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  63    0x4008d9  3      OPC=movslq_r64_r32  
  movq -0x18(%rbp), %rsi    #  64    0x4008dc  4      OPC=movq_r64_m64    
  addl (%rsi,%rdx,4), %ecx  #  65    0x4008e0  3      OPC=addl_r32_m32    
  movl -0x1c(%rbp), %edi    #  66    0x4008e3  3      OPC=movl_r32_m32    
  addl $0x3, %edi           #  67    0x4008e6  6      OPC=addl_r32_imm32  
  movslq %edi, %rdx         #  68    0x4008ec  3      OPC=movslq_r64_r32  
  movq -0x10(%rbp), %rsi    #  69    0x4008ef  4      OPC=movq_r64_m64    
  movl %ecx, (%rsi,%rdx,4)  #  70    0x4008f3  3      OPC=movl_m32_r32    
  popq %rbp                 #  71    0x4008f6  1      OPC=popq_r64_1      
  retq                      #  72    0x4008f7  1      OPC=retq            
  nop                       #  73    0x4008f8  1      OPC=nop             
  nop                       #  74    0x4008f9  1      OPC=nop             
  nop                       #  75    0x4008fa  1      OPC=nop             
  nop                       #  76    0x4008fb  1      OPC=nop             
  nop                       #  77    0x4008fc  1      OPC=nop             
  nop                       #  78    0x4008fd  1      OPC=nop             
  nop                       #  79    0x4008fe  1      OPC=nop             
  nop                       #  80    0x4008ff  1      OPC=nop             
                                                                          
.size _Z5saxpyjPjS_i, .-_Z5saxpyjPjS_i

