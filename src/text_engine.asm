INCLUDE "defines.asm"

SECTION "Text Engine Code", ROMX

NUM_VWF_PALS equ 4
COL_VWF_TEXT_BG_COL equ $2525 ; #2f4f4f

LoadVwf::
; Set all pixel column colors as unused
	ld hl, wVWFPixelCurrColors
	ld a, $ff
	ld bc, 8*2*(SCRN_X_B-2)
	rst Memset

; Clear 1bpp buffer
	ld hl, wVWFText1bpp
	xor a
	ld bc, 8*2*(SCRN_X_B-2)
	rst Memset

; Clear pals in use
	ld hl, wPalettesInUse
	ld c, NUM_VWF_PALS
	rst MemsetSmall

; Clear text vram buffer
	ld hl, $8800
	ld bc, $10*(SCRN_X_B-2)*2
	rst Memset

; Init text engine and set HL = addr of text data
	xor a
	ldh [hTextPalIdx], a
	ldh [hVWFPixelColIdx], a
	ld [wVWFIs2ndRow], a

	call VwfloadString
	call VWFassociatePalettes
	call VWFcreateShadowPals
	call VWFfillTiles
	call VwfsetupTilemap

; todo: this hardware setup should sit elsewhere
	ld a, 7
	ldh [rWX], a
	ld a, $90-(8*4)
	ldh [rWY], a
	ldh a, [hLCDC]
	or LCDCF_WIN9C00|LCDCF_WINON
	ldh [hLCDC], a

	ret



VwfloadString:
	call HLequAddrOfFuncParam

	ld a, [hl+]
	cp TYPE_STR
	jp nz, Debug

; Pass string length
	inc hl

; Step 1: Load string in hl, terminating in $ff. \t ($09) is a control code for
; palettes, the following ascii num is the palette idx
	.nextChar:
	    ld a, [hl+]
	    cp $09
	    jr z, .setPalette
	    cp $ff
	    ret z

	    push hl
	    sub $20
	    ldh [hCurrCharIdx], a
	    call GetCurrCharWidth

	; Fill pixel col array if not space
	    ldh a, [hCurrCharIdx]
	    and a
	    call nz, FillPixelColArray

	    call Fill1bppTile
	    call SetNextColPixel

	    pop hl
	    jr .nextChar

	.setPalette:
	    ld a, [hl+]
	    sub $30
	    ldh [hTextPalIdx], a
	    jr .nextChar


VWFassociatePalettes:
; Step 2: understand what colors each tile uses
	ld hl, wVWFPixelCurrColors
	ld de, wTileToPalsMap
	ld c, 2*(SCRN_X_B-2)
	ld b, 8 ; for the colors in a tile

	.nextTile:
	; C to contain the combined colors
	    push bc
	    ld c, 0

	    .nextCol:
	        ld a, [hl+]
	        cp $ff
	        jr z, .toNextCol

	        or c
	        ld c, a

	    .toNextCol:
	        dec b
	        jr nz, .nextCol

	; Try to allocate a palette for it
	    push hl
	    ld hl, wPalettesInUse
	    ld b, NUM_VWF_PALS
	    .nextPalette:
	        ld a, [hl]
	        or c
	        call AequNumBitsUsed
	        cp 4
	        jr c, .useCurrPalette

	        inc hl
	        dec b
	        jr nz, .nextPalette
	        jp Debug

	.useCurrPalette:
	; Set any new colors for the palette
	    ld a, [hl]
	    or c
	    ld [hl], a

	; Get the palette idx chosen
	    ld a, l
	    sub LOW(wPalettesInUse)
	    ld [de], a
	    inc de

	; HL points to the 8 colors for the next tile
	    pop hl
	    pop bc
	    dec c
	    jr nz, .nextTile

	ret


VWFcreateShadowPals:
	ld hl, wVWFShadowBGPals
	ld de, wPalettesInUse
	ld c, NUM_VWF_PALS

	.nextPalette:
	; 1st color of each palette is dark slate grey
	    ld a, LOW(COL_VWF_TEXT_BG_COL)
	    ld [hl+], a
	    ld a, HIGH(COL_VWF_TEXT_BG_COL)
	    ld [hl+], a

	; Fill the other 3 based on bits used
	    ld a, [de]
	    inc de
	    push de

	    ld de, RainbowColors
	    ld b, 8

	    .nextShift:
	        srl a
	        jr nc, .ignoreRainbowCol

	    ; Copy in word color
	        push af
	        ld a, [de]
	        inc de
	        ld [hl+], a
	        ld a, [de]
	        inc de
	        ld [hl+], a
	        pop af
	        jr .toNextShift

	    .ignoreRainbowCol:
	        inc de
	        inc de

	    .toNextShift:
	        dec b
	        jr nz, .nextShift

	    pop de
	    dec c
	    jr nz, .nextPalette

; Load into palette registers
	ld hl, wVWFShadowBGPals
	ld b, 8*NUM_VWF_PALS
	ld a, [wCurrBGPalette]
	add a
	add a
	add a
	or BCPSF_AUTOINC
	ldh [rBCPS], a
	ld c, LOW(rBCPD)
	.nextColByte:
		wait_vram
		ld a, [hl+]
		ldh [c], a
		dec b
		jr nz, .nextColByte

	ret


