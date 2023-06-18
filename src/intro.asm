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
	call LoadModule

	ld de, .main
	call CallName
	jr @

.main:
	db $05, "main", $ff


INCLUDE "pycompiled/test.asm"
