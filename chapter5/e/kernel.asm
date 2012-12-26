; compile:
; $ nasm -f elf kernel.asm -o kernel.o
; $ ld -m elf_i386 kernel.o -o kernel.bin

[section .text] ; code segment

global _start 

_start:
	mov ah, 0Fh
	mov al, 'K'
	mov [gs:(80 * 1 + 39) * 2], ax
	jmp $
