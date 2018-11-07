######################
# Makefile for Tinix #
######################


#Entry Point of Tinix
ENTRYPOINT = 0x30400
#Offset of entry point in kernel file
ENTRYOFFSET = 0x400

#Programs, flags...
ASM = nasm
CC = gcc
LD = ld
ASMBFLAGS = -I include/
ASMKFLAGS = -I include/ -f elf
CFLAGS    = -I ./include -c -fno-builtin -m32
LDFLAGS	  = -s -Ttext $(ENTRYPOINT) -m elf_i386
#按照指定平台架构和位数对汇编文件和源代码进行编译

TINIXBOOT   = boot/boot.bin boot/loader.bin
TINIXKERNEL = kernel.bin
OBJS        = kernel/kernel.o kernel/start.o lib/string.o lib/klib.o

# All Phony targets
.PHONY : everything final image clean realclean all buildimg

# Defalut starting position
everything : $(TINIXBOOT) $(TINIXKERNEL)
all : realclean everything
final : all clean
image : final buildimg
clean :
	rm -f $(OBJS)

realclean :
	rm -f $(OBJS) $(TINIXBOOT) $(TINIXKERNEL)

buildimg:
	mount tinix.img /mnt -o loop
	cp -f boot/loader.bin /mnt
	cp -f kernel.bin /mnt
	umount /mnt

boot/boot.bin : boot/boot.asm include/load.inc include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<
boot/loader.bin : boot/loader.asm include/load.inc include/fat12hdr.inc include/pm.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

$(TINIXKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(TINIXKERNEL) $(OBJS)

kernel/kernel.o : kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<
kernel/start.o: kernel/start.c include/type.h include/const.h include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

lib/klib.o : lib/klib.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<
lib/string.o : lib/string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<
