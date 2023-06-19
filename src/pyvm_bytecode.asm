INCLUDE "defines.asm"

SECTION "Python VM bytecode handlers", ROM0

; A - rom bank of module to load
; HL - address of module to load
LoadModule::
	ldh [hCurROMBank], a
	ld [rROMB0], a

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

    call HeapifyNames

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
    cp $17
    jp z, BinaryAdd
    cp $53
    jp z, ReturnValue
    cp $5a
    jp z, StoreName
    cp $64
	jp z, LoadConst
    cp $65
    jp z, LoadName
	cp $6c
	jp z, ImportName
	cp $6d
	jp z, ImportFrom
    cp $71
	jp z, JumpAbsolute
    cp $74
    jp z, LoadGlobal
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
	jp Debug


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

; DE = address of name string to find
:   ld a, [hl+]
    ld e, a
    ld d, [hl]

    pop hl

; Each name has a word ptr after it
	ld a, 2
	ldh [hStringListExtraBytes], a
	call HLequAfterMatchingNameInList

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
    add LOW(wPyFastNames)
	ld c, a
	ldh a, [hCallStackTop]
	add HIGH(wPyFastNames)
	ld b, a

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
    ldh a, [hCallStackTop]
	add HIGH(wFrameStackPtrs)
    ld h, a
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
    add LOW(wPyFastNames)
	ld l, a
	ldh a, [hCallStackTop]
	add HIGH(wPyFastNames)
	ld h, a

; Push the ptr to that data
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call PushStack
	jp ExecBytecodes


CallFunction:
; todo: verify correct num params used?

; Have stack point to after the ptr to function
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
    jr z, .doAsm

    cp TYPE_FUNCTION
    jr z, _StartNewFrameStack

	jp Debug

.doAsm:
; Jump to HL, then return to ExecBytecodes
; hPyStackTop points to the routine ptr, so params are eg [hPyStackTop]+2
	ld bc, .return
	push bc

	jp hl

.return:
	jp ExecBytecodes


; HL - points to the address of a function block
_StartNewFrameStack:
; Save prev stack top to get values to add to new function's fast vars
    ldh a, [hPyStackTop]
    add 2
    push af

    push hl

; Save prev stack
    ldh a, [hCallStackTop]
    swap a
    add LOW(wCallStackSavedVars)
    ld l, a
    ld h, HIGH(wCallStackSavedVars)
    ld de, hPyCodeAddr
    ld c, hPyOpcode-hPyCodeAddr
    rst MemcpySmall

; Start on a new frame
    ldh a, [hCallStackTop]
    inc a
    ldh [hCallStackTop], a

; HL = address of the function block
    pop hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; Init frame
    xor a
    ldh [hPyStackTop], a

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

; E = prev stack top
    pop af
    ld e, a

; Return to .return
    ld bc, .execBytecode
    push bc

; Get bytecode addr
	ld a, [hl-]
	ld l, [hl]
	ld h, a
	push hl

; Store fast values, DE = prev frame's stack where the fast values are
	ldh a, [hPyParam]
    add a
    jr z, .execBytecode
	ld c, a

    ldh a, [hCallStackTop]
    dec a
	add HIGH(wFrameStackPtrs)
	ld d, a

; HL = where to store the fast names
    ld l, LOW(wPyFastNames)
	ldh a, [hCallStackTop]
	add HIGH(wPyFastNames)
	ld h, a

    rst MemcpySmall

.execBytecode:
    jp ExecBytecodes


MakeFunction:
; TOS - qualified name of function
; TOS1 - ptr to function block
; Keeps the address of the function object in TOS
    call PopStack
    call PeekStack
    ld a, [hl]
    cp TYPE_FUNCTION
    jp nz, Debug

    jp ExecBytecodes


Nope:
	jp ExecBytecodes


BinaryAdd:
; Push TOS1 + TOS
; todo: allow other types
    call PopStack
    ld a, [hl+]
    cp TYPE_INT
    jp nz, Debug

    ld b, [hl]

    call PopStack
    ld a, [hl+]
    cp TYPE_INT
    jp nz, Debug

    ld a, [hl]
    add b
    ld b, a
    call PushNewInt

    jp ExecBytecodes


