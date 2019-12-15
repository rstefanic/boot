[ORG 0x7c00]			; offset directive

jmp main

%include "bios_print.asm"
%include "sprint.asm"
%include "printreg16.asm"
%include "clear_line.asm"

main:
	xor ax, ax		; Zero out ax
	mov ds, ax		; move it into DS register
				; ax is zeroed out to ensure ds contains nothing 
				; because we're setting the offset with ORG in NASM

	mov ss, ax		; stack starts at 0
	mov sp, 0x9c00		; 2000h past the stack start

	cld			; clear direction

	mov ax, 0xb800		; test video memory
	mov es, ax

	mov si, msg
	call clear_line
	call sprint

	mov ax, 0xb800		; video memory
	mov gs, ax
	mov bx, 0x0000		; 'W'=57, attrib=0F
	mov ax, [gs:bx]

	call clear_line
	mov word [reg16], ax	; look at the register
	call printreg16

halt:
	hlt

; ------------------------------------------------------------------------------
; Constants -- db = define bytes (8 bit) in NASM

msg	db 'Boot Successful.', 0

; -----------------------------------------------------------------------------
; Fill in

times 510-($-$$) db 0 	; NASM's way of filling up 510 bytes with zeros
db 0x55 		; The last two bytes are a boot signature
db 0xAA			; 	mostly used from older BIOS
