; compile:  
; $ rm -f kernel.bin
; $ nasm -f elf -o kernel.o kernel.asm
; $ nasm -f elf -o string.o string.asm
; $ nasm -f elf -o klib.o klib.asm
; $ gcc -c -o -m32 start.o start.c
; $ ld -m elf_i386 -s -Ttext 0x30400 -o kernel.bin kernel.o string.o start.o klib.o
; $ rm -f kernel.o string.o start.o

%include "sconst.inc"

; import function
extern cstart
extern kernel_main
extern spurious_irq
extern exception_handler

; improt global variables
extern gdt_ptr
extern idt_ptr
extern p_proc_ready
extern tss
extern disp_pos

bits 32
[SECTION .bss]
StackSpace	resb 2 * 1024
StackTop:
;END of [SECTION .bss]

[section .text] ; code segment

global _start 

global restart

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
global hwint00
global hwint01
global hwint02
global hwint03
global hwint04
global hwint05
global hwint06
global hwint07
global hwint08
global hwint09
global hwint10
global hwint11
global hwint12
global hwint13
global hwint14
global hwint15

_start:

	mov esp, StackTop
	mov dword [disp_pos], 0	
	sgdt [gdt_ptr]
	call cstart
	lgdt [gdt_ptr]

	lidt [idt_ptr]

	jmp SELECTOR_KERNEL_CS:csinit
csinit:
;	sti

	xor eax, eax
	mov ax, SELECTOR_TSS
	ltr ax

	jmp kernel_main
;	hlt

; interrupt
; ------------------------------------
%macro hwint_master 1
	push %1
	call spurious_irq
	add esp, 4
	hlt
%endmacro
; ------------------------------------
ALIGN	16
hwint00:
	sub esp, 4
	pushad
	push ds
	push es
	push fs
	push gs
	mov dx, ss
	mov ds, dx
	mov es, dx

	inc byte [gs:0]

	mov al, EOI
	out INT_M_CTL, al
	
	lea eax, [esp + P_STACKTOP]
	mov dword [tss + TSS3_S_SP0], eax

	pop gs
	pop fs
	pop es
	pop ds
	popad
	add esp, 4

	iretd

ALIGN	16
hwint01:
	hwint_master	1

ALIGN	16
hwint02:
	hwint_master	2

ALIGN	16
hwint03:
	hwint_master	3

ALIGN	16
hwint04:
	hwint_master	4

ALIGN	16
hwint05:
	hwint_master	5

ALIGN	16
hwint06:
	hwint_master	6

ALIGN	16
hwint07:
	hwint_master	7

; ----------------------------
%macro hwint_slave	1
	push %1
	call spurious_irq
	add esp, 4
	hlt
%endmacro
; ----------------------------

ALIGN	16
hwint08:
	hwint_slave	8

ALIGN	16
hwint09:
	hwint_slave	9

ALIGN	16
hwint10:
	hwint_slave	10

ALIGN	16
hwint11:
	hwint_slave	11

ALIGN	16
hwint12:
	hwint_slave	12

ALIGN	16
hwint13:
	hwint_slave	13

ALIGN	16
hwint14:
	hwint_slave	14

ALIGN	16
hwint15:
	hwint_slave	15

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

; =========================================================
;                   restart
; =========================================================
restart:
	mov esp, [p_proc_ready]
	lldt [esp + P_LDT_SEL]
	lea eax, [esp + P_STACKTOP]
	mov dword [tss + TSS3_S_SP0], eax
	
	pop gs
	pop fs
	pop es
	pop ds
	popad

	add esp, 4
	
	iretd
