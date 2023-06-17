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


rsreset
def TYPE_NONE rb 1
def TYPE_INT rb 1
def TYPE_TUPLE rb 1
def TYPE_STR rb 1
def TYPE_MODULE rb 1
def TYPE_ASM rb 1


TestPythonData:
dw .consts
dw .names
dw .bytecode
.consts:
	dw .const0
	dw .const1
	dw .const2
	dw .const3
	dw .const4
	dw .const5
	dw .const6
	.const0:
		db TYPE_NONE
	.const1:
		db TYPE_INT
		db $00
	.const2:
		db TYPE_TUPLE
		db $03
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		.tupleItem0
			db TYPE_STR
			db "load_tiles", $ff
		.tupleItem1
			db TYPE_STR
			db "print_string", $ff
		.tupleItem2
			db TYPE_STR
			db "wait_vblank", $ff
	.const3:
		db TYPE_STR
		db "ascii.2bpp", $ff
	.const4:
		db TYPE_INT
		db $17
	.const5:
		db TYPE_STR
		db "Hello,\nGBCompo '", $ff
	.const6:
		db TYPE_STR
		db "!", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	.name0:
		db "gbpy", $ff
	.name1:
		db "load_tiles", $ff
	.name2:
		db "print_string", $ff
	.name3:
		db "wait_vblank", $ff
.bytecode:
	db $64, $01
	db $64, $02
	db $6c, $00
	db $6d, $01
	db $7d, $00
	db $6d, $02
	db $7d, $01
	db $6d, $03
	db $7d, $02
	db $01, $00
	db $7c, $00
	db $64, $03
	db $83, $01
	db $7d, $03
	db $64, $04
	db $7d, $04
	db $7c, $01
	db $64, $05
	db $7c, $04
	db $9b, $00
	db $64, $06
	db $9d, $03
	db $7c, $03
	db $83, $02
	db $01, $00
	db $09, $00
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $1a


FileSystem:
	dw .next0
	db "ascii.2bpp", $ff
		dw File0
		dw File0.end-File0
.next0:
	dw $ffff

File0:
	INCBIN "data/ascii.2bpp"
.end:



CallPython:
	xor a
	ldh [hPyStackTop], a
	ldh [hStackDataOffs], a
	ldh [hStackDataOffs+1], a
	ld [wPrintTileCol], a
	ld [wPrintTileCol+1], a

; Python code address in hram
	ld a, l
	ldh [hPyCodeAddr], a
	ld a, h
	ldh [hPyCodeAddr+1], a

; Save ptrs addr
	ld a, [hl+]
	ldh [hPyConstAddr], a
	ld a, [hl+]
	ldh [hPyConstAddr+1], a
	ld a, [hl+]
	ldh [hPyNamesAddr], a
	ld a, [hl+]
	ldh [hPyNamesAddr+1], a
	ld a, [hl+]
	ldh [hBytecodeAddr], a
	ld a, [hl]
	ldh [hBytecodeAddr+1], a

; Get bytecode addr
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	push hl

ExecBytecodes:
	pop hl
	ld a, [hl+]
	ldh [hPyOpcode], a
	ld b, a
	ld a, [hl+]
	ldh [hPyParam], a
	push hl
	ld a, b
	cp $64
	jp z, LoadConst
	cp $6c
	jp z, ImportName
	cp $6d
	jp z, ImportFrom
	cp $7d
	jp z, StoreFast
	cp $01
	jp z, PopTop
	cp $7c
	jp z, LoadFast
	cp $83
	jp z, CallFunction
	cp $09
	jp z, Nope
	cp $71
	jp z, JumpAbsolute
	cp $9b
	jp z, FormatValue
	cp $9d
	jp z, BuildString

	pop hl
	ret


; Returns word ptr in HL (eg ptr to data)
PeekStack:
; Dec word ptr, and have L point to popped word's 'high' (little-endian word ptrs)
	ldh a, [hPyStackTop]
	dec a
	ld l, a

; Load high into A then H, and low into L
	ld h, HIGH(wPyStackPtrs)
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	ret


