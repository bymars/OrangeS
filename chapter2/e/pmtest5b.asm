; ===================================================================
; pmtest2.asm
; author: Liu, Linhong
; compile: nasm pmtest2.asm -o pmtest2.com
; ===================================================================

%include "pm.inc"

	org 0100h
	jmp LABEL_BEGIN

[SECTION .gdt]
; GDT
;
LABEL_GDT:		Descriptor	0,		0,			0
LABEL_DESC_NORMAL:	Descriptor	0,		0ffffh,			DA_DRW
LABEL_DESC_CODE32:	Descriptor	0,		SegCode32Len-1, 	DA_C+DA_32
LABEL_DESC_CODE16:	Descriptor	0,		0ffffh,			DA_C
LABEL_DESC_CODE_DEST:	Descriptor	0,		SegCodeDestLen-1, 	DA_C+DA_32
LABEL_DESC_CODE_RING3:	Descriptor	0,		SegCodeRing3Len-1, 	DA_C+DA_32+DA_DPL3
LABEL_DESC_DATA:	Descriptor	0,		DataLen-1,		DA_DRW
LABEL_DESC_STACK:	Descriptor	0,		TopOfStack,		DA_DRWA+DA_32
LABEL_DESC_STACK3:	Descriptor	0, 		TopOfStack3,		DA_DRWA+DA_32+DA_DPL3
LABEL_DESC_LDT:		Descriptor	0,		LDTLen - 1,		DA_LDT
LABEL_DESC_TSS:		Descriptor	0,		TSSLen-1,		DA_386TSS
LABEL_DESC_VIDEO:	Descriptor	0B8000h,	0ffffh,			DA_DRW+DA_DPL3

; GATE
LABEL_CALL_GATE_TEST: Gate SelectorCodeDest, 0, 0, DA_386CGate+DA_DPL3
; END of GDT

GdtLen		equ 	$ - LABEL_GDT
GdtPtr		dw	GdtLen - 1
		dd	0

; GDT Selector
SelectorNormal	equ LABEL_DESC_NORMAL	- LABEL_GDT
SelectorCode32 	equ LABEL_DESC_CODE32 	- LABEL_GDT
SelectorCode16	equ LABEL_DESC_CODE16	- LABEL_GDT
SelectorCodeDest equ LABEL_DESC_CODE_DEST - LABEL_GDT
SelectorCodeRing3 equ LABEL_DESC_CODE_RING3 - LABEL_GDT + SA_RPL3
SelectorData	equ LABEL_DESC_DATA	- LABEL_GDT
SelectorStack	equ LABEL_DESC_STACK	- LABEL_GDT
SelectorStack3 	equ LABEL_DESC_STACK3	- LABEL_GDT + SA_RPL3
SelectorLDT	equ LABEL_DESC_LDT	- LABEL_GDT
SelectorTSS	equ LABEL_DESC_TSS	- LABEL_GDT
SelectorVideo	equ LABEL_DESC_VIDEO	- LABEL_GDT
SelectorCallGateTest	equ	LABEL_CALL_GATE_TEST - LABEL_GDT
; END of [SECTION .gdt]

[SECTION .data1]
ALIGN	32
[BITS	32]
LABEL_DATA:
SPValueInRealMode	dw	0
; string
PMMessage:		db	"In Protect Mode now. ^-^", 0
OffsetPMMessage		equ	PMMessage - $$
StrTest:		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest		equ	StrTest - $$
DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]

; globol stack
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ $ - LABEL_STACK -1
; END of [SECTION .gs]

; ring3 stack
[SECTION .s3]
ALIGN 	32
[BITS	32]
LABEL_STACK3:
	times 512 db 0
TopOfStack3 equ $ - LABEL_STACK3 - 1
; END of [SECTION .s3]

; TSS
[SECTION .tss]
ALIGN	32
[BITS	32]
LABEL_TSS:
	DD	0		; Back
	DD	TopOfStack	; ring 0 stack
	DD	SelectorStack
	DD	0		; ring 1 stack
	DD	0
	DD	0		; ring 2 stack
	DD	0		
	DD	0		; CR3
	DD	0		; EIP
	DD	0		; EFLAGS
	DD	0		; EAX
	DD	0		; ECX
	DD      0               ; EDX
        DD      0               ; EBX
        DD      0               ; ESP
        DD      0               ; EBP
        DD      0               ; ESI
        DD      0               ; EDI
        DD      0               ; ES
        DD      0               ; CS
        DD      0               ; SS
        DD      0               ; DS
        DD      0               ; FS
        DD      0               ; GS
        DD      0               ; LDT
        DW      0               ; TRIP DEBUG
	DW	$ - LABEL_TSS + 2 ; base of I/O BITMAP
	DB	0ffh		;  end of I/O BITMAP
