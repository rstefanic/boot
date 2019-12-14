[ORG 0x7c00]

jmp main

%include "bios_print.asm"

main:
	xor ax, ax		; Zero out ax
	mov ds, ax		; move it into DS register
				; ax is zeroed out to ensure ds contains nothing 
				; because we're setting the offset with ORG in NASM

	cld			; clear direction

	mov si, msg
	call bios_print

	mov si, nxt
	call bios_print

hang:
	jmp hang

; db = define bytes (8 bit) in NASM
msg	db 'Boot Successful.', 13, 10, 0
nxt	db 'Now hanging...', 13, 10, 0		

	times 510-($-$$) db 0 	; NASM's way of filling up 510 bytes with zeros
	db 0x55 		; The last two bytes are a boot signature
	db 0xAA			; 	mostly used from older BIOS
