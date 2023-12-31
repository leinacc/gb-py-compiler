INCLUDE "defines.asm"

SECTION "Dynamic Allocation", ROM0

InitDynamicAllocation::
	xor a
	ld [wCurrBGTile], a
	ld [wCurrOBJTile], a
	ld [wCurrBGPalette], a
	ld [wCurrOBJPalette], a
	ret


; B - bank
; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated tile idx in A
; Trashes BC and DE
FarAllocateBGTileData::
	ldh a, [hCurROMBank]
	push af

	ld a, b
	ldh [hCurROMBank], a
	ld [rROMB0], a

	call AllocateBGTileData
	ld b, a

	pop af
	ldh [hCurROMBank], a
	ld [rROMB0], a
	ld a, b
	ret


; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated tile idx in A
; Trashes BC and DE
AllocateBGTileData:
; BC = len of data
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a

; DE = src of data
	ld e, l
	ld d, h

; HL = dest
	ld a, [wCurrBGTile]
	push af

	swap a
	ld l, a
	and $0f
	or $90
	cp $98
	jr c, :+
	sub $10
:	ld h, a
	ld a, l
	and $f0
	ld l, a

; Copy LCDMemcpy, keeping track of next bg tile
; Increment B if C is non-zero
	dec bc
	inc b
	inc c

	.loop
		wait_vram
		ld a, [de]
		ld [hli], a
		inc de

		ld a, l
		and $0f
		jr nz, .toNextLoop

		ld a, [wCurrBGTile]
		inc a
		ld [wCurrBGTile], a

		ld a, l
		and a
		jr nz, .toNextLoop

		ld a, h
		cp $98
		jr nz, .toNextLoop

		ld h, $88

	.toNextLoop:
		dec c
		jr nz, .loop
		dec b
		jr nz, .loop

    pop af
    ret


; B - bank
; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated tile idx in A
; Trashes BC and DE
FarAllocateOBJTileData::
	ldh a, [hCurROMBank]
	push af

	ld a, b
	ldh [hCurROMBank], a
	ld [rROMB0], a

	call AllocateOBJTileData
	ld b, a

	pop af
	ldh [hCurROMBank], a
	ld [rROMB0], a
	ld a, b
	ret


; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated tile idx in A
; Trashes BC and DE
AllocateOBJTileData::
; BC = len of data
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a

; DE = src of data
	ld e, l
	ld d, h

; HL = dest
	ld a, [wCurrOBJTile]
	push af

	swap a
	ld l, a
	and $0f
	or $80
	ld h, a
	ld a, l
	and $f0
	ld l, a

; Copy LCDMemcpy, keeping track of next bg tile
; Increment B if C is non-zero
	dec bc
	inc b
	inc c

	.loop
		wait_vram
		ld a, [de]
		ld [hli], a
		inc de

		ld a, l
		and $0f
		jr nz, .toNextLoop

		ld a, [wCurrOBJTile]
		inc a
		ld [wCurrOBJTile], a

		ld a, l
		and a
		jr nz, .toNextLoop

		ld a, h
		cp $90
		jr nz, .toNextLoop

		ld h, $80

	.toNextLoop:
		dec c
		jr nz, .loop
		dec b
		jr nz, .loop

    pop af
    ret


; B - bank
; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated palette idx in B
; Trashes A, C, D, E
FarAllocateBGPalettes::
	ldh a, [hCurROMBank]
	push af

	ld a, b
	ldh [hCurROMBank], a
	ld [rROMB0], a

	call AllocateBGPalettes

	pop af
	ldh [hCurROMBank], a
	ld [rROMB0], a
	ret


; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated palette idx in B
; Trashes A, C, D, E
AllocateBGPalettes:
; B = len of data
; HL = src of data
	ld a, [hl+]
	ld b, a
	inc hl

; Push num palettes
	srl a
	srl a
	srl a
	push af

; Allow choosing a starting palette
	ld a, [wCurrBGPalette]
	push af
	add a
	add a
	add a
	add BCPSF_AUTOINC
	ldh [rBCPS], a
	ld c, LOW(rBCPD)
	.nextColByte:
		wait_vram
		ld a, [hl+]
		ldh [c], a
		dec b
		jr nz, .nextColByte

	pop af
	ld b, a
	pop de
	add d
	ld [wCurrBGPalette], a
    ret


; B - bank
; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated palette idx in B
; Trashes A, C, D, E
FarAllocateOBJPalettes::
	ldh a, [hCurROMBank]
	push af

	ld a, b
	ldh [hCurROMBank], a
	ld [rROMB0], a

	call AllocateOBJPalettes

	pop af
	ldh [hCurROMBank], a
	ld [rROMB0], a
	ret


; HL - addr of file, has a size word, then the file data after it
; Returns 1st allocated palette idx in B
; Trashes A, C, D, E
AllocateOBJPalettes::
; B = len of data
; HL = src of data
	ld a, [hl+]
	ld b, a
	inc hl

; Push num palettes
	srl a
	srl a
	srl a
	push af

; Allow choosing a starting palette
	ld a, [wCurrOBJPalette]
	push af
	add a
	add a
	add a
	add OCPSF_AUTOINC
	ldh [rOCPS], a
	ld c, LOW(rOCPD)
	.nextColByte:
		wait_vram
		ld a, [hl+]
		ldh [c], a
		dec b
		jr nz, .nextColByte

; Dynamically allocate and return a palette
	pop af
	ld b, a
	pop de
	add d
	ld [wCurrOBJPalette], a
    ret


SECTION "Dynamic allocation", WRAM0
wCurrBGTile: db
wCurrOBJTile: db
wCurrBGPalette:: db
wCurrOBJPalette: db
