.begin :                      movl esi , esi
movl esi , esi                movl ( r15 , rsi ) , edx  #rsi - 64 bit register
movl ( r15 , rsi ) , edx      addl 4 , esi              #dereference
movl edi , eax                nop (23)           #series of nops happening 23 times
addl 4 , esi                  .begin :
movl edi , edi                movl edi, eax		 #edi - lower 32 bits of rdi	
movl edx , ( r15 , rdi )      movl edi , edi     #edi - destination string
addl 4 , edi                  movl ( r15 , rsi ) , edx
testl edx , edx               shrl 1 , edx
jne . begin                   je . exit             
retq                          movl esi , esi     #esi - source string
							  movl ( r15 , rsi ) , edx
							  addl 4 , esi
							  jmpq . begin
							  nop (31)
							  . exit :
							  retq


#The folloeing is the code for ATT Instruction. The difference is in ATT the first one is source and second is destination
#Whereas in the Intel, First is destination and Second  is source.
# Please read for Information:

	# NaCl requires memory operands to be of the form
# k 1 (%r15,X,k 2 ), where X is a 64-bit register whose
# top 32 bits are cleared by the previous instruction. This
# operand represents accessing memory at address k 1 +
# %r15 + k 2 X. When unspecified, k 1 = 0 and k 2 = 1.

# The notation nop (X) denotes a series of no-
# op instructions occupying X bytes.

# % for registers and $ for immeds
