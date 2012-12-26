; Header of FAT12 disk
; ------------------------------------------------------------------------
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
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; constant based on fat12 header
; ---------------------------------------------------------------------------
; BPB_FATSz16
FATSz	equ 9

; space of root dir
; RootDirSectors = ((BPB_RootEntCnt*32)+(BPB_BytsPerSec-1))/BPB_BytsPerSec
RootDirSectors	equ	14

; first sector number of root dir 
; SectorNoOfRootDirectory = BPB_RsvdSecCnt + (BPB_NumFATs * FATSz)
SectorNoOfRootDirectory	equ	19

; first sector of FAT1
SectorNoOfFAT1	equ	1

; DeltaSectorNo = BPB_RsvdSecCnt + (BPB_NumFATs * FATSz) - 2
; start sector number of file
DeltaSectorNo	equ 17

