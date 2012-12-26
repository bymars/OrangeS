[SECTION .text]
global memcpy
; ---------------------------------------------------------------------
; Memory copy.
; void* memcpy(void* es:pDest, void* ds:pSrc, int iSize)
;----------------------------------------------------------------------	
memcpy:
	push	ebp
	mov	ebp, esp
	
	push	esi
	push	edi
	push	ecx
	
	mov 	edi, [ebp + 8] ; dest
	mov 	esi, [ebp + 12] ; src
	mov 	ecx, [ebp + 16] ; Counter

.1:
	cmp 	ecx, 0
	jz 	.2

	mov	al, [ds:esi]
	inc	esi
	
	mov	byte [es:edi], al
	inc	edi
	
	dec 	ecx
	jmp 	.1
.2:
	mov 	eax, [ebp + 8]

	pop 	ecx
	pop	edi
	pop	esi
	mov	esp, ebp
	pop	ebp

	ret
; end of MemCpy-----------------------------------------------------------