; Returns word ptr in HL (eg ptr to data)
PopStack:
; Dec word ptr, and have L point to popped word's 'high' (little-endian word ptrs)
	ldh a, [hPyStackTop]
	sub 2
	ldh [hPyStackTop], a
	inc a
	ld l, a

; Load high into A then H, and low into L
	ld h, HIGH(wPyStackPtrs)
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	ret


; HL - word ptr to push (eg ptr to data)
PushStack:
	ldh a, [hPyStackTop]
	ld c, a
	ld b, HIGH(wPyStackPtrs)
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	inc c
	ld a, c
	ldh [hPyStackTop], a
	ret


; Returns HL pointing to the newly-pushed data
PushNewNone:
; HL = curr offset in dynamic stack data
	ldh a, [hStackDataOffs]
	ld l, a
	ldh a, [hStackDataOffs+1]
	add HIGH(wPyStackData)
	ld h, a

	push hl

; Store a None there
	ld a, TYPE_NONE
	ld [hl+], a

; Save the new data offset
	ld a, l
	ldh [hStackDataOffs], a
	ld a, h
	sub HIGH(wPyStackData)
	ldh [hStackDataOffs+1], a

	pop hl
	jp PushStack


; B - int to push
PushNewInt:
; HL = curr offset in dynamic stack data
	ldh a, [hStackDataOffs]
	ld l, a
	ldh a, [hStackDataOffs+1]
	add HIGH(wPyStackData)
	ld h, a
	push hl

; Store an INT:B there
	ld a, TYPE_INT
	ld [hl+], a
	ld a, b
	ld [hl+], a

	ld a, l
	ldh [hStackDataOffs], a
	ld a, h
	sub HIGH(wPyStackData)
	ldh [hStackDataOffs+1], a
	
	pop hl
	jp PushStack


LoadConst:
; HL = address of const items
	ldh a, [hPyConstAddr]
	ld l, a
	ldh a, [hPyConstAddr+1]
	ld h, a

; HL = address of ptr to data
	ldh a, [hPyParam]
	add a
	add l
	ld l, a
	jr nc, :+
	inc h

; Push ptr to data
:	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call PushStack
	jp ExecBytecodes


ImportName:
; HL = 'fromlist'
	call PopStack
	push hl
	call PopStack ; todo: ignore 'absolute/relative import'
	pop hl

; todo: use 'fromlist'
	ld hl, GbpyModule
	call PushStack

	jp ExecBytecodes


ImportFrom:
; todo: this should use param to get a name from co_names[param]
; that name should be pushed to stack
; instead I'll temp use it with the assumption they are 1-3, to get a ptr to the fake GbpyModule
	call PeekStack
	ld a, [hPyParam]
	add a
	dec a
	add l
	ld l, a
	jr nc, :+
	inc h

; Push ptr to asm
:	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call PushStack
	jp ExecBytecodes


StoreFast:
	call PopStack

; BC points to a varname ptr to data
	ldh a, [hPyParam]
	add a
	ld c, a
	ld b, HIGH(wPyVarNames)

; Store the stack word ptr to data in BC
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	jp ExecBytecodes


PopTop:
	ldh a, [hPyStackTop]
	sub 2
	ldh [hPyStackTop], a
	jp ExecBytecodes


LoadFast:
; HL points to a varname ptr to data
	ldh a, [hPyParam]
	add a
	ld l, a
	ld h, HIGH(wPyVarNames)

; Push the ptr to that data
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call PushStack
	jp ExecBytecodes


CallFunction:
; todo: verify correct num params used?

; Have stack point to before the ptr to function (hopefully)
	ldh a, [hPyParam]
	and a
	jr z, .afterDescendingStack

	ld b, a
	:	ldh a, [hPyStackTop]
		sub 2
		ldh [hPyStackTop], a
		dec b
		jr nz, :-

.afterDescendingStack:
	call PopStack
	ld a, [hl+]
	cp TYPE_ASM
	jp nz, Debug

; Jump to HL, then return to ExecBytecodes
; hPyStackTop points to the routine ptr, so params are eg [hPyStackTop]+2
	ld bc, .return
	push bc

	jp hl

