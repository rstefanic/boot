[ORG 0x7c00]			; offset directive

jmp main

%include "bios_print.asm"
%include "sprint.asm"
%include "print_reg16.asm"
%include "clear_line.asm"

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

	cli			; clear interrupts

	mov bx, 0x09		; hardware interrupt number
	shl bx, 2		; mutliply by 2 (shift left 2 bits)
	xor ax, ax		; 0 out ax
	mov gs, ax		; start of memory
	mov [gs:bx], word keyhandler
	mov [gs:bx + 2], ds	; segment
	
	mov si, msg
	call clear_line
	call sprint

	mov si, next
	call clear_line
	call sprint

	sti			; set interrupt flag
	jmp $			; loop forever

keyhandler:
	in al, 0x60		; read data from the I/O device (keyboard)
	mov bl, al		; save it to bl
	mov byte [port60], al

	in al, 0x61		; read the keyboard control
	mov ah, al
	or al, 0x80		; disable bit 7
	out 0x61, al		; write it back to the I/O device (keyboard)
	xchg ah, al		; get the original al that we stored in ah
	out 0x61, al		; write the original back

	mov al, 0x20		; End Interrupt	by writing that we're finished
	out 0x20, al		; 

	and bl, 0x80		; key released
	jnz keyhandle_done

	call clear_line
	mov ax, [port60]
	mov word [reg16], ax	; look at the register
				; reg16 is located in "print_reg16.asm"
	call print_reg16

keyhandle_done:
	iret			; interrupt return

; ------------------------------------------------------------------------------
; General Descriptor Table

gdt_info:
	dw gdt_end - gdt - 1	; last byte in the General Descriptor Table
	dd gdt			; start of the date

gdt	dd 00 			; entry 0 is always unused
flat	dd 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
gdt_end:

; ------------------------------------------------------------------------------
; Constants -- db = define bytes (8 bit) in NASM

msg	db 'Boot Successful.', 0
next	db 'Press any key to echo the key code back...', 0

; -----------------------------------------------------------------------------
; Fill in

port60 	dw 0
times 510-($-$$) db 0 	; NASM's way of filling up 510 bytes with zeros
dw 0xAA55		; Magic bytes at 511 and 512 to let the BIOS know
			; 	this is bootable
