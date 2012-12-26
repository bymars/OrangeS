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
extern exception_handler

; improt global variables
extern gdt_ptr
extern idt_ptr
extern disp_pos

[SECTION .bss]
StackSpace	resb 2 * 1024
StackTop:
;END of [SECTION .bss]

[section .text] ; code segment

global _start 

global divide_error
global single_step_exception
global nmi
global breakpoint_exception
global overflow
global bounds_check
global inval_opcode
global copr_not_available
global double_fault
global copr_seg_overrun
global inval_tss
global segment_not_present
global stack_exception
global general_protection
global page_fault
global copr_error

_start:

	mov esp, StackTop
	mov dword [disp_pos], 0	
	sgdt [gdt_ptr]
	call cstart
	lgdt [gdt_ptr]

	lidt [idt_ptr]

	jmp SELECTOR_KERNEL_CS:csinit
csinit:
	;jmp $
	ud2
	jmp 0x40:0
;	push 0
;	popfd

	hlt

; exception
divide_error:
	push 0xFFFFFFFF ; no err code
	push 0		; vector_no = 0
	jmp exception
single_step_exception:
	push 0xFFFFFFFF ; no err code
	push 1		; vector_no = 1
	jmp exception
nmi:
	push 0xFFFFFFFF ; no err code
	push 2		; vector_no = 2
	jmp exception
breakpoint_exception:
	push 0xFFFFFFFF ; no err code
	push 3		; vector_no = 3
	jmp exception
overflow:
	push 0xFFFFFFFF ; no err code
	push 4		; vector_no = 4
	jmp exception
bounds_check:
	push 0xFFFFFFFF ; no err code
	push 5		; vector_no = 5
	jmp exception
inval_opcode:
	push 0xFFFFFFFF ; no err code
	push 6		; vector_no = 6
	jmp exception
copr_not_available:
	push 0xFFFFFFFF ; no err code
	push 7		; vector_no = 7
	jmp exception
double_fault:
	push 8		; vector_no = 8
	jmp exception
copr_seg_overrun:
	push 0xFFFFFFFF ; no err code
	push 9		; vector_no = 9
	jmp exception
inval_tss:
	push 10		; vector_no = A
	jmp exception
segment_not_present:
	push 11		; vector_no = B
	jmp exception
stack_exception:
	push 12		; vector_no = C
	jmp exception
general_protection:
	push 13		; vector_no = D
	jmp exception
page_fault:
	push 14		; vector_no = E
	jmp exception
copr_error:
	push 0xFFFFFFFF ; no err code
	push 16		; vector_no = 10h
	jmp exception
exception:
	call exception_handler
	add esp, 4 * 2
	hlt
