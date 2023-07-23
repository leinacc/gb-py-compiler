INCLUDE "defines.asm"

SECTION "Intro", ROMX

Intro::
; todo: use hConsoleType to display a CGB-only screen

	rst WaitVBlank

	ld a, $01
	ldh [hCanSoftReset], a

; Clear screen
	ld hl, _SCRN0
	ld bc, $400
	ld a, $ff
	call LCDMemset

; Init sub-engines
	call InitEntites
	call InitDynamicAllocation

	ldh a, [hLCDC]
	or LCDCF_OBJON
	ldh [hLCDC], a

; Show abilities
	ld de, PowerIconsTileData
	call HLequAddrOfFilenameInDE
	call AllocateBGTileData

	ld de, PowerIconsPalettes
	call HLequAddrOfFilenameInDE
	call AllocateBGPalettes
; todo: display on 2nd screen

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


INCLUDE "pycompiled/test.asm"
