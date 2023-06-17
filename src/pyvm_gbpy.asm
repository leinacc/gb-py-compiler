INCLUDE "src/include/defines.asm"

SECTION "Python VM gbpy module asm routines", ROMX


GbpyModule::
	db TYPE_MODULE
; todo: these are purposely in order in my `main.py`, there should be strings+ptrs
	dw AsmLoadTiles
	dw AsmPrintString
	dw AsmWaitVBlank


InitGbpyModule::
    xor a
    ld [wPrintTileCol], a
	ld [wPrintTileCol+1], a
    ret


; Returns HL pointing to the newly-pushed data
PushNewNone:
	ld bc, 1
	call Malloc
	ld a, TYPE_NONE
	ld [hl], a
	jp PushStack


; B - int to push
PushNewInt:
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


AsmLoadTiles:
	db TYPE_ASM

; 1st param = filename
	ldh a, [hPyStackTop]
	add 2
	ld l, a
	ld h, HIGH(wPyStackPtrs)

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a

; Check filename to load is str
	ld a, [hl+]
	cp TYPE_STR
	jp nz, Debug

	ld d, h
	ld e, l

	ld hl, FileSystem

; Save ptr to next file to check
	ld a, [hl+]
	ldh [hFilesDirNextAddr], a
	ld a, [hl+]
	ldh [hFilesDirNextAddr], a

; Check filename
	push de
	call CheckString
; todo: we're assuming 1 file here for now (which would use the `pop de`)
	jr nz, .debug

	pop de

; DE = src of data
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
; BC = len of data
	ld a, [hl+]
	ld c, a
	ld b, [hl]
; todo: this is auto-allocated
	ld hl, $9000
; todo: files should have a size
	call LCDMemcpy

; todo: this is going to be the 1st tile idx from the auto-allocation
	ld b, 0
	jp PushNewInt

.debug:
	ret


AsmPrintString:
	db TYPE_ASM

; 2nd param = starting tile idx
	ldh a, [hPyStackTop]
	add 4
	ld l, a
	ld h, HIGH(wPyStackPtrs)

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a

	ld a, [hl+]
	cp TYPE_INT
	jr nz, .debug

	ld a, [hl]
	ld [wPrintStartingTileIdx], a

; 1st param = string to print
	ldh a, [hPyStackTop]
	add 2
	ld l, a
	ld h, HIGH(wPyStackPtrs)

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a

; Check type
; todo: like python, should be able to print non-strs?
.startPrint:
	ld a, [hl+]
	cp TYPE_STR
	jr nz, .debug

; Skip past length byte
	inc hl

	.nextChar:
		ld a, [hl+]
		cp $ff
		jr z, .done

	; todo: more control codes?
		cp $0a
		jr z, .newLine

	; Must not be below $20 (ascii tilesets' starting tile)
		cp $20
		jr c, .debug

	; After sub, $5f is invalid, and no other chars past it
		sub $20
		cp $5f
		jr nc, .debug

		push hl
		push af

	; HL points to dest for tile row
		ld a, [wPrintTileRow]
		ld h, HIGH(TileRowTilemapStarts)
		add a
		add LOW(TileRowTilemapStarts)
		ld l, a

	; HL = dest for tile row
		ld a, [hl+]
		ld h, [hl]
		ld l, a

	; Add tile col
		ld a, [wPrintTileCol]
		inc a
		ld [wPrintTileCol], a
		dec a
		add l
		ld l, a

	; Print tile
		wait_vram
		pop af
		ld [hl], a
		pop hl
		jr .nextChar

	.newLine:
		ld a, [wPrintTileRow]
		inc a
		ld [wPrintTileRow], a
		xor a
		ld [wPrintTileCol], a
		jr .nextChar

.done:
	jp PushNewNone

.debug:
	ret


TileRowTilemapStarts:
FOR N, SCRN_Y_B
	dw _SCRN0+N*$20
ENDR


AsmWaitVBlank:
	db TYPE_ASM
	call WaitVBlank
	jp PushNewNone


SECTION "PYVM Wram Print", WRAM0
wPrintStartingTileIdx: db
wPrintTileCol: db
wPrintTileRow: db