.return:
	jp ExecBytecodes


Nope:
	jp ExecBytecodes


JumpAbsolute:
	pop hl
	ldh a, [hBytecodeAddr]
	ld l, a
	ldh a, [hBytecodeAddr+1]
	ld h, a
	ldh a, [hPyParam]
	add a
	add l
	ld l, a
	jr nc, :+
	inc h
:	push hl
	jp ExecBytecodes


FormatValue:
; Take value ptr off stack, turn it into a ptr to its string form
	call PopStack
	ld a, [hl+]
; todo: stringify to other types
	cp TYPE_INT
	jp nz, Debug

	ld b, [hl]

; Convert B to a 1 or 2-digit string in the data stack

; HL = curr offset in dynamic stack data
	ldh a, [hStackDataOffs]
	ld l, a
	ldh a, [hStackDataOffs+1]
	add HIGH(wPyStackData)
	ld h, a
	push hl

; Store a ptr to a string there
	ld a, TYPE_STR
	ld [hl+], a
	ld a, b
	cp 10
	jr c, .doDigit
; Get 10s
	ld c, 0
	:	sub 10
		jr c, .print10s
		inc c
		jr :-
.print10s:
	add 10
	ld b, a
	ld a, c
	add "0"
	ld [hl+], a
	ld a, b
.doDigit:
	add "0"
	ld [hl+], a
	ld a, $ff
	ld [hl+], a

	ld a, l
	ldh [hStackDataOffs], a
	ld a, h
	sub HIGH(wPyStackData)
	ldh [hStackDataOffs+1], a
	
	pop hl
	call PushStack
	jp ExecBytecodes


BuildString:
; Param is number of string components - build them into 1 string, and push

; Have stack point to 1st string, while saving hPyStackTop as if the strings were popped
	ldh a, [hPyParam]
	ld b, a
	:	ldh a, [hPyStackTop]
		sub 2
		ldh [hPyStackTop], a
		dec b
		jr nz, :-

; HL = curr offset in dynamic stack data
	ldh a, [hStackDataOffs]
	ld l, a
	ldh a, [hStackDataOffs+1]
	add HIGH(wPyStackData)
	ld h, a
	push hl

	ld a, TYPE_STR
	ld [hl+], a

; Combines strings
	ldh a, [hPyParam]
	ld b, a
	ldh a, [hPyStackTop]
	ld e, a
	ld d, HIGH(wPyStackPtrs)

	.nextString:
		push bc

		ld a, [de]
		inc de
		ld c, a
		ld a, [de]
		inc de
		ld b, a
		
	; todo: are other types allowed?
		ld a, [bc]
		inc bc
		cp TYPE_STR
		jp nz, Debug

	; Copy string into HL
		.nextChar
			ld a, [bc]
			inc bc
			cp $ff
			jr z, .toNextString

			ld [hl+], a
			jr .nextChar

	.toNextString:
		pop bc
		dec b
		jr nz, .nextString

	ld a, $ff
	ld [hl+], a

; Save stack data offset
	ld a, l
	ldh [hStackDataOffs], a
	ld a, h
	sub HIGH(wPyStackData)
	ldh [hStackDataOffs+1], a

	pop hl
	call PushStack
	jp ExecBytecodes


GbpyModule:
	db TYPE_MODULE
; todo: these are purposely in order in my `main.py`, there should be strings+ptrs
	dw AsmLoadTiles
	dw AsmPrintString
	dw AsmWaitVBlank


AsmLoadTiles:
	db TYPE_ASM

; 1st param = filename
	ldh a, [hPyStackTop]
	add 2
	ld l, a
	ld h, HIGH(wPyStackPtrs)

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a

; Check filename is str
	ld a, [hl+]
	cp TYPE_STR
	jp nz, Debug

	ld d, h
	ld e, l

	ld hl, FileSystem

; Save ptr to next file to check
	ld a, [hl+]
	ldh [hFilesDirNextAddr], a
	ld a, [hl+]
	ldh [hFilesDirNextAddr], a

; Check filename
	push de
	call CheckString
; todo: we're assuming 1 file here
	jr nz, .debug

	pop de

