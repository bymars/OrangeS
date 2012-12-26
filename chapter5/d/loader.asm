; ============================================================
; loader.asm
; author: liu, linhong
; ============================================================
org 0100h

	jmp LABEL_START

%include	"fat12hdr.inc"
%include 	"load.inc"
%include	"pm.inc"

; GDT
;                                base           limit             type
LABEL_GDT:		Descriptor 0, 		0, 		0
LABEL_DESC_FLAT_C:	Descriptor 0, 		0fffffh, 	DA_CR|DA_32|DA_LIMIT_4K
LABEL_DESC_FLAT_RW:	Descriptor 0,	 	0fffffh, 	DA_DRW|DA_32|DA_LIMIT_4K
LABEL_DESC_VIDEO:	Descriptor 0B8000h, 	0ffffh, 	DA_DRW|DA_DPL3

GdtLen	equ $ - LABEL_GDT
GdtPtr	dw GdtLen-1
	dd BaseOfLoaderPhyAddr + LABEL_GDT

; GDT selector
SelectorFlatC	equ LABEL_DESC_FLAT_C 	- LABEL_GDT
SelectorFlatRW	equ LABEL_DESC_FLAT_RW	- LABEL_GDT
SelectorVideo	equ LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3


BaseOfStack	equ 0100h
PageDirBase	equ 100000h
PageTblBase	equ 101000h

LABEL_START:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BaseOfStack

	mov dh, 0	; display "Loading  "
	call DispStrRealMode
	
	; get memory information
	mov ebx, 0
	mov di, _MemChkBuf
.MemChkLoop:
	mov eax, 0E820h
	mov ecx, 20
	mov edx, 0534D4150h
	int 15h
	jc .MemChkFail
	add di, 20
	inc dword [_dwMCRNumber]
	cmp ebx, 0
	jne .MemChkLoop
	jmp .MemChkOk
.MemChkFail:
	mov dword [_dwMCRNumber], 0
.MemChkOk:

	; find KERNEL.BIN from root dir
	mov word [wSectorNo], SectorNoOfRootDirectory
	xor ah, ah  ;-|
	xor dl, dl  ; | reset floppy
	int 13h	    ;-|	
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp word [wRootDirSizeForLoop], 0
	jz LABEL_NO_LOADERBIN
	dec word [wRootDirSizeForLoop]
	mov ax, BaseOfKernelFile
	mov es, ax
	mov bx, OffsetOfKernelFile
	mov ax, [wSectorNo]
	mov cl, 1
	call ReadSector

	mov si, KernelFileName
	mov di, OffsetOfKernelFile
	cld
	mov dx, 10h
LABEL_SEARCH_FOR_KERNELBIN:
	cmp dx, 0
	jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec dx
	mov cx, 11
LABEL_CMP_FILENAME:
	cmp cx, 0
	jz LABEL_FILENAME_FOUND
	dec cx
	lodsb
	cmp al, byte [es:di]
	jz LABEL_GO_ON
	jmp LABEL_DIFFERENT

LABEL_GO_ON:
	inc di
	jmp LABEL_CMP_FILENAME

LABEL_DIFFERENT:
	and di, 0FFE0h
	add di, 20h
	mov si, KernelFileName
	jmp LABEL_SEARCH_FOR_KERNELBIN

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add word [wSectorNo], 1
	jmp LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
	mov dh, 2
	call DispStrRealMode
%ifdef	_LOADER_DEBUG_
	mov ax, 4c00h
	int 21h
%else
	jmp $
%endif

LABEL_FILENAME_FOUND:
	mov ax, RootDirSectors
	and di, 0FFE0h

	push eax
	mov eax, [es:di + 01Ch]       ;-|
	mov dword [dwKernelSize], eax ;-| store size of kernel.bin
	pop eax
	
	add di, 01Ah
	mov cx, word [es:di]
	push cx
	add cx, ax
	add cx, DeltaSectorNo
	mov ax, BaseOfKernelFile
	mov es, ax
	mov bx, OffsetOfKernelFile
	mov ax, cx

