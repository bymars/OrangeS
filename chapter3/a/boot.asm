
;%define	_BOOT_DEGUB_

%ifdef	_BOOT_DEBUG_
	org 0100h
%else
	org 07c00h
%endif

	jmp short LABEL_START
	nop

	; the header of fat12 disk
	BS_OEMName	DB 'ForrestY'		; OEM string 8 Bytes
	BPB_BytsPerSec	DW 512			; Byte of per sector
	BPB_SecPerClus	DB 1			; sector of per cluster
	BPB_RsvdSecCnt	DW 1			; sector number for boot
	BPB_NumFATs	DB 2			; number of fat
	BPB_RootEntCnt	DW 224			; max file number of root dir
	BPB_TotSec16	DW 2880			; total sectors
	BPB_Media	DB 0xF0			; media descriptor
	BPB_FATSz16	DW 9			; sector of per fat
	BPB_SecPerTrk	DW 18			; sector of per track
	BPB_NumHeads	DW 2			; 
	BPB_HiddSec	DD 0			; number of hidden sector
	BPB_TotSec32	DD 0			; 
	BS_DrvNum	DB 0			; dirver number for int 13
	BS_Reserved1	DB 0			; 
	BS_BootSig	DB 29h			; 
	BS_VolID	DD 0			
	BS_VolLab	DB 'OrangeS0.02'	
	BS_FileSysType	DB 'FAT12'		; filesystem type

LABEL_START:
	mov ax, cs
	mov ds, ax
	mov es, ax
	Call	DispStr
	jmp $
DispStr:
	mov ax, BootMessage
	mov bp, ax
	mov cx, 16
	mov ax, 01301h	
	mov bx, 000ch
	mov dl, 0
	int 10h
	ret
BootMessage		db	"Hello, OS world"
times	510 - ($ - $$)	db	0
			dw	0xaa55
