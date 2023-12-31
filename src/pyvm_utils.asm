INCLUDE "defines.asm"

INCLUDE "include/file_system.asm"

SECTION "Python VM common routines", ROM0


BCequCurrFrameStackPtrs:
	ldh a, [hPyStackTop]
	ld c, a
	ldh a, [hCurrCallStackIdx]
	add HIGH(wFrameStackPtrs)
	ld b, a
	ret


BequCurrFastNamesHi::
	ldh a, [hCurrCallStackIdx]
	add HIGH(wPyFastNames)
	ld b, a
	ret


DEequCurrFrameStackPtrs::
	ldh a, [hPyStackTop]
	ld e, a
	ldh a, [hCurrCallStackIdx]
	add HIGH(wFrameStackPtrs)
	ld d, a
	ret


HLequCurrFrameStackPtrs::
	ldh a, [hPyStackTop]
	ld l, a
	ldh a, [hCurrCallStackIdx]
	add HIGH(wFrameStackPtrs)
	ld h, a
	ret


HLequCurrReturnCallStackIdx::
	ld l, LOW(wReturnCallStackIdx)
	ldh a, [hCurrCallStackIdx]
	add HIGH(wReturnCallStackIdx)
	ld h, a
	ret


HequCurrFastNamesHi::
	ldh a, [hCurrCallStackIdx]
	add HIGH(wPyFastNames)
	ld h, a
	ret


; Returns word ptr in HL (eg ptr to data)
PeekStack::
; Dec word ptr, and have L point to popped word's 'high' (little-endian word ptrs)
	call HLequCurrFrameStackPtrs
	dec l

; Load high into A then H, and low into L
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	ret


; Returns word ptr in HL (eg ptr to data)
; Trashes A
PopStack::
; Dec word ptr, and have L point to popped word's 'low' (little-endian word ptrs)
	call HLequCurrFrameStackPtrs
	dec l
	dec l
	ld a, l
	ldh [hPyStackTop], a

; Load high into A then H, and low into L
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret


; HL - word ptr to push (eg ptr to data)
PushStack::
	call BCequCurrFrameStackPtrs
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	inc c
	ld a, c
	ldh [hPyStackTop], a
	ret


; Returns HL pointing to the newly-pushed None
PushNewNone::
	ld bc, 1
	call Malloc
	ld a, TYPE_NONE
	ld [hl], a
	jp PushStack


; B - int to push
; Returns HL pointing to the newly-pushed int
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


; B - 1 if True, 0 if False
; Returns HL pointing to the newly-pushed bool
PushNewBool::
	push bc
	ld bc, 2
	call Malloc
	pop bc

; Store an BOOL:B there
	ld a, TYPE_BOOL
	ld [hl+], a
	ld a, b
	ld [hl-], a
	jp PushStack


; HL - pointer to a Str macro
; Returns B:HL = a pointer to the file
; Trashes A, C, DE
GetSrcOfFileInHL::
	call FileSystemHash
	ld b, a
	add a
	add b
	ld hl, FileSystem
	add l
	ld l, a
	jr nc, :+
	inc h
:	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret


; A - param idx starting 0
; Trashes A, B
HLequAddrOfFuncParam::
; 1st param is +2 after block's stack ptr
; (as the ptr looks at the function address)
	inc a
	add a
	ld b, a

	call HLequCurrFrameStackPtrs
	ld a, b
	add l
	ld l, a

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret


; A - param idx starting 0
; Trashes A, B
AequIntParam::
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	ret


EndEntitysScript::
; HL = return address (to CallFunction handler)
	pop hl

; HL = address of bytecode after the CallFunction that got here
	pop hl
	ld a, l
	ldh [hSavedBytecodeAddr], a
	ld a, h
	ldh [hSavedBytecodeAddr+1], a

; Return to the ContEntityFrameStack's .return
	ret


; HL - points to high byte of potential heap addr
; Returns HL pointing to the low byte of that address
; Trashes A, DE
FreeStackPoppedData::
; Check if we need to free data
	ld a, [hl-]
	cp HIGH(wHeapData)
	ret c

	cp HIGH(wHeapData.end)
	ret nc

; If so, go from user data to chunk header, and Free the chunk
	push hl
	ld l, [hl]
	ld h, a
	call Free
	pop hl
	ret


Debug::
	jr @
