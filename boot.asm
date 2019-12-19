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
	push ds			; save real mode

	mov bx, 0x09		; hardware interrupt number
	shl bx, 2		; mutliply by 2 (shift left 2 bits)
	xor ax, ax		; 0 out ax
	mov gs, ax		; start of memory
	mov [gs:bx], word keyhandler
	mov [gs:bx + 2], ds	; segment
	
	mov si, msg		; load start message
	call clear_line
	call sprint		; print start message

	mov si, next		; load next message
	call clear_line
	call sprint		; print next message

	lgdt [gdt_info]		; load gdt register

	mov eax, cr0		; check cr0 and or the value to
	or al, 1		; 	sure we're in protected mode
	mov cr0, eax		; set cr0 to switch into protected mode

	mov bx, 0x08		; to select our first descriptor, we use
	mov ds, bx		; 8h = 1000b as our offset because
				; in protected mode, bits 3-15 in the segment
				; register are an index into the descriptor
				; table. That's why 0x08 gets us the first entry

	and al, 0xFE		; set al to 1 to switch back into real mode
	mov cr0, eax		; set cr0 to 1

	pop ds			; get back to our old segment
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
;
; A simple single descriptor table. The size is 1MB and
; the base address is 0x0.
;
; 0 lowest byte of Limit
;	[P - Present (1 bit) = 1 means segment is in memory]
; 1 next byte of Limit
;	[DPL - Descriptor Privilege Level]
; 2 lowest byte of Base Address
;	[S - System (1 bit)]
; 3 next byte of Base Address
;	[Type (4 bits) = interpretation changes on S is set or not]
; 4 third byte of Base Address
;	[Type bit 3 - If high bit is 1, then it's a code segment; othwerise DS]
; 5 Type Bit 2
; 6 Type Bit 1
; 7 Type Bit 0

gdt_info:
	dw gdt_end - gdt - 1	; last byte in the General Descriptor Table
	dd gdt			; start of the date

gdt		dd 0,0 		; entry 0 is always unused
flatdesc	db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
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
