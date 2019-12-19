; For printing 32 bit registers and values

print_reg32:
	mov edi, outstr32
	mov eax, [reg32]
	mov esi, hexstr
	mov ecx, 8

hexloop:
	rol eax, 4
	mov ebx, eax
	and ebx, 0x0f
	mov bl, [esi + ebx]
	mov [edi], bl
	inc edi
	dec ecx
	jnz hexloop

	mov esi, outstr32
	call sprint

	ret

hexstr db '0123456789ABCDEF'
outstr32 db '00000000', 0
reg32 dd 0
