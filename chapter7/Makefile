###############################################################
# Makefile for Orange'S
# Author: liu, linhong
###############################################################

# This need to be same with 'KernelEntryPointPhyAddr' in load.inc
ENTRYPOINT = 0x30400
# Offset of entry point
ENTRYOFFSET = 0x400

# Programs, flags, etc.
ASM 	= nasm
DASM	= ndisasm
CC	= gcc
LD	= ld
ASMBFLAGS 	= -I boot/include/
ASMKFLAGS	= -I include/ -f elf
CFLAGS		= -I include -c -m32 -fno-builtin -fno-stack-protector
LDFLAGS		= -s -Ttext $(ENTRYPOINT) -m elf_i386
DASMFLAGS	= -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# This Program
ORANGESBOOT 	= boot/boot.bin boot/loader.bin
ORANGESKERNEL	= kernel.bin
OBJS		= kernel/kernel.o kernel/syscall.o kernel/start.o kernel/main.o\
			kernel/clock.o kernel/keyboard.o\
			kernel/i8259.o kernel/global.o kernel/protect.o kernel/proc.o\
			lib/kliba.o lib/klib.o lib/string.o
DASMOUTPUT	= kernel.bin.asm

# ALL Phony Targets
.PHONY : everything final image clean realclean disasm all buildimg

# Default staring position
nop :
	@echo "why not \'make image' huh? :)"
everything : $(ORANGESBOOT) $(ORANGESKERNEL)

all : realclean everything

final: all clean

image : final buildimg

clean :
	rm -f $(OBJS)

realclean :
	rm -f $(OBJS) $(ORANGESBOOT) $(ORANGESKERNEL)

disasm :
	$(DASM) $(DASMFLAGS) $(ORANGESKERNEL) > $(DASMOUTPUT)

# we assume that a.img exists in current floder
buildimg:
	dd if=boot/boot.bin of=a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop a.img /mnt/floppy/
	sudo cp -fv boot/loader.bin /mnt/floppy/
	sudo cp -fv kernel.bin /mnt/floppy/
	sudo umount -l /mnt/floppy/

boot/boot.bin : boot/boot.asm boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/load.inc \
		boot/include/fat12hdr.inc boot/include/pm.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

$(ORANGESKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(ORANGESKERNEL) $(OBJS)

kernel/kernel.o : kernel/kernel.asm include/sconst.inc
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/start.o : kernel/start.c include/type.h include/const.h include/protect.h \
	 include/proto.h include/string.h include/proc.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/main.o : kernel/main.c include/type.h include/const.h include/protect.h \
	include/string.h include/proc.h include/proto.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/i8259.o : kernel/i8259.c include/type.h include/const.h include/protect.h \
	include/proto.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/global.o : kernel/global.c include/type.h include/const.h include/protect.h \
	include/proc.h include/global.h include/proto.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/protect.o : kernel/protect.c include/type.h include/const.h include/protect.h \
	include/proc.h include/proto.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/clock.o : kernel/clock.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/keyboard.o : kernel/keyboard.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/proc.o : kernel/proc.c include/type.h include/const.h include/protect.h \
	include/proc.h include/proto.h include/global.h include/string.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/syscall.o : kernel/syscall.asm include/sconst.inc
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/klib.o : lib/klib.c include/type.h include/const.h include/protect.h include/string.h \
	include/proc.h include/proto.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

lib/kliba.o : lib/kliba.asm include/sconst.inc
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

