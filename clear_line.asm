doclear: 
	call clear
clear_line:
	cmp byte [x_clear], 80		; see if we're cleared the whole row
	jne doclear		
	add byte [y_clear], 1		; down one row
	mov byte [x_clear], 0		; back to the left
	ret

clear:					; prints a space char at the current pos
	mov al, 0x20
	mov ah, 0x0F			; set the attribute of white on black
	mov cx, ax			; save the attribute
	movzx ax, byte [y_clear]	; shift positions
	mov dx, 160			; 2 bytes for the char
	mul dx				; for 80 col
	movzx bx, byte [x_clear]
	shl bx, 1			; 2 for the skip attribute

	mov di, 0			; start of video memory
	add di, ax			; add y offset
	add di, bx			; add x offset

	mov ax, cx			; restore attribute
	stosw				; write attribute
	add byte [x_clear], 1		; advance to the right
	ret

; ------------------------------------------------------------------------------
; Used to keep track of the x and y position for clear_line

x_clear db 0
y_clear db 0