VWFfillTiles:
	ld hl, wTileToPalsMap
	ld de, wVWFPixelCurrColors
	ld b, 2*(SCRN_X_B-2)
	xor a
	ld [wVWFIs2ndRow], a
	ldh [hVWFPixelColIdx], a
	ld c, 8

	.nextTile:
	    push bc

	    ld a, $80
	    ldh [hVWFCurrPixelColumnBitflag], a

	; A = the palette idx for the tile (0 to 3)
	    ld a, [hl+]
	    push hl

	; B = the palette bitfield value used for the entire tile
	    ld hl, wPalettesInUse
	    add l
	    ld l, a
	    jr nc, :+
	    inc h
	:   ld b, [hl]

	; Set the tile dest for each pixel column
	    call HLequVWFTextDest

	    .nextPixelCol:
	    ; A = a bitfield value for the color, eg $01 to $80
	        ld a, [de]
	        inc de
	        cp $ff
	        jr z, .toNextPixelCol

	    ; Determine its idx in the tile's entire palette
	        dec a
	        and b
	        call AequNumBitsUsed
	        inc a
	        call FillTextBufferForPixelColumn

	    .toNextPixelCol:
	        ldh a, [hVWFCurrPixelColumnBitflag]
	        srl a
	        ldh [hVWFCurrPixelColumnBitflag], a

	        ldh a, [hVWFPixelColIdx]
	        inc a
	        ldh [hVWFPixelColIdx], a

	        dec c
	        jr nz, .nextPixelCol

	; To next tile
	    pop hl
	    pop bc
	    dec b
	    jr nz, .nextTile

	ret


