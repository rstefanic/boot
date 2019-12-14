[ORG 0x7c00]			; offset directive

jmp main

%include "bios_print.asm"
%include "sprint.asm"
%include "printreg16.asm"

main:
	xor ax, ax		; Zero out ax
	mov ds, ax		; move it into DS register
				; ax is zeroed out to ensure ds contains nothing 
				; because we're setting the offset with ORG in NASM

	mov ss, ax		; stack starts at 0
	mov sp, 0x9c00		; 2000h past the stack start

	cld			; clear direction

	mov ax, 0xb800		; text video memory
	mov es, ax

	mov si, msg
	call sprint

	mov ax, 0xb800		; video memory
	mov gs, ax
	mov bx, 0x0000		; 'W'=57, attrib=0F
	mov ax, [gs:bx]

	mov word [reg16], ax	; look at the register
	call printreg16

hang:
	jmp hang

; ------------------------------------------------------------------------------
; Constants -- db = define bytes (8 bit) in NASM

xpos db 0
ypos db 0
hexstr db '0123456789ABCDEF'
outstr16 db '0000', 0
reg16 dw 0
msg	db 'Boot Successful.', 13, 10, 0
nxt	db 'Now hanging...', 13, 10, 0		

; -----------------------------------------------------------------------------
; Fill in

times 510-($-$$) db 0 	; NASM's way of filling up 510 bytes with zeros
db 0x55 		; The last two bytes are a boot signature
db 0xAA			; 	mostly used from older BIOS
