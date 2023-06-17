INCLUDE "src/include/defines.asm"

SECTION "Intro", ROMX

Intro::
	ld a, $0c
	ldh [hBGP], a

	ld hl, _SCRN0
	ld bc, $400
	xor a
	call LCDMemset

	ld hl, TestPythonData
	call CallPython
	jr @


INCLUDE "pycompiled/test.asm"
