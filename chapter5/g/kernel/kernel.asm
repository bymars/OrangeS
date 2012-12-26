; compile:
; $ rm -f kernel.bin
; $ nasm -f elf -o kernel.o kernel.asm
; $ nasm -f elf -o string.o string.asm
; $ nasm -f elf -o klib.o klib.asm
; $ gcc -c -o -m32 start.o start.c
; $ ld -m elf_i386 -s -Ttext 0x30400 -o kernel.bin kernel.o string.o start.o klib.o
; $ rm -f kernel.o string.o start.o

SELECTOR_KERNEL_CS equ 8

; import function
extern cstart
extern gdt_ptr

[SECTION .bss]
StackSpace	resb 2 * 1024
StackTop:
;END of [SECTION .bss]

[section .text] ; code segment

global _start 

_start:

	mov esp, StackTop
	
	sgdt [gdt_ptr]
	call cstart
	lgdt [gdt_ptr]

	; lidt [idt_ptr]

	jmp SELECTOR_KERNEL_CS:csinit
csinit:
	push 0
	popfd

	hlt
