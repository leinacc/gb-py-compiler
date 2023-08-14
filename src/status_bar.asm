INCLUDE "defines.asm"

SECTION "Status bar", ROM0

ShowAbilities::
	ldh a, [hCurROMBank]
	push af

; Show abilities
	ld hl, PowerIconsTileData
	call GetSrcOfFileInHL
	call FarAllocateBGTileData

	ld hl, PowerIconsPalettes
	call GetSrcOfFileInHL
	call FarAllocateBGPalettes

	ld hl, PowerIconsSelectSpriteTiles
	call AllocateOBJTileData

	ld hl, PowerIconsSelectSpritePals
	call AllocateOBJPalettes

    pop af
    ldh [hCurROMBank], a
    ld [rROMB0], a
    ret


PowerIconsTileData:
	Str "power_icons.2bpp"

PowerIconsPalettes:
	Str "power_icons.pal"

PowerIconsSelectSpriteTiles:
	dw .end-.start
.start:
rept 8
	db $00, $ff
endr
rept 8
	db $ff, $ff
endr
.end:

PowerIconsSelectSpritePals:
	dw .end-.start
.start:
	dw STATUS_SCREEN_MAIN_COL
	dw STATUS_SCREEN_MAIN_COL
	dw $7fff ; white
	dw $001f ; red
.end:


StatInt_TurnOffObjs::
	push af
	ldh a, [rLCDC]
	and ~LCDCF_OBJON
	ldh [rLCDC], a

	ld a, $90-STATUS_BAR_TILE_HEIGHT*8+8
	ldh [rLYC], a
	ld a, LOW(StatInt_TurnOnObjs)
	ld [wStatInterrupt+1], a
	ld a, HIGH(StatInt_TurnOnObjs)
	ld [wStatInterrupt+2], a

	pop af
	reti


StatInt_TurnOnObjs::
	push af
	ldh a, [rLCDC]
	or LCDCF_OBJON
	ldh [rLCDC], a

	ld a, $90-STATUS_BAR_TILE_HEIGHT*8
	ldh [rLYC], a
	ld a, LOW(StatInt_TurnOffObjs)
	ld [wStatInterrupt+1], a
	ld a, HIGH(StatInt_TurnOffObjs)
	ld [wStatInterrupt+2], a

	pop af
	reti
