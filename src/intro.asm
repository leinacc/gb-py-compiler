INCLUDE "defines.asm"

SECTION "Intro", ROMX

Intro::
; todo: use hConsoleType to display a CGB-only screen

	rst WaitVBlank

	ld a, $01
	ldh [hCanSoftReset], a

; Display sprites globally
	ldh a, [hLCDC]
	or LCDCF_OBJON
	ldh [hLCDC], a

; Load the starting room
	ld a, 5
	ld [wPlayerTileX], a
	ld a, 6
	ld [wPlayerTileY], a

	ld a, WORLD_CRYPT
	ld [wWorldArea], a
	ld a, 5
	ld [wWorldRoomX], a
	ld [wWorldRoomY], a

	jp LoadNewRoom


LoadNewRoom::
; Turn off screen
	ld sp, wStackBottom
	ldh a, [hLCDC]
	and ~LCDCF_ON
	ldh [hLCDC], a

; Clear OAM
	ld hl, wShadowOAM
	ld c, $a0
	ld a, $ff
	rst MemsetSmall

	ld a, h
	ldh [hOAMHigh], a

	rst WaitVBlank

; Init sub-engines
	call InitEntites
	call InitDynamicAllocation

; Init interrupts
	ld a, _RETI
	ld [wStatInterrupt], a
	ldh [hTimerInterrupt], a

; Clear screens, and attrs, allocating a palette for the 2nd screen
	ld hl, _SCRN0
	ld bc, $800
	ld a, $ff
	call LCDMemset

	ld a, 1
	ldh [rVBK], a

	ld hl, _SCRN0
	ld bc, $800
	ld a, [wCurrBGPalette]
	call LCDMemset
	ldh [rVBK], a

; Show abilities
	ld de, PowerIconsTileData
	call HLequAddrOfFilenameInDEsSrcLen
	call AllocateBGTileData

	ld de, PowerIconsPalettes
	call HLequAddrOfFilenameInDEsSrcLen
	call AllocateBGPalettes

	ld hl, PowerIconsSelectSpriteTiles
	call AllocateOBJTileData

	ld hl, PowerIconsSelectSpritePals
	call AllocateOBJPalettes

	jp LoadRoomModule


LoadRoomModule:
; todo: index on a table based on world area
	ld hl, CryptRooms
	ld a, [wWorldRoomX]
	ld b, a
	ld a, [wWorldRoomY]
	ld c, a
	ld de, 4

	.nextRoom:
		ld a, [hl+]
		cp $ff
		jp z, Debug

		push hl
		cp b
		jr nz, .toNextRoom

		ld a, [hl+]
		cp c
		jr z, .foundRoom

	.toNextRoom:
		pop hl
		add hl, de
		jr .nextRoom

.foundRoom:
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, b
	jp LoadModule


CryptRooms:
	db 4, 4, BANK(PyBlock_crypt_4_4__module_)
		dw PyBlock_crypt_4_4__module_
	db 4, 5, BANK(PyBlock_crypt_4_5__module_)
		dw PyBlock_crypt_4_5__module_
	db 5, 4, BANK(PyBlock_crypt_5_4__module_)
		dw PyBlock_crypt_5_4__module_
	db 5, 5, BANK(PyBlock_crypt_5_5__module_)
		dw PyBlock_crypt_5_5__module_
	db $ff


PowerIconsTileData:
	Str "power_icons.2bpp"

PowerIconsPalettes:
	Str "power_icons.pal"

PowerIconsSelectSpriteTiles:
	dw .src
	dw .end-.src

.src:
rept 8
	db $00, $ff
endr
rept 8
	db $ff, $ff
endr
.end:

PowerIconsSelectSpritePals:
	dw .src
	dw .end-.src

.src:
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


INCLUDE "pycompiled/crypt_4_4.asm"
INCLUDE "pycompiled/crypt_4_5.asm"
INCLUDE "pycompiled/crypt_5_4.asm"
INCLUDE "pycompiled/crypt_5_5.asm"


SECTION "World", WRAM0
wWorldRoomX:: db
wWorldRoomY:: db
wWorldArea: db
wPlayerTileX:: db
wPlayerTileY:: db
