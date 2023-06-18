INCLUDE "defines.asm"

SECTION "Python VM gbpy module asm routines", ROMX


GbpyModule::
	db TYPE_GBPY_MODULE
	db $0b, "load_tiles", $ff
		dw AsmLoadTiles
	db $0d, "print_string", $ff
		dw AsmPrintString
	db $0c, "wait_vblank", $ff
		dw AsmWaitVBlank
	db $ff


InitGbpyModule::
    xor a
    ld [wPrintTileCol], a
	ld [wPrintTileCol+1], a
    ret


AsmLoadTiles:
	db TYPE_ASM

; 1st param = filename
	ldh a, [hPyStackTop]
	add 2
	ld l, a
	ldh a, [hCallStackTop]
	add HIGH(wFrameStackPtrs)
	ld h, a

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

; Each name has 2 word ptrs after it
	ld a, 4
	ldh [hStringListExtraBytes], a
	call HLequAfterMatchingNameInList

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


AsmPrintString:
	db TYPE_ASM

; 2nd param = starting tile idx
	ldh a, [hPyStackTop]
	add 4
	ld l, a
	ldh a, [hCallStackTop]
	add HIGH(wFrameStackPtrs)
	ld h, a

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
	ldh a, [hCallStackTop]
	add HIGH(wFrameStackPtrs)
	ld h, a

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