LABEL_GOON_LOADING_FILE:
	push ax
	push bx
	mov ah, 0Eh
	mov al, '.'
	mov bl, 0Fh
	int 10h
	pop bx
	pop ax
	
	mov cl, 1
	call ReadSector
	pop ax
	call GetFATEntry
	cmp ax, 0FFFh
	jz LABEL_FILE_LOADED
	push ax
	mov dx, RootDirSectors
	add ax, dx
	add ax, DeltaSectorNo
	add bx, [BPB_BytsPerSec]
	jmp LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
	
	call	KillMotor
	
	mov dh, 1	; display "Ready. "
	call DispStrRealMode

	; load GDTR
	lgdt	[GdtPtr]

	; close interrupt
	cli

	; open addr A20
	in al, 92h
	or al, 00000010b
	out 92h, al
	
	; prepare to jump to protect mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	
	;jump to protect mode
	jmp dword SelectorFlatC:(BaseOfLoaderPhyAddr+LABEL_PM_START)	
	
	jmp $

; ====================================================
; variables
; ----------------------------------------------------
wRootDirSizeForLoop	dw RootDirSectors
wSectorNo		dw 0
bOdd			db 0
dwKernelSize		dd 0
; ====================================================
; string
; ----------------------------------------------------
KernelFileName	db "KERNEL  BIN", 0
MessageLength	equ 9
LoadMessage:	db "Loading  "
Message1	db "Ready.   "
Message2	db "NO KERNEL"
; ====================================================

DispStrRealMode:
	mov ax, MessageLength
	mul dh
	add  ax, LoadMessage
	mov bp, ax
	mov ax, ds
	mov es, ax
	mov cx, MessageLength
	mov ax, 01301h	
	mov bx, 0007h
	mov dl, 0
	add dh, 3
	int 10h
	ret

;-----------------------------------------------------------------
; function ReadSector
;-----------------------------------------------------------------
; read sector from ax, read cl number sectors to es:bx
;-----------------------------------------------------------------
ReadSector:
	push bp
	mov bp, sp
	sub esp, 2

	mov byte[bp - 2], cl
	push bx
	mov bl, [BPB_SecPerTrk]
	div bl
	inc ah
	mov cl, ah
	mov dh, al
	shr al, 1
	mov ch, al
	and dh, 1
	pop bx
	
	mov dl, [BS_DrvNum]
.GoOnReading:
	mov ah, 2
	mov al, byte [bp - 2]
	int 13h
	jc .GoOnReading

	add esp, 2
	pop bp

	ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; function GetFATEntry
;--------------------------------------------------------------------
; find the next sector of sector ax by searching fat. result put in ax
;--------------------------------------------------------------------
GetFATEntry:
	push	es
	push	bx
	push	ax
	mov ax, BaseOfKernelFile
	sub ax, 0100h
	mov es, ax
	pop ax
	mov byte [bOdd], 0
	mov bx, 3
	mul bx
	mov bx, 2
	div bx
	cmp dx, 0
	jz LABEL_EVEN
	mov byte [bOdd], 1
LABEL_EVEN:
	xor dx, dx
	mov bx, [BPB_BytsPerSec]
	div bx
	push dx
	mov bx, 0
	add ax, SectorNoOfFAT1
	mov cl, 2
	call ReadSector
	
	pop dx
	add bx, dx
	mov ax, [es:bx]
	cmp byte [bOdd], 1
	jnz LABEL_EVEN_2
	shr ax, 4
LABEL_EVEN_2:
	and ax, 0FFFh

LABEL_GET_FAT_ENTRY_OK:
	pop bx
	pop es
	ret
;---------------------------------------------------------

; ----------------------------------------------------
; killMotor
; ----------------------------------------------------
; close motor of floppy
KillMotor:
	push dx
	mov dx, 03F2h
	mov al, 0
	out dx, al
	pop dx
	ret
; -----------------------------------------------------

[SECTION .s32]
ALIGN 	32
[BITS	32]

LABEL_PM_START:
	mov ax, SelectorVideo
	mov gs, ax
	
	mov ax, SelectorFlatRW
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov ss, ax
	mov esp, TopOfStack

	push szMemChkTitle
	call DispStr
	add esp, 4

	call DispMemInfo
	call SetupPaging

	mov ah, 0Fh
	mov al, 'P'
	mov [gs:((80 * 0 + 39) * 2)], ax
	jmp $

