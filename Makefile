test: build run

build:
	nasm boot.asm -f bin -o boot.bin

run:
	qemu-system-i386 \
	  -drive "file=boot.bin,index=0,media=disk,format=raw"


