INCLUDE "defines.asm"

SECTION "Python VM gbpy module asm routines", ROM0


GbpyModule::
	db TYPE_GBPY_MODULE
	; arg0: filename
	Str "load_bg_tiles"
		dw AsmLoadBGTiles
	; arg0: filename
	Str "load_obj_tiles"
		dw AsmLoadOBJTiles
	Str "wait_vblank"
		dw AsmWaitVBlank
	; arg0: filename
	Str "load_bg_palettes"
		dw AsmLoadBGPalettes
	; arg0: filename
	Str "load_obj_palettes"
		dw AsmLoadOBJPalettes
	; arg0: metatile tiles filename
	; arg1: metatile attrs filename
	; arg2: tile data ptr for the tiles arg0 refers to
	; arg3: palettes ptr for the palettes arg1 refers to
	Str "load_room"
		dw AsmLoadRoom
	; arg0: room's metatiles filename
	Str "load_metatiles"
		dw AsmLoadMetatiles
	; arg0: script function ptr
	; arg1: animation definition index
	; arg2: palettes ptr for the palettes arg7 refers to
	; arg3: tile data ptr for the tiles arg6 refers to
	; arg4: metatile tiles filename
	; arg5: metatile attrs filename
	; arg6: metatile x
	; arg7: metatile y
	Str "add_entity"
		dw AsmAddEntity
	; arg0: num metatiles to move
	Str "move_left"
		dw AsmMoveLeft
	; arg0: num metatiles to move
	Str "move_right"
		dw AsmMoveRight
	; arg0: num metatiles to move
	Str "move_up"
		dw AsmMoveUp
	; arg0: num metatiles to move
	Str "move_down"
		dw AsmMoveDown
	Str "update_entities"
		dw AsmUpdateEntities
	Str "enable_movement"
		dw AsmEnableMovement
	Str "enable_abilities"
		dw AsmEnableAbilities
	Str "entity_noop"
		dw AsmEntityNoop
	; arg0: the text to print
	;       \0 to \7 change the text to 1 of 8 pre-defined colors
	Str "load_vwf"
		dw AsmLoadVwf
	Str "allow_1_move"
		dw AsmAllow1Move
	Str "enable_solid"
		dw AsmEnableSolid
	; arg0: id of an entity to check collision with
	Str "collides_with"
		dw AsmCollidesWith
	; arg0: id of an entity to remove the 'solid' state from
	Str "disable_other_solid"
		dw AsmDisableOtherSolid
	; arg0: id of an entity to change the dir of
	Str "look_other_down"
		dw AsmLookOtherDown
	Str "look_down"
		dw AsmLookDown
	Str "show_status"
		dw AsmShowStatus
	; arg0: script function ptr
	; arg1: animation definition index
	; arg2: palettes ptr for the palettes arg7 refers to
	; arg3: tile data ptr for the tiles arg6 refers to
	; arg4: metatile tiles filename
	; arg5: metatile attrs filename
	Str "add_player_entity"
		dw AsmAddPlayerEntity
	db $ff


AsmStub:
	db TYPE_ASM
	jp Debug


AsmLoadBGTiles:
	db TYPE_ASM

; 1st param file is the tile data to load
	xor a
	call HLequAfterFilenameInVMDir

; Return the 1st tile idx from the auto-allocation
	call AllocateBGTileData
	ld b, a
	jp PushNewInt


AsmLoadOBJTiles:
	db TYPE_ASM

; 1st param file is the tile data to load
	xor a
	call HLequAfterFilenameInVMDir

; Return the 1st tile idx from the auto-allocation
	call AllocateOBJTileData
	ld b, a
	jp PushNewInt


AsmLoadBGPalettes:
	db TYPE_ASM

; 1st param file is the palette data to load
	xor a
	call HLequAfterFilenameInVMDir

	call AllocateBGPalettes
	jp PushNewInt


AsmLoadOBJPalettes:
	db TYPE_ASM

; 1st param file is the palette data to load
	xor a
	call HLequAfterFilenameInVMDir

	call AllocateOBJPalettes
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

; 3rd param is the base tile idx
	ld a, 2
	call AequIntParam
	ld [wTempRoomLoadBaseTileOrPalIdx], a

; 1st param file is the metatile tiles to load
	xor a
	call HLequAfterFilenameInVMDir

; Store metatile table addr
	ld a, [hl+]
	ld [wMetatileTableAddr], a
	ld a, [hl+]
	ld [wMetatileTableAddr+1], a
	call LoadRoomMetatiles