VwfsetupTilemap:
; Palettes (todo: it's just 1 row atm)
	ld a, 1
	ldh [rVBK], a

; Clear palettes
	ld hl, $9c00
	ld a, [wCurrBGPalette]
	ld c, SCRN_VX_B*4
	call LCDMemsetSmall

	ld hl, $9c21
	ld de, wTileToPalsMap
	ld b, (SCRN_X_B-2)
	ld c, a

	.nextTile:
	    ld a, [de]
	    inc de
	    add c
	    push af
	    wait_vram
	    pop af
	    ld [hl+], a

	    dec b
	    jr nz, .nextTile

	xor a
	ldh [rVBK], a

; Clear tilemap
	ld hl, $9c00
	ld a, $ff
	ld c, SCRN_VX_B*4
	call LCDMemsetSmall

; 1st text row
	ld hl, $9c21
	ld a, $80
	ld b, (SCRN_X_B-2)
	.nextCol1:
	    push af
	    wait_vram
	    pop af
	    ld [hl+], a
	    inc a

	    dec b
	    jr nz, .nextCol1
	push af

; 2nd text row
	ld hl, $9c41
	pop af
	ld b, (SCRN_X_B-2)
	.nextCol2:
	    push af
	    wait_vram
	    pop af
	    ld [hl+], a
	    inc a

	    dec b
	    jr nz, .nextCol2

	ret


; A - color idx (1 to 3)
; HL - vram tile data dest
; Trashes A
FillTextBufferForPixelColumn:
	push de
	push bc

	push af
	and $01
	call nz, _FillBitplaneForPixelColumn
	pop af
	inc hl
	and $02
	call nz, _FillBitplaneForPixelColumn
	dec hl

	pop bc
	pop de
	ret


; HL - vram tile data dest for the bitplane
; Trashes A, BC and DE
_FillBitplaneForPixelColumn:
	push hl

	ld c, 8
	call DEequ1bppTextAddr
	ldh a, [hVWFCurrPixelColumnBitflag]
	ld b, a

	.nextPixelRow:
	    wait_vram
	    ld a, [de]
	    and b
	    or [hl]
	    ld [hl+], a

	    inc de
	    inc hl
	    dec c
	    jr nz, .nextPixelRow

	pop hl
	ret


; Trashes A
HLequVWFTextDest:
	ld hl, $8800
	ld a, [wVWFIs2ndRow]
	and a
	jr z, :+
	ld hl, $8800+($10*(SCRN_X_B-2))
:   ldh a, [hVWFPixelColIdx]
	and $f8
	add a
	jr nc, :+
	inc h
:   add l
	ld l, a
	ret nc
	inc h
	ret


TileRowTilemapStarts:
FOR N, SCRN_Y_B
	dw _SCRN1+N*$20+1
ENDR


; A - curr char idx-$20
; Trashes A and HL
GetCurrCharWidth:
	ld h, HIGH(CharWidths)
	add LOW(CharWidths)
	ld l, a
	jr nc, :+
	inc h
:   ld a, [hl]
	ldh [hCurrCharPxWidth], a
	ret


; hCurrCharPxWidth
; hTextPalIdx
; hVWFPixelColIdx
; todo: wVWFIs2ndRow
; Trashes A, C and HL
FillPixelColArray:
; Get palette bitfield
	ldh a, [hTextPalIdx]
	ld h, HIGH(BitfieldMap)
	add LOW(BitfieldMap)
	ld l, a
	jr nc, :+
	inc h
:   ld a, [hl]
	push af

; HL = addr of 1st pixel to fill for
	ldh a, [hVWFPixelColIdx]
	ld h, HIGH(wVWFPixelCurrColors)
	add LOW(wVWFPixelCurrColors)
	ld l, a
	jr nc, :+
	inc h

; C = num pixels to fill
:   ldh a, [hCurrCharPxWidth]
	ld c, a

; Fill with palette idx
	pop af
	rst MemsetSmall
	ret


; Trashes A and B
SetNextColPixel:
	ldh a, [hVWFPixelColIdx]
	ld b, a
	ldh a, [hCurrCharPxWidth]
	add b
	inc a
	ld [hVWFPixelColIdx], a
	ret


; hCurrCharIdx - curr char idx-$20
; Trashes A, BC and HL
Fill1bppTile:
	ldh a, [hCurrCharIdx]

; BC = A * 8
	ld b, 0
	add a
	add a
	rl b
	add a
	rl b
	ld c, a

; HL = src to fill
	ld hl, Ascii
	add hl, bc

	call DEequ1bppTextAddr

; Loop through 8 1bpp bytes
:   ld b, 8
	ldh a, [hVWFPixelColIdx]
	and $07
	ld c, a

	.nextPxRow:
	    push bc
	    ld a, [hl+]
	    push hl

	    ld l, 0
	    inc c

	    .nextShift:
	        dec c
	        jr z, .afterRotates
	        srl a
	        rr l
	        jr .nextShift

	.afterRotates:
	    ld h, a
	    ld a, [de]
	    or h
	    ld [de], a
	    inc de
	    push de

	; todo: extend buffer slightly for when the last tile overspills
	    ld a, 7
	    add e
	    ld e, a
	    jr nc, :+
	    inc d

	:   ld a, l
	    ld [de], a

	; To next pixel row, restore dest of that new row (DE),
	; the src of the next tile data (HL),
	; the number of pixel rows left (B), and the pixel shift value (C)
	    pop de
	    pop hl
	    pop bc
	    dec b
	    jr nz, .nextPxRow

	ret


; Trashes A
DEequ1bppTextAddr:
; DE = dest for the row
	ld de, wVWFText1bpp
	ld a, [wVWFIs2ndRow]
	and a
	jr z, :+
	ld de, wVWFText1bpp+8*(SCRN_X_B-2)

; Add on dest for the pixel column
; // 8 to get the chosen tile, then * 8 to get offset for the tile
; DE = dest tile for the char
:   ldh a, [hVWFPixelColIdx]
	and $f8
	add e
	ld e, a
	ret nc
	inc d
	ret


Ascii:
	INCBIN "res/optix.1bpp"


AequNumBitsUsed:
	push hl
	ld hl, BitsPerByte
	add l
	ld l, a
	jr nc, :+
	inc h
:   ld a, [hl]
	pop hl
	ret


BitfieldMap:
	db $01, $02, $04, $08, $10, $20, $40, $80


; Excludes space after
CharWidths:
	db 2, 2, 4, 5, 4, 4, 6, 2, 2, 2, 5, 5, 2, 4, 2, 4 ; the last 2 is actually 1
	db 4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 3, 4, 3, 3
	db 7, 5, 4, 4, 4, 5, 4, 5, 5, 3, 5, 5, 5, 7, 5, 5
	db 4, 5, 4, 5, 5, 5, 5, 7, 4, 4, 5, 3, 4, 3, 5, 5
	db 2, 4, 4, 4, 4, 4, 3, 4, 4, 2, 3, 4, 3, 5, 4, 4
	db 4, 4, 4, 4, 3, 4, 5, 5 ,4, 4 ,4, 3, 2, 3, 5, 5 ; the last 2 is actually 1


BitsPerByte:
	db 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4
	db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
	db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
	db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
	db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
	db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
	db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
	db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
	db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
	db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
	db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
	db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
	db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
	db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
	db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7
	db 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8


RainbowColors:
; white then roygbiv
	dw $7fff, $001f, $01ff, $03ff
	dw $03e0, $7c00, $4009, $6812


SECTION "Text Engine Hram", HRAM

hTextPalIdx: db
hCurrCharPxWidth: db
hVWFPixelColIdx: db
hCurrCharIdx: db ; -$20
hVWFCurrPixelColumnBitflag: db


SECTION "Text Engine Wram", WRAM0

; 2-bordered lines
; 8 bytes per tile * 2 rows * tiles within border
wVWFText1bpp: ds 8*2*(SCRN_X_B-2)
wVWFIs2ndRow: db ; when loading text, not populating it
; 8 pixel cols per tile * 2 tiles * tiles within border
; Contains bitfield values $01 to $80
wVWFPixelCurrColors: ds 8*2*(SCRN_X_B-2)

wPalettesInUse: ds NUM_VWF_PALS
wTileToPalsMap: ds 2*(SCRN_X_B-2)

wVWFShadowBGPals: ds 2*4*NUM_VWF_PALS ; 4 color words * num palettes used
