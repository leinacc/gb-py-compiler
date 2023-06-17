INCLUDE "src/include/defines.asm"

SECTION "Python VM bytecode handlers", ROM0

CallPython::
	xor a
	ldh [hPyStackTop], a

	call InitGbpyModule
	call InitHeap

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
PushStack::
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
	ld l, a
	ld h, HIGH(wPyStackPtrs)
	dec hl

; Check if we need to free data
	ld a, [hl-]
	cp HIGH(wHeapData)
	jr c, .afterFree

	cp HIGH(wHeapData+$1000)
	jr nc, .afterFree

; If so, go from user data to chunk header, and Free the chunk
	push hl
	ld l, [hl]
	ld h, a
	ld de, -6
	add hl, de
	call Free
	pop hl

.afterFree:
	ld a, l
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

	ld a, [hl]
	push af

; Convert A to a 1 or 2-digit string in the data stack
; Malloc'd data = TYPE, 1 or 2 chars, $ff
	ld bc, 3
	cp 10
	jr c, :+
	inc bc
:	call Malloc

	pop bc ; B = int value
	push hl ; push to stack later, a ptr to the text

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
	ld [hl], a

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

; todo: calc string length
	ld bc, $100
	call Malloc
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
	ld [hl], a

	pop hl
	call PushStack
	jp ExecBytecodes


; DE - 1 string
; HL - 1 string
; Return Z flag set if strings match
; Does not preserve regs (DE and HL will be past a terminator if they match)
CheckString::
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


Debug::
	jr @


SECTION "PYVM Hram", HRAM
hPyCodeAddr: dw
hPyConstAddr: dw
hPyNamesAddr: dw
hBytecodeAddr: dw
hPyOpcode: db
hPyParam: db
hFilesDirNextAddr:: dw

; Stack for a single block frame
hPyStackTop:: db

SECTION "PYVM Wram Main", WRAM0, ALIGN[8]
wPyStackPtrs:: ds $100 ; word-sized (low, then high)
wPyVarNames: ds $100 ; word-sized ptrs to data rather than names
