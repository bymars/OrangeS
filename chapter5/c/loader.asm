; ============================================================
; loader.asm
; author: liu, linhong
; ============================================================
org 0100h

BaseOfStack		equ 0100h
BaseOfKernelFile	equ 08000h ; base position of KERNEL.BIN
OffsetOfKernelFile	equ 0h	   ; offset of KERNEL.BIn

	jmp LABEL_START

%include	"fat12hdr.inc"

LABEL_START:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BaseOfStack

	mov dh, 0	; display "Loading  "
	call DispStr

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
	call DispStr
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
	call DispStr

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

DispStr:
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
