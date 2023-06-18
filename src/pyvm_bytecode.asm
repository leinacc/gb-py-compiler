INCLUDE "defines.asm"

SECTION "Python VM bytecode handlers", ROM0

; todo - input should be a proper name
; A - co_names idx
CallName::
; HL points to a name ptr to data
	add a
	ld l, a
	ld h, HIGH(wPyLocalNames)

; HL = a ptr to the address of the function block
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; HL = the address of the function block
    ld a, [hl+]
    ld h, [hl]
    ld l, a

CallPython::
	xor a
	ldh [hPyStackTop], a
    ldh [hCallStackTop], a

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
	cp $01
	jp z, PopTop
    cp $09
	jp z, Nope
    cp $53
    jp z, ReturnValue
    cp $5a
    jp z, StoreName
    cp $64
	jp z, LoadConst
	cp $6c
	jp z, ImportName
	cp $6d
	jp z, ImportFrom
    cp $71
	jp z, JumpAbsolute
	cp $7c
	jp z, LoadFast
    cp $7d
	jp z, StoreFast
	cp $83
	jp z, CallFunction
    cp $84
    jp z, MakeFunction
	cp $9b
	jp z, FormatValue
	cp $9d
	jp z, BuildString

	pop hl
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
; This should uses a param to get a name from co_names[param]
; The thing that name points to should be pushed to stack
	call PeekStack

; todo: allow other types, like regular modules
    ld a, [hl+]
    cp TYPE_GBPY_MODULE
    jp nz, Debug

    push hl

; HL = address of names
	ldh a, [hPyNamesAddr]
	ld l, a
	ldh a, [hPyNamesAddr+1]
	ld h, a

; HL = address of ptr to data
	ldh a, [hPyParam]
	add a
	add l
	ld l, a
	jr nc, :+
	inc h

; HL = address of name string to find
:   ld a, [hl+]
    ld e, a
    ld d, [hl]

    pop hl

.nextString:
; Save ptr to next file to check
	ld a, [hl+]
	ldh [hStringTableNextAddr], a
	ld a, [hl+]
	ldh [hStringTableNextAddr+1], a

    push de
    call CheckString
    pop de
    jr z, .storePtr

; To next string
    ldh a, [hStringTableNextAddr]
    ld l, a
    ldh a, [hStringTableNextAddr+1]
    ld h, a
    cp $ff
    jp z, Debug

    jr .nextString

.storePtr:
; Push ptr to asm type
    ld a, [hl+]
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
	ld b, HIGH(wPyFastNames)

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
	ld h, HIGH(wPyFastNames)

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


MakeFunction:
; TOS - qualified name of function
; TOS1 - ptr to function block
; Pushes function object to stack
    call PopStack
; Skip PopStack / PushStack
    jp ExecBytecodes


Nope:
	jp ExecBytecodes


ReturnValue:
; todo: call stack returns
    ldh a, [hCallStackTop]
    and a
    jp nz, Debug

; Return from python vm
    pop hl
    ret


StoreName:
	call PopStack

; BC points to a name ptr to data
	ldh a, [hPyParam]
	add a
	ld c, a
	ld b, HIGH(wPyLocalNames)

; Store the stack word ptr to data in BC
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
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
; Malloc'd data = TYPE, length byte, 1 or 2 chars, $ff
	ld bc, 4
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
    ld c, 2
	cp 10
	jr c, .doDigit

; Store string length, including $ff
    inc c
    ld [hl], c
    inc hl

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

.digitOnly:
; Store string length, including $ff
    ld [hl], c
    inc hl
    jr .doDigit


BuildString:
; Param is number of string components - build them into 1 string, and push
; C = malloc length - TYPE, length byte, string length, $ff
; 3 = all but string length
    ld c, 3

; Have stack point to 1st string, while saving hPyStackTop as if the strings were popped
	ldh a, [hPyParam]
	ld b, a
	:	ldh a, [hPyStackTop]
		sub 2
		ldh [hPyStackTop], a
        ld h, HIGH(wPyStackPtrs)
        ld l, a
    ; HL now points to a ptr to a string?
        ld a, [hl+]
        ld h, [hl]
        ld l, a

        ld a, [hl+]
        cp TYPE_STR
        jp nz, Debug

    ; Add the string length, excluding the $ff, onto C
        ld a, [hl]
        dec a
        add c
        ld c, a

		dec b
		jr nz, :-

; BC = $00<string length>
    push bc
	call Malloc
    pop bc
	push hl

	ld a, TYPE_STR
	ld [hl+], a
    ld a, c
    dec a
    dec a
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

    ; Skip length
        inc bc

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


SECTION "PYVM Hram", HRAM

; Values for a single block frame
hPyCodeAddr: dw ; todo: use to restore the below 3
hPyConstAddr: dw
hPyNamesAddr: dw
hBytecodeAddr: dw
hPyStackTop:: db

hPyOpcode: db
hPyParam: db
; For generic singly-linked list string tables
hStringTableNextAddr:: dw

; Call stack which 1st points to a global frame
hCallStackTop: db

SECTION "PYVM Wram Main", WRAM0, ALIGN[8]
wPyStackPtrs:: ds $100 ; word-sized (low, then high)
wPyFastNames: ds $100 ; word-sized ptrs to 'fast' data rather than names
wPyLocalNames: ds $100 ; word-sized ptrs to 'local' data rather than names
wCallStackPtrs: ds $100 ; word-sized (low, then high)
