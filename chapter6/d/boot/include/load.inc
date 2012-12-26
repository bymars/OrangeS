BaseOfLoader	equ 09000h ; base addr of LOADER.BIN
OffsetOfLoader	equ 0100h ; offset of LOADER.BIN

BaseOfLoaderPhyAddr	equ BaseOfLoader*10h ; physical addr of LOADER.BIN

BaseOfKernelFile	equ 08000h
OffsetOfKernelFile	equ 0h

BaseOfKernelFilePhyAddr	equ BaseOfKernelFile * 10h
KernelEntryPointPhyAddr	equ 030400h

PageDirBase	equ 200000h
PageTblBase	equ 201000h