; 4th param is the base palette idx
	ld a, 3
	call AequIntParam
	ld [wTempRoomLoadBaseTileOrPalIdx], a

; 2nd param file is the metatile attrs to load
	ld a, 1
	ldh [rVBK], a
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
; wMetatileTableAddr
; wTempRoomLoadBaseTileOrPalIdx
; Preserves B, C, HL
; Returns DE = DE+2
; rVBK - determines if it's tiles or attrs being set
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

; B = the base tile/palette idx to add to the curr tile/attr
:	ld a, [wTempRoomLoadBaseTileOrPalIdx]
	ld b, a

; Copy TL, TR, BL, BR
	wait_vram
	ld a, [hl+]
	add b
	ld [de], a
	inc de
	wait_vram
	ld a, [hl+]
	add b
	ld [de], a
	push de
	ld a, $1f
	add e
	ld e, a
	jr nc, :+
	inc d
:	wait_vram
	ld a, [hl+]
	add b
	ld [de], a
	inc de
	wait_vram
	ld a, [hl+]
	add b
	ld [de], a

	pop de
	inc de

	pop hl
	pop bc
	ret


AsmAddEntity:
	db TYPE_ASM

; 7th param is the tile x (push as the below routine trashes B)
	ld a, 6
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	push af

; 8th param is the tile y
	ld a, 7
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

; B = tile x, C = tile y
	pop bc
	ld a, [hl]
	ld c, a

; B - tile x
; C - tile y
; Rest of details in AsmAddEntity or AsmAddPlayerEntity's 6 params
_AddEntity:
	push bc

; 5th param is the metatiles tiles data
	ld a, 4
	call HLequAfterFilenameInVMDir
	ld a, [hl+]
	ld [wTempEntityMtilesAddr], a
	ld a, [hl]
	ld [wTempEntityMtilesAddr+1], a

; 6th param is the metatiles attrs data
	ld a, 5
	call HLequAfterFilenameInVMDir
	ld a, [hl+]
	ld [wTempEntityMattrsAddr], a
	ld a, [hl]
	ld [wTempEntityMattrsAddr+1], a

; 1st param is the entity script
	xor a
	call HLequAddrOfFuncParam

	ld a, [hl]
	cp TYPE_FUNCTION
	jp nz, Debug

	ld e, l
	ld d, h

; 2nd param is the anim definition idx
	ld a, 1
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	push af

; 3rd param is the pals ptr
	ld a, 2
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_INT
	jp nz, Debug

	ld a, [hl]
	push af

; 4th param is the tiles ptr
	ld a, 3
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
; Return the entity idx
	ld a, [wChosenEntitySlot]
	ld b, a
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
	ld a, [wCurrEntity_InputCtrl]
	set ENTCTRL_DIR_MOVABLE, a
	ld [wCurrEntity_InputCtrl], a
	jp PushNewNone


AsmEnableAbilities:
	db TYPE_ASM
	ld a, [wCurrEntity_InputCtrl]
	set ENTCTRL_USES_ABILITIES, a
	ld [wCurrEntity_InputCtrl], a
	jp PushNewNone


AsmEntityNoop:
	db TYPE_ASM
	call PassTurnToNextEntity
	call PushNewNone
	jp EndEntitysScript


AsmAllow1Move:
	db TYPE_ASM
	call UpdateEntity
	call PushNewNone
	jp EndEntitysScript


AsmEnableSolid:
	db TYPE_ASM
	ld a, [wCurrEntity_InputCtrl]
	set ENTCTRL_IS_SOLID, a
	ld [wCurrEntity_InputCtrl], a
	jp PushNewNone


AsmCollidesWith:
	db TYPE_ASM

; Arg 0 is the entity id to check against the current
	xor a
	call AequIntParam

; todo: verify the slot is in-user
	ld hl, wEntity00_TileX
	and a
	jr z, .foundEntity

	ld de, wEntity01-wEntity00
	:	add hl, de
		dec a
		jr nz, :-

.foundEntity:
	ld a, [hl+]
	ld b, a
	ld a, [wCurrEntity_TileX]
	cp b
	jr nz, .noCollide

	ld b, [hl]
	ld a, [wCurrEntity_TileY]
	cp b
	jr nz, .noCollide

; We collided
	ld b, BOOL_TRUE
	jp PushNewBool

.noCollide:
	ld b, BOOL_FALSE
	jp PushNewBool


AsmDisableOtherSolid:
	db TYPE_ASM

; Arg 0 is the entity id to disable
	xor a
	call AequIntParam

