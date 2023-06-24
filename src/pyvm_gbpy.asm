INCLUDE "defines.asm"

SECTION "Python VM gbpy module asm routines", ROM0


GbpyModule::
	db TYPE_GBPY_MODULE
	db $0e, "load_bg_tiles", $ff
		dw AsmLoadBGTiles
	db $0f, "load_obj_tiles", $ff
		dw AsmLoadOBJTiles
	db $0d, "print_string", $ff
		dw AsmPrintString
	db $0c, "wait_vblank", $ff
		dw AsmWaitVBlank
	db $11, "load_bg_palettes", $ff
		dw AsmLoadBGPalettes
	db $12, "load_obj_palettes", $ff
		dw AsmLoadOBJPalettes
	db $0a, "load_room", $ff
		dw AsmLoadRoom
	db $0f, "load_metatiles", $ff
		dw AsmLoadMetatiles
	db $0b, "add_entity", $ff
		dw AsmAddEntity
	db $0a, "move_left", $ff
		dw AsmMoveLeft
	db $0b, "move_right", $ff
		dw AsmMoveRight
	db $08, "move_up", $ff
		dw AsmMoveUp
	db $0a, "move_down", $ff
		dw AsmMoveDown
	db $10, "update_entities", $ff
		dw AsmUpdateEntities
	db $10, "enable_movement", $ff
		dw AsmEnableMovement
	db $0c, "entity_noop", $ff
		dw AsmEntityNoop
	db $ff


AsmStub:
	db TYPE_ASM
	jp Debug


InitGbpyModule::
    xor a
    ld [wPrintTileCol], a
	ld [wPrintTileCol+1], a
    ret


AsmLoadBGTiles:
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


AsmLoadOBJTiles:
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
	ld hl, $8000
; todo: files should have a size
	call LCDMemcpy

; todo: this is going to be the 1st tile idx from the auto-allocation
	ld b, 0
	jp PushNewInt


AsmLoadBGPalettes:
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
; todo: return the starting palette idx, save the next allocatable one, choose bg/spr
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


AsmLoadOBJPalettes:
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
; todo: return the starting palette idx, save the next allocatable one, choose bg/spr
	ld a, OCPSF_AUTOINC
	ldh [rOCPS], a
	ld c, LOW(rOCPD)
	.nextColByte:
		wait_vram
		ld a, [hl+]
		ldh [c], a
		dec b
		jr nz, .nextColByte

; todo: this should dynamically allocate and return a palette
	ld b, 0
	jp PushNewInt


AsmLoadMetatiles:
	db TYPE_ASM

; 1st param file is the room metatile data to load
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

	ld hl, wRoomMetatiles
	call Memcpy

	jp PushNewNone


AsmLoadRoom:
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
	ld c, $10
	ld hl, wRoomMetatiles
	ld de, $9800
	.nextMetatileRow:
		ld b, $10
		.nextMetatileCol:
			ld a, [hl+]
			call StoreMetatileTilesOrAttrs
			dec b
			jr nz, .nextMetatileCol

		ld a, $20
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


AsmAddEntity:
	db TYPE_ASM

; 7th param is the metatiles tiles data
	ld a, 6
	call HLequAfterFilenameInVMDir
	ld a, [hl+]
	ld [wTempEntityMtilesAddr], a
	ld a, [hl]
	ld [wTempEntityMtilesAddr+1], a

; 8th param is the metatiles attrs data
	ld a, 7
	call HLequAfterFilenameInVMDir
	ld a, [hl+]
	ld [wTempEntityMattrsAddr], a
	ld a, [hl]
	ld [wTempEntityMattrsAddr+1], a

; 1st param is the tile x (push as the below routine trashes B)
	xor a
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	push af

; 2nd param is the tile y
	ld a, 1
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	pop bc
	ld a, [hl]
	ld c, a
	push bc

; 3rd param is the entity script
	ld a, 2
	call HLequAddrOfFuncParam

	ld a, [hl]
	cp TYPE_FUNCTION
	jp nz, Debug

	ld e, l
	ld d, h

; 4th param is the anim definition idx
	ld a, 3
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	push af

; 5th param is the pals ptr
	ld a, 4
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	push af

; 6th param is the tiles ptr
	ld a, 5
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	pop hl
	ld l, a

; Pop anim def idx, then tile x/y
	pop af
	pop bc

	call AddEntity
; todo: this should be the entity idx
	ld b, 0
	jp PushNewInt


AsmMoveLeft:
	db TYPE_ASM

	xor a
	call AequIntParam

; Set movement details
	ld b, a
	call MoveLeft

	call PushNewNone
	jp EndEntitysScript


AsmMoveRight:
	db TYPE_ASM

	xor a
	call AequIntParam

; Set movement details
	ld b, a
	call MoveRight

	call PushNewNone
	jp EndEntitysScript


AsmMoveUp:
	db TYPE_ASM

	xor a
	call AequIntParam

; Set movement details
	ld b, a
	call MoveUp

	call PushNewNone
	jp EndEntitysScript


AsmMoveDown:
	db TYPE_ASM

	xor a
	call AequIntParam

; Set movement details
	ld b, a
	call MoveDown

	call PushNewNone
	jp EndEntitysScript


AsmUpdateEntities:
	db TYPE_ASM
	call UpdateEntities
	jp PushNewNone


AsmEnableMovement:
	db TYPE_ASM
	ld a, 1
	ld [wCurrEntity_PlayerMoved], a
	jp PushNewNone


AsmEntityNoop:
	db TYPE_ASM
	call PushNewNone
	jp EndEntitysScript


AsmPrintString:
	db TYPE_ASM

; 2nd param = starting tile idx
	ld a, 1
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jr nz, .debug

	ld a, [hl]
	ld [wPrintStartingTileIdx], a

; 1st param = string to print
	ld a, 0
	call HLequAddrOfFuncParam

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
wRoomMetatiles:: ds 16*16
wMetatileTableAddr: dw
wTempEntityMtilesAddr:: dw
wTempEntityMattrsAddr:: dw