; DE = src of data
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
; BC = len of data
	ld a, [hl+]
	ld c, a
	ld b, [hl]
; todo: this is auto-allocated
	ld hl, $9000
; todo: files should have a size
	call LCDMemcpy

; todo: this is going to be the 1st tile idx from the auto-allocation
	ld b, 0
	jp PushNewInt

.debug:
	ret


AsmPrintString:
	db TYPE_ASM

; 2nd param = starting tile idx
	ldh a, [hPyStackTop]
	add 4
	ld l, a
	ld h, HIGH(wPyStackPtrs)

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a

	ld a, [hl+]
	cp TYPE_INT
	jr nz, .debug

	ld a, [hl]
	ld [wPrintStartingTileIdx], a

; 1st param = string to print
	ldh a, [hPyStackTop]
	add 2
	ld l, a
	ld h, HIGH(wPyStackPtrs)

; HL = pointer to data
	ld a, [hl+]
	ld h, [hl]
	ld l, a

; Check type
; todo: like python, should be able to print non-strs?
.startPrint:
	ld a, [hl+]
	cp TYPE_STR
	jr nz, .debug

	.nextChar:
		ld a, [hl+]
		cp $ff
		jr z, .done

	; todo: more control codes?
		cp $0a
		jr z, .newLine

	; Must not be below $20 (ascii tilesets' starting tile)
		cp $20
		jr c, .debug

	; After sub, $5f is invalid, and no other chars past it
		sub $20
		cp $5f
		jr nc, .debug

		push hl
		push af

	; HL points to dest for tile row
		ld a, [wPrintTileRow]
		ld h, HIGH(TileRowTilemapStarts)
		add a
		add LOW(TileRowTilemapStarts)
		ld l, a

	; HL = dest for tile row
		ld a, [hl+]
		ld h, [hl]
		ld l, a

	; Add tile col
		ld a, [wPrintTileCol]
		inc a
		ld [wPrintTileCol], a
		dec a
		add l
		ld l, a

	; Print tile
		wait_vram
		pop af
		ld [hl], a
		pop hl
		jr .nextChar

	.newLine:
		ld a, [wPrintTileRow]
		inc a
		ld [wPrintTileRow], a
		xor a
		ld [wPrintTileCol], a
		jr .nextChar

.done:
	jp PushNewNone

.debug:
	ret


AsmWaitVBlank:
	db TYPE_ASM
	call WaitVBlank
	jp PushNewNone


TileRowTilemapStarts:
FOR N, SCRN_Y_B
	dw _SCRN0+N*$20
ENDR


; DE - 1 string
; HL - 1 string
; Return Z flag set if strings match
; Does not preserve regs (DE and HL will be past a terminator if they match)
CheckString:
.nextChar:
; If [hl] and [de] are both $ff, they matched til now, and terminated at the same time
	ld a, [hl+]
	cp $ff
	jr z, .checkZended

	ld b, a

; If [de] == $ff, [hl] wasn't, so it's no match
	ld a, [de]
	inc de
	cp $ff
	jr z, .nomatch

; If any character doesn't match, jump
	cp b
	jr nz, .nomatch

	jr .nextChar

.checkZended:
	ld a, [de]
	inc de
	cp $ff
	jr nz, .nomatch

.match:
	xor a
	ret

.nomatch:
	ld a, 1
	and a
	ret


Debug:
	jr @


SECTION "PYVM Hram", HRAM
hPyCodeAddr: dw
hPyConstAddr: dw
hPyNamesAddr: dw
hBytecodeAddr: dw
hPyOpcode: db
hPyParam: db
hFilesDirNextAddr: dw

hPyStackTop: db
hStackDataOffs: dw

SECTION "PYVM Wram Main", WRAM0, ALIGN[8]
wPyStackPtrs: ds $100 ; word-sized (low, then high)
wPyStackData: ds $1000
wPyVarNames: ds $100 ; word-sized ptrs to data rather than names

SECTION "PYVM Wram Print", WRAM0
wPrintStartingTileIdx: db
wPrintTileCol: db
wPrintTileRow: db