; todo: verify the slot is in-user
	ld hl, wEntity00_InputCtrl
	and a
	jr z, .foundEntity

	ld de, wEntity01-wEntity00
	:	add hl, de
		dec a
		jr nz, :-

.foundEntity:
	ld a, [hl]
	res ENTCTRL_IS_SOLID, a
	ld [hl], a

	jp PushNewNone


AsmLookOtherDown:
	db TYPE_ASM

; Arg 0 is the entity id to change direction of
	xor a
	call AequIntParam

; todo: verify the slot is in-user
	ld hl, wEntity00_AnimCtr
	and a
	jr z, .foundEntity

	ld de, wEntity01-wEntity00
	:	add hl, de
		dec a
		jr nz, :-

.foundEntity:
; Reset anim to update sprite
	xor a
	ld [hl], a

; Set dir to down
	ld a, l
	add wCurrEntity_Dir-wCurrEntity_AnimCtr
	ld l, a
	jr nc, :+
	inc h
:	ld [hl], DIR_DOWN

	jp PushNewNone


AsmLookDown:
	db TYPE_ASM

	ld a, DIR_DOWN
	ld [wCurrEntity_Dir], a
	xor a
	ld [wCurrEntity_AnimCtr], a

	jp PushNewNone


AsmLoadVwf:
	db TYPE_ASM
	call LoadVwf
	jp PushNewNone


AsmWaitVBlank:
	db TYPE_ASM
	rst WaitVBlank
	jp PushNewNone


AsmShowStatus:
	db TYPE_ASM

; Render status bar via window
; todo: this hardware setup should sit elsewhere
	ld a, 7
	ldh [rWX], a
	ld a, $90-STATUS_BAR_TILE_HEIGHT*8
	ldh [rWY], a
	ldh a, [hLCDC]
	or LCDCF_WIN9C00|LCDCF_WINON
	ldh [hLCDC], a

; Setup stat interrupt to hide objs in the 1st tile row of the status bar
	ld a, _JP
	ld [wStatInterrupt], a
	ld a, LOW(StatInt_TurnOffObjs)
	ld [wStatInterrupt+1], a
	ld a, HIGH(StatInt_TurnOffObjs)
	ld [wStatInterrupt+2], a
	ld a, $90-STATUS_BAR_TILE_HEIGHT*8
	ldh [rLYC], a
	ld a, STATF_LYC
	ldh [rSTAT], a
	ldh a, [rIE]
	or IEF_STAT
	ldh [rIE], a

; todo: flip a flag to say we have status bar controls

; Add the power icons
	ld de, .mtilesFile
	call HLequAddrOfFilenameInDEsSrcLen
	ld a, [hl+]
	ld [wMetatileTableAddr], a
	ld a, [hl]
	ld [wMetatileTableAddr+1], a

	xor a
	ld [wTempRoomLoadBaseTileOrPalIdx], a
	ld b, 5
	ld de, $9c21

	.nextMetatiles:
		push af
		call StoreMetatileTilesOrAttrs
		inc de
		pop af

		inc a
		dec b
		jr nz, .nextMetatiles

	ld a, 1
	ldh [rVBK], a

	ld de, .mattrsFile
	call HLequAddrOfFilenameInDEsSrcLen
	ld a, [hl+]
	ld [wMetatileTableAddr], a
	ld a, [hl]
	ld [wMetatileTableAddr+1], a

	xor a
	ld b, 5
	ld de, $9c21

	.nextMetatileAttrs:
		push af
		call StoreMetatileTilesOrAttrs
		inc de
		pop af

		inc a
		dec b
		jr nz, .nextMetatileAttrs

	xor a
	ldh [rVBK], a

; Turn on the screen
	ldh a, [hLCDC]
	or LCDCF_ON
	ldh [hLCDC], a
	ldh [rLCDC], a
	rst WaitVBlank

	jp PushNewNone

.mtilesFile:
	Str "power_icons_mtiles.bin"

.mattrsFile:
	Str "power_icons_mattrs.bin"


AsmAddPlayerEntity:
	db TYPE_ASM
	ld a, [wPlayerTileX]
	ld b, a
	ld a, [wPlayerTileY]
	ld c, a
	jp _AddEntity


SECTION "Room metatiles", WRAM0, ALIGN[8]
wRoomMetatiles:: ds 16*16 ; do not change

SECTION "Room loading", WRAM0
wMetatileTableAddr: dw
wTempEntityMtilesAddr:: dw
wTempEntityMattrsAddr:: dw
wTempRoomLoadBaseTileOrPalIdx: db
