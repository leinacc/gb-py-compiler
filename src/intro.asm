INCLUDE "defines.asm"

SECTION "Intro", ROMX

Intro::
; todo: use hConsoleType to display a CGB-only screen

	rst WaitVBlank

	ld a, $01
	ldh [hCanSoftReset], a

; Init sub-engines
	call InitEntites
	call InitDynamicAllocation

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

; Display sprites globally
	ldh a, [hLCDC]
	or LCDCF_OBJON
	ldh [hLCDC], a

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

; test: load a sample room
	ld a, BANK(PyBlock__module_)
	ld hl, PyBlock__module_
	call LoadModule

:	rst WaitVBlank
	jr :-


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


INCLUDE "pycompiled/test.asm"
