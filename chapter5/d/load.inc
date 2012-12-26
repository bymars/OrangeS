BaseOfLoader	equ 0900h ; base addr of LOADER.BIN
OffsetOfLoader	equ 0100h ; offset of LOADER.BIN

BaseOfLoaderPhyAddr	equ BaseOfLoader*10h ; physical addr of LOADER.BIN

BaseOfKernelFile	equ 0800h
OffsetOfKernelFile	equ 0h