TSSLen	equ	$ - LABEL_TSS
; END of [SECTION .tss]

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	mov [LABEL_GO_BACK_TO_REAL + 3], ax
	mov [SPValueInRealMode], sp

	; init code 16 segment
	;                  low  -- ---- -- ---- --- high
	;                    |- base - | |limit| |type|
	; LABEL_DESC_CODE16   HGFE 0000   00000    000   H
	; EAX 0xABCDEFGH  high -- low
	; mov word [.. + 2], ax EFGH -> ...
	; shr eax, 16   al:CD ah:AB 
	mov ax, cs
	movzx	eax, ax
	shl eax, 4
	add eax, LABEL_SEG_CODE16
	mov word [LABEL_DESC_CODE16 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE16 + 4], al
	mov byte [LABEL_DESC_CODE16 + 7], ah

	; init code 32 segment
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE32
	mov word [LABEL_DESC_CODE32 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE32 + 4], al
	mov byte [LABEL_DESC_CODE32 + 7], ah

	; init code for test gate
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE_DEST
	mov word [LABEL_DESC_CODE_DEST + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE_DEST + 4], al
	mov byte [LABEL_DESC_CODE_DEST + 7], ah

	; init data segment
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_DATA
	mov word [LABEL_DESC_DATA + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_DATA + 4], al
	mov byte [LABEL_DESC_DATA + 7], ah
	
	; init stack segment
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_STACK
	mov word [LABEL_DESC_STACK + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_STACK + 4], al
	mov byte [LABEL_DESC_STACK + 7], ah

	; init ring3 stack segment
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_STACK3
	mov word [LABEL_DESC_STACK3 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_STACK3 + 4], al
	mov byte [LABEL_DESC_STACK3 + 7], ah

	; init ldt segment
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_LDT
	mov word [LABEL_DESC_LDT + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_LDT + 4], al
	mov byte [LABEL_DESC_LDT + 7], ah

	; init codea segment in ldt
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_CODE_A
	mov word [LABEL_LDT_DESC_CODEA + 2], ax
	shr eax, 16
	mov byte [LABEL_LDT_DESC_CODEA + 4], al
	mov byte [LABEL_LDT_DESC_CODEA + 7], ah

	; init ring3 segment
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_CODE_RING3
	mov [LABEL_DESC_CODE_RING3 + 2], ax
	shr eax, 16
	mov [LABEL_DESC_CODE_RING3 + 4], al
	mov [LABEL_DESC_CODE_RING3 + 7], ah

	; init tss descriptor
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_TSS
	mov [LABEL_DESC_TSS + 2], ax
	shr eax, 16
	mov [LABEL_DESC_TSS + 4], al
	mov [LABEL_DESC_TSS + 7], ah

	; prepare gdt
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_GDT
	mov dword [GdtPtr + 2], eax

	; load gdtr
	lgdt	[GdtPtr]

	; close interrupt
	cli

	; open addr A20
	in al, 92h
	or al, 00000010b
	out 92h, al

	;prepare to switch
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	; jump to protect mode
	jmp dword SelectorCode32:0


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
LABEL_REAL_ENTRY:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax

	mov sp, [SPValueInRealMode]
	
	in al, 92h
	and al, 11111101b
	out 92h, al
	
	sti

	mov ax, 4c00h
	int 21h	
; END of [SECTION .s16]

[SECTION .s32]
[BITS	32]

LABEL_SEG_CODE32:
	mov ax, SelectorData
	mov ds, ax
	mov ax, SelectorVideo
	mov gs, ax

	mov ax, SelectorStack
	mov ss, ax
	
	mov esp, TopOfStack

	; show the string
	mov ah, 0Ch
	xor esi, esi
	xor edi, edi
	mov esi, OffsetPMMessage
	mov edi, (80 * 10 + 0) * 2
	cld
	
.1:
	lodsb
	test	al, al
	jz .2
	mov [gs:edi], ax
	add edi, 2
	jmp .1
.2:
	call DispReturn

	mov 	ax, SelectorTSS
	ltr	ax

	push	SelectorStack3
	push	TopOfStack3
	push	SelectorCodeRing3
	push	0
	retf

;	call SelectorCodeDest:0
	call SelectorCallGateTest:0

	; load LDT
	mov ax, SelectorLDT
	lldt	ax

	; end
	jmp SelectorLDTCodeA:0

DispReturn:
	push	eax
	push	ebx
	mov	eax, edi
	mov 	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop ebx
	pop eax

	ret

SegCode32Len	equ $ - LABEL_SEG_CODE32 
;END of [SECTION .32]

[SECTION .sdest]
[BITS	32]

LABEL_SEG_CODE_DEST:
	;jmp	$
	mov ax, SelectorVideo
	mov gs, ax
	
	mov edi, (80 * 12 + 0) * 2
	mov ah, 0Ch
	mov al, 'C'
	mov [gs:edi], ax

	mov ax, SelectorLDT
	lldt ax
	
	jmp SelectorLDTCodeA:0
;	retf

SegCodeDestLen	equ $ - LABEL_SEG_CODE_DEST
;END of [SECTION .sdest]

[SECTION .s16code]
ALIGN	32
[BITS	16]
LABEL_SEG_CODE16:
	; jmp back
	mov ax, SelectorNormal
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov eax, cr0
	and al, 11111110b
	mov cr0, eax

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY

Code16Len	equ $ - LABEL_SEG_CODE16
; END of [SECTION .s16code]

; LDT
[SECTION .ldt]
ALIGN	32
LABEL_LDT:
LABEL_LDT_DESC_CODEA:	Descriptor	0, CodeALen - 1, DA_C + DA_32
LDTLen	equ $ - LABEL_LDT

SelectorLDTCodeA	equ LABEL_LDT_DESC_CODEA - LABEL_LDT + SA_TIL
; END of [SECTION .ldt]

; CodeA
[SECTION .la]
ALIGN 	32
[BITS	32]
LABEL_CODE_A:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, (80 * 13 + 0) * 2
	mov ah, 0Ch
	mov al, 'L'
	mov [gs:edi], ax

	jmp SelectorCode16:0
CodeALen	equ $- LABEL_CODE_A
; END of [SECTION .la]

; Code Ring3
[SECTION .ring3]
ALIGN 	32
[BITS	32]
LABEL_CODE_RING3:
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, (80 * 14 + 0) * 2
	mov ah, 0Ch
	mov al, '3'
	mov [gs:edi], ax

	call SelectorCallGateTest:0

	jmp $
SegCodeRing3Len	equ $ - LABEL_CODE_RING3
; END of [SECTION .ring3]
