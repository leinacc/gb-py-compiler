INCLUDE "defines.asm"

SECTION "Intro", ROMX

Intro::
; todo: use hConsoleType to display a CGB-only screen
; todo: set hOAMHigh = HIGH(wShadowOAM) so that vblank can transfer oam
; todo: use hHeldKeys and hPressedKeys
	ld a, $01
	ldh [hCanSoftReset], a

; Init GBC palettes
	ld a, BCPSF_AUTOINC
	ldh [rBCPS], a
	ld e, 8
	ld c, LOW(rBCPD)
	.nextPalette:
		ld hl, GrayscalePals
		ld d, 8
		.nextColByte:
			wait_vram
			ld a, [hl+]
			ldh [c], a
			dec d
			jr nz, .nextColByte

		dec e
		jr nz, .nextPalette

; Clear screen
	ld hl, _SCRN0
	ld bc, $400
	xor a
	call LCDMemset

	ld a, BANK(PyBlock__module_)
	ld hl, PyBlock__module_
	call LoadModule
	jr @


GrayscalePals:
	dw $7fff, $0000, $7fff, $7fff


INCLUDE "pycompiled/test.asm"
