[SECTION .text]
global memcpy
global memset
global strcpy
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

; ---------------------------------------------------------------
; void memset(void* p_dst, char ch, int size);
; ---------------------------------------------------------------
memset:
	push ebp
	mov ebp, esp
	
	push esi
	push edi
	push ecx
	
	mov edi, [ebp + 8]
	mov edx, [ebp + 12]
	mov ecx, [ebp + 16]
.1:
	cmp ecx, 0
	jz .2

	mov byte[edi], dl
	inc edi
	
	dec ecx
	jmp .1
.2:
	pop ecx
	pop edi
	pop esi
	mov esp, ebp
	pop ebp

	ret
; end of memset------------------------------------

; -------------------------------------------------------------
; char* strcpy(char* p_dst, char* p_src);
; -------------------------------------------------------------
strcpy:
	push ebp
	mov ebp, esp
	
	mov esi, [ebp + 12]
	mov edi, [ebp + 8]
.1:
	mov al, [esi]
	inc esi

	mov byte [edi], al
	inc edi

	cmp al, 0
	jnz .1

	mov eax, [ebp + 8]
	
	pop ebp
	ret
; end of strcpy -------------------------------------------------
