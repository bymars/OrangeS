; ==========================================================
; pmtest.asm
; author: Liu, Linhong
; compile: nasm pmtest1.asm -o pmtest1.bin
; =========================================================

%include	"pm.inc"

org 0100h
	jmp LABEL_BEGIN

[SECTION .gdt]
; GDT
;					base		limit			property
LABEL_GDT:		Descriptor	0,		0,			0
LABEL_DESC_CODE32:	Descriptor	0,		SegCode32Len - 1,	DA_C + DA_32
LABEL_DESC_VIDEO:	Descriptor	00B8000h,	0ffffh,			DA_DRW
; GDT END

GdtLen		equ	$ - LABEL_GDT
GdtPtr		dw	GdtLen - 1	; limit
		dd	0		; base

; GDT Selector
SelectorCode32	equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO	- LABEL_GDT
; END of [SECTION .gdt]

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	; init 32bit code paragraph descriptor
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE32
	mov word [LABEL_DESC_CODE32 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE32 + 4], al
	mov byte [LABEL_DESC_CODE32 + 7], ah
	
	; prepare load GDTR
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_GDT		; LABEL_GDT is the base addr of gdt
	mov dword [GdtPtr + 2], eax 

	; load GDTR
	lgdt	[GdtPtr]
	
	; close interrupt
	cli

	; open addr bus A20
	in al, 92h
	or al, 00000010b
	out 92h, al

	; prepare to switch to protect mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	; enter protect mode
	jmp dword SelectorCode32:0 	; locd SelectorCode32 to cs
					; and jump to SelectorCode32:0

; END of [SECTION .s16]
[SECTION .s32]
[BITS	32]

LABEL_SEG_CODE32:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, (80 * 11 + 79) * 2
	mov ah, 0Ch
	mov al, 'P'
	mov [gs:edi], ax

	; sotp at here
	jmp $

SegCode32Len	equ $ - LABEL_SEG_CODE32
; END of [SECTION .s32]

