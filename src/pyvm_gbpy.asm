INCLUDE "defines.asm"

SECTION "Python VM gbpy module asm routines", ROM0


GbpyModule::
	db TYPE_GBPY_MODULE
	db $0b, "load_tiles", $ff
		dw AsmLoadTiles
	db $0d, "print_string", $ff
		dw AsmPrintString
	db $0c, "wait_vblank", $ff
		dw AsmWaitVBlank
	db $0e, "load_palettes", $ff
		dw AsmLoadPalettes
	db $0a, "load_room", $ff
		dw AsmLoadRoom
	db $0f, "load_metatiles", $ff
		dw AsmLoadMetatiles
	db $ff


InitGbpyModule::
    xor a
    ld [wPrintTileCol], a
	ld [wPrintTileCol+1], a
    ret


AsmLoadTiles:
	db TYPE_ASM

; 1st param file is the tile data to load
	xor a
	call HLequAfterFilenameInVMDir

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


AsmLoadPalettes:
	db TYPE_ASM

; 1st param file is the palette data to load
	xor a
	call HLequAfterFilenameInVMDir

; DE (later HL) = src of data
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	push de
; B = len of data
	ld a, [hl]
	ld b, a
	pop hl

; todo: allow choosing a starting palette
	ld a, BCPSF_AUTOINC
	ldh [rBCPS], a
	ld c, LOW(rBCPD)
	.nextColByte:
		wait_vram
		ld a, [hl+]
		ldh [c], a
		dec b
		jr nz, .nextColByte

	jp PushNewNone


AsmLoadRoom:
	db TYPE_ASM

; 1st param file is the palette data to load
	xor a
	call HLequAfterFilenameInVMDir

; DE = src of data
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
; C = len of data
	ld a, [hl]
	ld c, a

	ld hl, wRoomMetatiles
	rst MemcpySmall

	jp PushNewNone


AsmLoadMetatiles:
	db TYPE_ASM

; 1st param file is the metatile tiles to load
	xor a
	call HLequAfterFilenameInVMDir

; Store metatile table addr
	ld a, [hl+]
	ld [wMetatileTableAddr], a
	ld a, [hl+]
	ld [wMetatileTableAddr+1], a
	call LoadRoomMetatiles

	ld a, 1
	ldh [rVBK], a

; 2nd param file is the metatile attrs to load
	call HLequAfterFilenameInVMDir

; Store metatile table addr
	ld a, [hl+]
	ld [wMetatileTableAddr], a
	ld a, [hl+]
	ld [wMetatileTableAddr+1], a
	call LoadRoomMetatiles

	xor a
	ldh [rVBK], a

	jp PushNewNone


LoadRoomMetatiles:
	ld c, 9
	ld hl, wRoomMetatiles
	ld de, $9800
	.nextMetatileRow:
		ld b, 10
		push de
		.nextMetatileCol:
			ld a, [hl+]
			call StoreMetatileTilesOrAttrs
			dec b
			jr nz, .nextMetatileCol

		pop de
		ld a, $40
		add e
		ld e, a
		jr nc, :+
		inc d

	:	dec c
		jr nz, .nextMetatileRow

	ret


; A - metatile idx
; DE - dest addr for top-left tile
; Preserves B, C, HL
; Returns DE = DE+2
StoreMetatileTilesOrAttrs:
	push bc
	push hl

; B = 4 * metatile idx (num bytes per metatile)
	add a
	add a
	ld b, a

; HL = addr of metatile data
	ld a, [wMetatileTableAddr+1]
	ld h, a
	ld a, [wMetatileTableAddr]
	add b
	ld l, a
	jr nc, :+
	inc h

; Copy TL, TR, BL, BR
:	wait_vram
	ld a, [hl+]
	ld [de], a
	inc de
	wait_vram
	ld a, [hl+]
	ld [de], a
	push de
	ld a, $1f
	add e
	ld e, a
	jr nc, :+
	inc d
:	wait_vram
	ld a, [hl+]
	ld [de], a
	inc de
	wait_vram
	ld a, [hl+]
	ld [de], a

	pop de
	inc de

	pop hl
	pop bc
	ret


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
	rst WaitVBlank
	jp PushNewNone


SECTION "PYVM Wram Print", WRAM0
wPrintStartingTileIdx: db
wPrintTileCol: db
wPrintTileRow: db


SECTION "Room loading", WRAM0
wRoomMetatiles: ds 10*9
wMetatileTableAddr: dw
