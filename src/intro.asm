INCLUDE "defines.asm"

SECTION "Intro", ROMX

Intro::
	ld a, $0c
	ldh [hBGP], a

	ld hl, _SCRN0
	ld bc, $400
	xor a
	call LCDMemset

	ld hl, PyBlock__module_
	call CallPython

	xor a
	call CallName
	jr @


INCLUDE "pycompiled/test.asm"
