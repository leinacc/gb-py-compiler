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

	ldh a, [hLCDC]
	or LCDCF_OBJON
	ldh [hLCDC], a

; test: load a sample room
	ld a, BANK(PyBlock__module_)
	ld hl, PyBlock__module_
	call LoadModule

:	rst WaitVBlank
	jr :-


INCLUDE "pycompiled/test.asm"
