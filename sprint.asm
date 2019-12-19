dochar: 
	call cprint		; print character
sprint:
	mov eax, [esi]		; character string into al
	lea esi, [esi+1]
	cmp al, 0		; if it's not zero, jump to dochar
	jne dochar		
	add byte [ypos], 1	; down one row
	mov byte [xpos], 0	; back to the left
	ret

cprint:				; prints a character
	mov ah, 0x0F		; set the attribute of white on black
	mov ecx, eax		; save the attribute
	movzx eax, byte [ypos]	; shift positions
	mov edx, 160		; 2 bytes for the char
	mul edx			; for 80 col
	movzx ebx, byte [xpos]
	shl ebx, 1		; 2 for the skip attribute

	mov edi, 0xb8000	; start of video memory
	add edi, eax		; add y offset
	add edi, ebx		; add x offset

	mov eax, ecx		; restore attribute
	mov word [ds:edi], ax
	add byte [xpos], 1	; advance to the right
	ret

xpos db 0
ypos db 0