%include "lib.inc"

; display memory information--------------------------------------------------
DispMemInfo:
	push esi
	push edi
	push ecx
	
	mov esi, MemChkBuf
	mov ecx, [dwMCRNumber]
.loop:
	mov edx, 5
	mov edi, ARDStruct
.1:
	push dword [esi]
	call DispInt
	pop eax
	stosd
	add esi, 4
	dec edx
	cmp edx, 0
	jnz .1
	call DispReturn
	cmp dword [dwType], 1
	jne .2
	mov eax, [dwBaseAddrLow]
	add eax, [dwLengthLow]
	cmp eax, [dwMemSize]
	jb .2
	mov [dwMemSize], eax
.2:
	loop	.loop

	call DispReturn
	push szRAMSize
	call DispStr
	add esp, 4
	
	push dword [dwMemSize]
	call DispInt
	add esp, 4
	
	pop ecx
	pop edi
	pop esi
	ret
; ----------------------------------------------------------------------------

; setup paging ---------------------------------------------------------------
SetupPaging:
	; caculate how many page table to allocate
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
	mov ax, SelectorFlatRW
	mov es, ax
	mov edi, PageDirBase
	xor eax, eax
	mov eax, PageTblBase | PG_P | PG_USU | PG_RWW
.1:
	stosd
	add eax , 4096
	loop .1

	;init page table
	pop eax
	mov ebx, 1024
	mul ebx
	mov ecx, eax
	mov edi, PageTblBase
	xor eax, eax
	mov eax, PG_P | PG_USU | PG_RWW
.2:
	stosd
	add eax, 4096
	loop .2

	mov eax, PageDirBase
	mov cr3, eax
	mov eax, cr0
	or eax, 80000000h
	mov cr0, eax
	jmp short .3
.3:
	nop
	
	ret
; ---------------------------------------------------------------------------
; END OF {SECTION .s32}

; ----------------------------------------------------------------------------
[Section .data1]
ALIGN	32

LABEL_DATA:
; symbol in real mode
; string
_szMemChkTitle:	db "BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0
_szRAMSize: 	db "RAM size:", 0
_szReturn: 	db 0Ah, 0
; variables
_dwMCRNumber: 	dd 0
_dwDispPos: 	dd (80 * 6 + 0) * 2
_dwMemSize: 	dd 0
_ARDStruct:
  _dwBaseAddrLow:	dd 0
  _dwBaseAddrHigh:	dd 0
  _dwLengthLow:		dd 0
  _dwLengthHigh:	dd 0
  _dwType:		dd 0
_MemChkBuf: times 256 db 0

; symbol in protect mode
szMemChkTitle	equ BaseOfLoaderPhyAddr + _szMemChkTitle
szRAMSize	equ BaseOfLoaderPhyAddr + _szRAMSize
szReturn	equ BaseOfLoaderPhyAddr + _szReturn
dwDispPos	equ BaseOfLoaderPhyAddr + _dwDispPos
dwMemSize	equ BaseOfLoaderPhyAddr + _dwMemSize
dwMCRNumber	equ BaseOfLoaderPhyAddr + _dwMCRNumber
ARDStruct	equ BaseOfLoaderPhyAddr + _ARDStruct
 dwBaseAddrLow	equ BaseOfLoaderPhyAddr + _dwBaseAddrLow
 dwBaseAddrHigh	equ BaseOfLoaderPhyAddr + _dwBaseAddrHigh
 dwLengthLow	equ BaseOfLoaderPhyAddr + _dwLengthLow
 dwLengthHigh	equ BaseOfLoaderPhyAddr + _dwLengthHigh
 dwType		equ BaseOfLoaderPhyAddr + _dwType
MemChkBuf	equ BaseOfLoaderPhyAddr + _MemChkBuf

; place the stack in the end of data segment
StackSpace: 	times 	1024	db	0
TopOfStack	equ	BaseOfLoaderPhyAddr + $
