INCLUDE "defines.asm"

SECTION "Python VM common routines", ROM0

; Returns word ptr in HL (eg ptr to data)
PeekStack::
; Dec word ptr, and have L point to popped word's 'high' (little-endian word ptrs)
	ldh a, [hPyStackTop]
	dec a
	ld l, a

; Load high into A then H, and low into L
	ld h, HIGH(wPyStackPtrs)
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	ret


; Returns word ptr in HL (eg ptr to data)
PopStack::
; Dec word ptr, and have L point to popped word's 'high' (little-endian word ptrs)
	ldh a, [hPyStackTop]
	sub 2
	ldh [hPyStackTop], a
	inc a
	ld l, a

; Load high into A then H, and low into L
	ld h, HIGH(wPyStackPtrs)
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	ret


; HL - word ptr to push (eg ptr to data)
PushStack::
	ldh a, [hPyStackTop]
	ld c, a
	ld b, HIGH(wPyStackPtrs)
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	inc c
	ld a, c
	ldh [hPyStackTop], a
	ret


; Returns HL pointing to the newly-pushed data
PushNewNone::
	ld bc, 1
	call Malloc
	ld a, TYPE_NONE
	ld [hl], a
	jp PushStack


; B - int to push
PushNewInt::
	push bc
	ld bc, 2
	call Malloc
	pop bc

; Store an INT:B there
	ld a, TYPE_INT
	ld [hl+], a
	ld a, b
	ld [hl-], a
	jp PushStack


; DE - 1 string (the 1st byte being length, the last being $ff)
; HL - 1 string (same as above)
; Return Z flag set if strings match
; Does not preserve regs (DE and HL will be past a terminator if they match)
; todo: if string length == $ff, this will fail
CheckString::
.nextChar:
; If either [hl] or [de] are both $ff, they have the same length, so are both $ff
	ld a, [hl+]
	cp $ff
	jr z, .match

; If any character doesn't match, jump
	ld b, a
	ld a, [de]
	inc de

	cp b
	jr nz, .nomatch

	jr .nextChar

.match:
    inc de
	xor a
	ret

.nomatch:
	ld a, 1
	and a
	ret


Debug::
	jr @