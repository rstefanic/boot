printreg16:			; our setup for creating our hex value
	mov di, outstr16	; the template of the register we're reading 
				; defined as '0x000' in boot.asm
	mov ax, [reg16]
	mov si, hexstr		; all the possible hex digits
	mov cx, 4		; move it 4 places

hexloop:			; main loop
	rol ax, 4		; starting with the left most character
	mov bx, ax
	and bx, 0x0F		; move it into the right most character
	mov bl, [si + bx]	; find the index from our hex string to we
				; know which character it is
	mov [di], bl
	inc di
	dec cx
	jnz hexloop		; repeat if we're not finished

	mov si, outstr16	; move our result into si
	call sprint		; print our result to the screen

	ret

hexstr db '0123456789ABCDEF'
outstr16 db '0000', 0
reg16 dw 0
