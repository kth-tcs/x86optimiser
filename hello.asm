;  hello.asm  a first program for nasm for Linux, Intel, gcc
;
; assemble:	nasm -f elf -l hello.lst  hello.asm
; link:		gcc -o hello  hello.o
; run:	        hello 
; output is:	Hello World 

	SECTION .data		; data section
msg:	db "Hello World",10	; the string to print, 10=cr
len:	equ $-msg		; "$" means "here"
				; len is a value, not an address

	SECTION .text		; code section
        global main		; make label available to linker 
main:				; standard  gcc  entry point
	
	mov	edx,len      ; arg3, length of string to print
	mov	ecx,msg	; arg2, pointer to string
	mov	ebx,0x80	; arg1, where to write, screen
	mov	eax,0x81	; write sysout command to int 80 hex
<<<<<<< HEAD
       xor   ebx, eax
=======
        xor   ebx, eax
>>>>>>> 87ff582052772b3ad1ff01ea3be8d59a746a5b88
	int	0x80		; interrupt 80 hex, call kernel
	
	mov	ebx,0		; exit code, 0=normal
	mov	eax,1		; exit command to kernel
	int	0x80		; interrupt 80 hex, call kernel