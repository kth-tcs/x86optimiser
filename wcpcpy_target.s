#target                       #rewrite
.begin :                      movl esi , esi
movl esi , esi                movl ( r15 , rsi ) , edx
movl ( r15 , rsi ) , edx      addl 4 , esi
movl edi , eax                nop (23)
addl 4 , esi                  .begin :
movl edi , edi                movl edi, eax
movl edx , ( r15 , rdi )      movl edi , edi
addl 4 , edi                  movl ( r15 , rsi ) , edx
testl edx , edx               shrl 1 , edx
jne . begin                   je . exit             
retq                          movl esi , esi
			      movl ( r15 , rsi ) , edx
                   	      addl 4 , esi
			      jmpq . begin
			      nop (31)
			      . exit :
			      retq

