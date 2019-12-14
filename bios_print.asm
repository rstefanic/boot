bios_print:
	lodsb			; loadstring
	or al, al 		; zero means we're at the end
	jz done			; if zero, jump to done
	mov ah, 0x0E
	mov bh, 0
	int 0x10		; BIOS print char
	jmp bios_print
done:
	ret
