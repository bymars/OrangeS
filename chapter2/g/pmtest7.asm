; ===================================================================
; pmtest2.asm
; author: Liu, Linhong
; compile: nasm pmtest2.asm -o pmtest2.com
; ===================================================================

%include "pm.inc"

PageDirBase	equ 200000h
PageTblBase	equ 201000h

	org 0100h
	jmp LABEL_BEGIN

[SECTION .gdt]
; GDT
;
LABEL_GDT:		Descriptor	0,		0,		0
LABEL_DESC_NORMAL:	Descriptor	0,		0ffffh,		DA_DRW
LABEL_DESC_PAGE_DIR:	Descriptor	PageDirBase,	4095,		DA_DRW
LABEL_DESC_PAGE_TBL:	Descriptor	PageTblBase, 	4096 * 8 - 1,	DA_DRW
LABEL_DESC_CODE32:	Descriptor	0,		SegCode32Len-1, DA_C+DA_32
LABEL_DESC_CODE16:	Descriptor	0,		0ffffh,		DA_C
LABEL_DESC_DATA:	Descriptor	0,		DataLen-1,	DA_DRW
LABEL_DESC_STACK:	Descriptor	0,		TopOfStack,	DA_DRWA+DA_32
LABEL_DESC_VIDEO:	Descriptor	0B8000h,	0ffffh,		DA_DRW
; END of GDT

GdtLen		equ 	$ - LABEL_GDT
GdtPtr		dw	GdtLen - 1
		dd	0

; GDT Selector
SelectorNormal	equ LABEL_DESC_NORMAL	- LABEL_GDT
SelectorPageDir	equ LABEL_DESC_PAGE_DIR - LABEL_GDT
SelectorPageTbl equ LABEL_DESC_PAGE_TBL - LABEL_GDT
SelectorCode32 	equ LABEL_DESC_CODE32 	- LABEL_GDT
SelectorCode16	equ LABEL_DESC_CODE16	- LABEL_GDT
SelectorData	equ LABEL_DESC_DATA	- LABEL_GDT
SelectorStack	equ LABEL_DESC_STACK	- LABEL_GDT
SelectorVideo	equ LABEL_DESC_VIDEO	- LABEL_GDT
; END of [SECTION .gdt]

[SECTION .data1]
ALIGN	32
[BITS	32]
LABEL_DATA:
; string in real mode
_szPMMessage:		db	"In Protect Mode now. ^_^", 0Ah, 0Ah, 0
_szMemChkTitle:		db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0
_szRAMSize		db	"RAM size:", 0
_szReturn		db	0Ah, 0
; variables in real mode
_wSPValueInRealMode	dw	0
_dwMCRNumber:		dd	0
_dwDispPos:		dd	(80 * 6 + 0) * 2
_dwMemSize:		dd	0
_ARDStruct:	; address range descriptor struct
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0

_MemChkBuf:	times	256	db	0

; symbol in protect mode
szPMMessage	equ	_szPMMessage	- $$
szMemChkTitle	equ	_szMemChkTitle  - $$
szRAMSize	equ	_szRAMSize	- $$
szReturn	equ	_szReturn	- $$
dwDispPos	equ	_dwDispPos	- $$
dwMemSize	equ	_dwMemSize	- $$
dwMCRNumber	equ	_dwMCRNumber	- $$
ARDStruct	equ	_ARDStruct	- $$
	dwBaseAddrLow	equ _dwBaseAddrLow 	- $$
	dwBaseAddrHigh	equ _dwBaseAddrHigh 	- $$
	dwLengthLow	equ _dwLengthLow	- $$
	dwLengthHigh	equ _dwLengthHigh	- $$
	dwType		equ _dwType		- $$
MemChkBuf	equ	_MemChkBuf	- $$

DataLen		equ $ - LABEL_DATA
; END of [SECTION .data1]

; globol stack
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ $ - LABEL_STACK -1
; END of [SECTION .gs]

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	mov [LABEL_GO_BACK_TO_REAL + 3], ax
	mov [_wSPValueInRealMode], sp

	; get number of RAM
	mov ebx, 0
	mov di, _MemChkBuf
.loop:
	mov eax, 0E820h
	mov ecx, 20
	mov edx, 0534D4150h
	int 15h
	jc LABEL_MEM_CHK_FAIL
	add di, 20
	inc dword [_dwMCRNumber]
	cmp ebx, 0
	jne .loop
	jmp LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov dword [_dwMCRNumber], 0
LABEL_MEM_CHK_OK:

	; init code 16 segment
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

	mov sp, [_wSPValueInRealMode]
	
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
	mov ax, SelectorData
	mov es, ax
	mov ax, SelectorVideo
	mov gs, ax

	mov ax, SelectorStack
	mov ss, ax
	
	mov esp, TopOfStack

	; show the string
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4
	
	call	DispMemSize	; show mem info
	
	call	SetupPaging	; setup the page

	; end
	jmp SelectorCode16:0
; start page----------------------------------------------------
SetupPaging:

	; caculate ram size
	xor edx, edx
	mov eax, [dwMemSize]
	mov ebx, 400000h
	div ebx
	mov ecx, eax
	test edx, edx
	jz .no_remainder
	inc ecx
.no_remainder:
	push ecx
	
	; init page dir
	mov ax, SelectorPageDir
	mov es, ax
	xor edi, edi
	xor eax, eax
	mov eax, PageTblBase | PG_P | PG_USU | PG_RWW
.1:
	stosd
	add eax, 4096
	loop .1

	mov ax, SelectorPageTbl
	mov es, ax
	pop eax
	mov ebx, 1024
	mul ebx
	mov ecx, eax
	xor edi, edi
	xor eax, eax
	mov eax, PG_P | PG_USU | PG_RWW
.2:
	stosd
	add eax, 4096
	loop	.2

	mov eax, PageDirBase
	mov cr3, eax
	mov eax, cr0
	or  eax, 80000000h
	mov cr0, eax
	jmp short .3
.3:
	nop

	ret
	; 
; start page complete --------------------------------------------------

DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov 	ecx, [dwMCRNumber]
.loop:
	mov 	edx, 5
	mov	edi, ARDStruct
.1:
	push	dword [esi]
	call 	DispInt
	pop	eax
	stosd
	add	esi, 4
	dec	edx
	cmp	edx, 0
	jnz	.1
	call 	DispReturn
	cmp	dword [dwType], 1
	jne	.2
	mov	eax, [dwBaseAddrLow]
	add	eax, [dwLengthLow]
	cmp	eax, [dwMemSize]
	jb	.2
	mov	[dwMemSize], eax
.2:
	loop	.loop

	call	DispReturn
	push	szRAMSize
	call	DispStr
	add	esp, 4

	push	dword	[dwMemSize]
	call	DispInt
	add	esp, 4

	pop	ecx
	pop	edi
	pop	esi
	ret
%include	"lib.inc"

SegCode32Len	equ $ - LABEL_SEG_CODE32 
;END of [SECTION .32]

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
	and eax, 7FFFFFFEh
	mov cr0, eax

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY

Code16Len	equ $ - LABEL_SEG_CODE16
; END of [SECTION .s16code]



