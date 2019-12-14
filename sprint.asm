dochar: 
	call cprint		; print character
sprint:
	lodsb
	cmp al, 0		; if it's not zero, jump to dochar
	jne dochar		
	add byte [ypos], 1	; down one row
	mov byte [xpos], 0	; back to the left
	ret

cprint:				; prints a character
	mov ah, 0x0F		; set the attribute of white on black
	mov cx, ax		; save the attribute
	movzx ax, byte [ypos]	; shift positions
	mov dx, 160		; 2 bytes for the char
	mul dx			; for 80 col
	movzx bx, byte [xpos]
	shl bx, 1		; 2 for the skip attribute

	mov di, 0		; start of video memory
	add di, ax		; add y offset
	add di, bx		; add x offset

	mov ax, cx		; restore attribute
	stosw			; write attribute
	add byte [xpos], 1	; advance to the right
	ret