ReturnValue:
    ldh a, [hCallStackTop]
    and a
    jr nz, .returnUpCallStack

; Return from python vm
    pop hl
    ret

.returnUpCallStack:
    call PopStack
    push hl

; Restore prev frame
    ldh a, [hCallStackTop]
    dec a
    ldh [hCallStackTop], a

; Restore prev stack
    ldh a, [hCallStackTop]
    swap a
    ld e, a
    ld d, HIGH(wCallStackSavedVars)
    ld hl, hPyCodeAddr
    ld c, hPyOpcode-hPyCodeAddr
    rst MemcpySmall

    pop hl
    call PushStack

    pop hl
    ret


StoreName:
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

; DE = address of name string to find
:   ld a, [hl+]
    ld e, a
    ld d, [hl]

    call HLequGlobalNamePtrAddr
    ld c, l
    ld b, h

; Store the stack word ptr to data in BC
	call PopStack
	ld a, l
	ld [bc], a
	inc bc
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


LoadName:
LoadGlobal:
; Push address of co_names[namei] to TOS

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

; DE = address of name string to find
:   ld a, [hl+]
    ld e, a
    ld d, [hl]

    call HLequGlobalNamePtrAddr
; Push address of function
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call PushStack
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
	jr c, .digitOnly

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
        ld l, a
        ldh a, [hCallStackTop]
	    add HIGH(wFrameStackPtrs)
        ld h, a
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
    ldh a, [hCallStackTop]
	add HIGH(wFrameStackPtrs)
	ld d, a

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


; Preserve HL
; There should exist a list of global names that point to their values, eg
; <heap_address>:
;   db <str_len>, <str>, $ff
;      dw <ptr to name's value>
;   db $ff
; thus every entry that exists generates 1+str_len+1+2 bytes
; and the final entry ($ff) takes up 1
; this value is stored before the 1st name, by `gbcompiler.py`
HeapifyNames:
	push hl

; HL = address of names
    ldh a, [hPyNamesAddr]
    ld l, a
    ldh a, [hPyNamesAddr+1]
    ld h, a

; HL = address of name 0 (end marker) - 1 => ptr to heap length
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	dec hl

; HL points to region to heapify names
	ld b, 0
	ld c, [hl]
	call Malloc
    ld a, l
    ldh [hGlobalNamesPtr], a
    ld a, h
    ldh [hGlobalNamesPtr+1], a

; Start storing string data here, DE = 1st name's address
    pop de

; BC = bytecode addr - 1st name's address
    ldh a, [hBytecodeAddr]
    sub e
    ld c, a
    ldh a, [hBytecodeAddr+1]
    sbc d
    ld b, a

; Copy data over, skipping 2 bytes after every $ff
	dec bc
	inc b
	inc c
    .loop
        ld a, [de]
        ld [hli], a
        cp $ff
        jr nz, :+
        inc hl
        inc hl
    :   inc de
        dec c
        jr nz, .loop
        dec b
        jr nz, .loop

    ld a, $ff
    ld [hl+], a

	pop hl
	ret


SECTION "PYVM Hram", HRAM

; Local to a single block frame
hPyCodeAddr: dw
hPyConstAddr: dw
hPyNamesAddr: dw
hBytecodeAddr: dw
hPyStackTop:: db

hPyOpcode: db
hPyParam: db

; For generic singly-linked list string tables
hStringListExtraBytes:: db

; Call stack which 1st points to a global frame
hCallStackTop:: db

hGlobalNamesPtr:: dw


SECTION "PYVM Wram Frame data", WRAM0, ALIGN[8]
; Local to a single block frame

; This should be 1st so we can use HIGH(wFrameStackPtrs)
wFrameStackPtrs:: ds $80 ; word-sized (low, then high)
wPyFastNames: ds $80 ; word-sized ptrs to 'fast' data rather than names
wLocalFrameIgnore: ds (CALL_STACK_LEN-1) * $100 ; per frame


SECTION "PYVM Wram Global data", WRAM0, ALIGN[8]

; Per-module
wCallStackSavedVars: ds CALL_STACK_LEN * $10
