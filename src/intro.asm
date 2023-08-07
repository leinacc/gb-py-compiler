INCLUDE "defines.asm"

SECTION "Intro", ROMX, BANK[$01]

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

	call ShowAbilities

; Load a room's python module
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


SECTION "Crypt 4 4", ROMX, BANK[$02]

INCLUDE "pycompiled/crypt_4_4.asm"

SECTION "Crypt 4 5", ROMX, BANK[$03]

INCLUDE "pycompiled/crypt_4_5.asm"

SECTION "Crypt 5 4", ROMX, BANK[$04]

INCLUDE "pycompiled/crypt_5_4.asm"

SECTION "Crypt 5 5", ROMX, BANK[$05]

INCLUDE "pycompiled/crypt_5_5.asm"


SECTION "World", WRAM0
wWorldRoomX:: db
wWorldRoomY:: db
wWorldArea: db
wPlayerTileX:: db
wPlayerTileY:: db
