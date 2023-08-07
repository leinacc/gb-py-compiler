INCLUDE "defines.asm"

SECTION "Python VM bytecode handlers", ROM0

; A - rom bank of module to load
; HL - address of module to load
LoadModule::
	push hl
	ldh [hCurROMBank], a
	ld [rROMB0], a

	xor a
	ldh [hCurrCallStackIdx], a
	
; Allow use of all function call stacks...
	ld a, $ff
	ld b, CALL_STACK_LEN-1
	ld h, HIGH(wReturnCallStackIdx)+1
	ld l, LOW(wReturnCallStackIdx)
	:	ld [hl+], a
		ld [hl-], a
		inc h
		dec b
		jr nz, :-

; Except the global one
	xor a
	ld hl, wCurrCallStackIdx
	ld [hl], a

	call InitHeap

; Python code address in hram
	pop hl
	call InitFrame
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
	ld c, a
	ld a, [hl+]
	ldh [hPyParam], a
	push hl

; Jump to opcode C's handler
	ld hl, BytecodeHandlers
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl


BytecodeHandlers:
	dw Debug ; $00
	dw PopTop ; $01
	dw Debug ; $02
	dw Debug ; $03
	dw Debug ; $04
	dw Debug ; $05
	dw Debug ; $06
	dw Debug ; $07
	dw Debug ; $08
	dw Nope ; $09
	dw Debug ; $0a
	dw Debug ; $0b
	dw Debug ; $0c
	dw Debug ; $0d
	dw Debug ; $0e
	dw Debug ; $0f
	dw Debug ; $10
	dw Debug ; $11
	dw Debug ; $12
	dw Debug ; $13
	dw Debug ; $14
	dw Debug ; $15
	dw Debug ; $16
	dw BinaryAdd ; $17
	dw Debug ; $18
	dw Debug ; $19
	dw Debug ; $1a
	dw Debug ; $1b
	dw Debug ; $1c
	dw Debug ; $1d
	dw Debug ; $1e
	dw Debug ; $1f
	dw Debug ; $20
	dw Debug ; $21
	dw Debug ; $22
	dw Debug ; $23
	dw Debug ; $24
	dw Debug ; $25
	dw Debug ; $26
	dw Debug ; $27
	dw Debug ; $28
	dw Debug ; $29
	dw Debug ; $2a
	dw Debug ; $2b
	dw Debug ; $2c
	dw Debug ; $2d
	dw Debug ; $2e
	dw Debug ; $2f
	dw Debug ; $30
	dw Debug ; $31
	dw Debug ; $32
	dw Debug ; $33
	dw Debug ; $34
	dw Debug ; $35
	dw Debug ; $36
	dw Debug ; $37
	dw Debug ; $38
	dw Debug ; $39
	dw Debug ; $3a
	dw Debug ; $3b
	dw Debug ; $3c
	dw Debug ; $3d
	dw Debug ; $3e
	dw Debug ; $3f
	dw Debug ; $40
	dw Debug ; $41
	dw Debug ; $42
	dw Debug ; $43
	dw Debug ; $44
	dw Debug ; $45
	dw Debug ; $46
	dw Debug ; $47
	dw Debug ; $48
	dw Debug ; $49
	dw Debug ; $4a
	dw Debug ; $4b
	dw Debug ; $4c
	dw Debug ; $4d
	dw Debug ; $4e
	dw Debug ; $4f
	dw Debug ; $50
	dw Debug ; $51
	dw Debug ; $52
	dw ReturnValue ; $53
	dw Debug ; $54
	dw Debug ; $55
	dw Debug ; $56
	dw Debug ; $57
	dw Debug ; $58
	dw Debug ; $59
	dw StoreName ; $5a
	dw Debug ; $5b
	dw Debug ; $5c
	dw Debug ; $5d
	dw Debug ; $5e
	dw Debug ; $5f
	dw Debug ; $60
	dw StoreGlobal ; $61
	dw Debug ; $62
	dw Debug ; $63
	dw LoadConst ; $64
	dw LoadName ; $65
	dw Debug ; $66
	dw Debug ; $67
	dw Debug ; $68
	dw Debug ; $69
	dw Debug ; $6a
	dw Debug ; $6b
	dw ImportName ; $6c
	dw ImportFrom ; $6d
	dw JumpForward ; $6e
	dw Debug ; $6f
	dw Debug ; $70
	dw JumpAbsolute ; $71
	dw PopJumpIfFalse ; $72
	dw PopJumpIfTrue ; $73
	dw LoadGlobal ; $74
	dw Debug ; $75
	dw Debug ; $76
	dw Debug ; $77
	dw Debug ; $78
	dw Debug ; $79
	dw Debug ; $7a
	dw Debug ; $7b
	dw LoadFast ; $7c
	dw StoreFast ; $7d
	dw Debug ; $7e
	dw Debug ; $7f
	dw Debug ; $80
	dw Debug ; $81
	dw Debug ; $82
	dw CallFunction ; $83
	dw MakeFunction ; $84
	dw Debug ; $85
	dw Debug ; $86
	dw Debug ; $87
	dw Debug ; $88
	dw Debug ; $89
	dw Debug ; $8a
	dw Debug ; $8b
	dw Debug ; $8c
	dw Debug ; $8d
	dw Debug ; $8e
	dw Debug ; $8f
	dw Debug ; $90
	dw Debug ; $91
	dw Debug ; $92
	dw Debug ; $93
	dw Debug ; $94
	dw Debug ; $95
	dw Debug ; $96
	dw Debug ; $97
	dw Debug ; $98
	dw Debug ; $99
	dw Debug ; $9a
	dw FormatValue ; $9b
	dw Debug ; $9c
	dw BuildString ; $9d
	dw Debug ; $9e
	dw Debug ; $9f
	dw Debug ; $a0
	dw Debug ; $a1
	dw Debug ; $a2
	dw Debug ; $a3
	dw Debug ; $a4
	dw Debug ; $a5
	dw Debug ; $a6
	dw Debug ; $a7
	dw Debug ; $a8
	dw Debug ; $a9
	dw Debug ; $aa
	dw Debug ; $ab
	dw Debug ; $ac
	dw Debug ; $ad
	dw Debug ; $ae
	dw Debug ; $af
	dw Debug ; $b0
	dw Debug ; $b1
	dw Debug ; $b2
	dw Debug ; $b3
	dw Debug ; $b4
	dw Debug ; $b5
	dw Debug ; $b6
	dw Debug ; $b7
	dw Debug ; $b8
	dw Debug ; $b9
	dw Debug ; $ba
	dw Debug ; $bb
	dw Debug ; $bc
	dw Debug ; $bd
	dw Debug ; $be
	dw Debug ; $bf
	dw Debug ; $c0
	dw Debug ; $c1
	dw Debug ; $c2
	dw Debug ; $c3
	dw Debug ; $c4
	dw Debug ; $c5
	dw Debug ; $c6
	dw Debug ; $c7
	dw Debug ; $c8
	dw Debug ; $c9
	dw Debug ; $ca
	dw Debug ; $cb
	dw Debug ; $cc
	dw Debug ; $cd
	dw Debug ; $ce
	dw Debug ; $cf
	dw Debug ; $d0
	dw Debug ; $d1
	dw Debug ; $d2
	dw Debug ; $d3
	dw Debug ; $d4
	dw Debug ; $d5
	dw Debug ; $d6
	dw Debug ; $d7
	dw Debug ; $d8
	dw Debug ; $d9
	dw Debug ; $da
	dw Debug ; $db
	dw Debug ; $dc
	dw Debug ; $dd
	dw Debug ; $de
	dw Debug ; $df
	dw Debug ; $e0
	dw Debug ; $e1
	dw Debug ; $e2
	dw Debug ; $e3
	dw Debug ; $e4
	dw Debug ; $e5
	dw Debug ; $e6
	dw Debug ; $e7
	dw Debug ; $e8
	dw Debug ; $e9
	dw Debug ; $ea
	dw Debug ; $eb
	dw Debug ; $ec
	dw Debug ; $ed
	dw Debug ; $ee
	dw Debug ; $ef
	dw Debug ; $f0
	dw Debug ; $f1
	dw Debug ; $f2
	dw Debug ; $f3
	dw Debug ; $f4
	dw Debug ; $f5
	dw Debug ; $f6
	dw Debug ; $f7
	dw Debug ; $f8
	dw Debug ; $f9
	dw Debug ; $fa
	dw Debug ; $fb
	dw Debug ; $fc
	dw Debug ; $fd
	dw Debug ; $fe
	dw Debug ; $ff


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
	call BequCurrFastNamesHi

; Store the stack word ptr to data in BC
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	jp ExecBytecodes


PopTop:
; The prev data will be ignored, so pop+free it
	call HLequCurrFrameStackPtrs
	dec hl

	call FreeStackPoppedData

	ld a, l
	ldh [hPyStackTop], a
	jp ExecBytecodes


LoadFast:
; HL points to a varname ptr to data
	ldh a, [hPyParam]
	add a
	add LOW(wPyFastNames)
	ld l, a
	call HequCurrFastNamesHi

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
	jr z, CallNewFrameStack

	jp Debug

.doAsm:
; Jump to HL, then return to ExecBytecodes
; hPyStackTop points to the routine ptr, so params are eg [hPyStackTop]+2
	ld bc, .return
	push bc

	jp hl

.return:
	jp ExecBytecodes


SaveCurrCallStackVars:
	ldh a, [hCurrCallStackIdx]
	swap a
	add LOW(wCallStackSavedVars)
	ld l, a
	ld h, HIGH(wCallStackSavedVars)
	ld de, hPyCodeAddr
	ld c, hPyOpcode-hPyCodeAddr
	rst MemcpySmall
	ret


; HL - addr of module/function block
InitFrame:
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
	ldh [hSavedBytecodeAddr], a
	ld a, [hl]
	ldh [hBytecodeAddr+1], a
	ldh [hSavedBytecodeAddr+1], a
	ret


; A - call stack idx
LoadCallStackSavedVars:
	ldh [hCurrCallStackIdx], a

; Restore prev stack
	swap a
	ld e, a
	ld d, HIGH(wCallStackSavedVars)
	ld hl, hPyCodeAddr
	ld c, hPyOpcode-hPyCodeAddr
	rst MemcpySmall
	ret


; HL - points to the address of a function block
; This routine allows pushing a frame stack, that will return to the current one
CallNewFrameStack:
; Push curr call stack, and stack top, to get the addr for new function's fast vars
	ldh a, [hCurrCallStackIdx]
	ld d, a

	ldh a, [hPyStackTop]
	add 2
	ld e, a
	push de

; Push addr of function block to store later
	push hl

; Save prev stack
	call SaveCurrCallStackVars

; Start on a new frame
	ld c, 1
	ld b, CALL_STACK_LEN
	ld h, HIGH(wCurrCallStackIdx)+1
	ld l, LOW(wCurrCallStackIdx)
	.nextCallStackToTryUsing:
		ld a, [hl]
		cp $ff
		jr z, .foundCallStack

		inc h
		inc c
		dec b
		jp z, Debug
		jr .nextCallStackToTryUsing

.foundCallStack:
	ld a, c
	ld [hl], c
	ldh [hCurrCallStackIdx], a

; HL = address of the function block
	pop hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a

	call InitFrame

; Save prev and curr call stack idx
	call HLequCurrReturnCallStackIdx
	pop de
	ld a, d
	ld [hl+], a
	ldh a, [hCurrCallStackIdx]
	ld [hl], a

; Store fast values, DE = prev frame's stack where the fast values are
	ldh a, [hPyParam]
	add a
	jr z, .afterFast
	ld c, a

; D = prev call stack idxes set of vars
	ld a, d
	add HIGH(wFrameStackPtrs)
	ld d, a

; HL = where to store the fast names
	ld l, LOW(wPyFastNames)
	call HequCurrFastNamesHi

	rst MemcpySmall

.afterFast:
; Continue exec'ing bytecodes for the previous stack
	ld bc, ExecBytecodes
	push bc

; Get bytecode addr
	ldh a, [hSavedBytecodeAddr]
	ld l, a
	ldh a, [hSavedBytecodeAddr+1]
	ld h, a
	push hl

	jp ExecBytecodes


; C - new call stack idx
; HL - points to the address of a function block
; This routine allows starting a new python routine from outside the VM
StartEntityFrameStack::
; Push curr call stack idx to set the next one's 'return'
	ldh a, [hCurrCallStackIdx]
	ld b, a
	push bc

; Push addr of function block to store later
	push hl

	ld a, c
	push af

; Save prev stack
	call SaveCurrCallStackVars

; Find the relevant frame
	pop af
	ldh [hCurrCallStackIdx], a

; HL = address of the function block
	pop hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a

	call InitFrame
	call SaveCurrCallStackVars

; Save prev call stack idx
	call HLequCurrReturnCallStackIdx
	pop af
	ld [hl], a

; Restore prev frame
	jp LoadCallStackSavedVars


; This routine allows continuing a python routine from outside the VM
ContEntityFrameStack::
; Save prev stack
	call SaveCurrCallStackVars
	ldh a, [hCurrCallStackIdx]
	push af

; Get vars for the entity's script's frame
	ld a, [wCurrEntity_CallStackIdx]
	call LoadCallStackSavedVars

	call HLequCurrReturnCallStackIdx
	pop af
	ld [hl], a

; Return to .return
	ld bc, .return
	push bc

; Get bytecode addr, and continue executing them
	ldh a, [hSavedBytecodeAddr]
	ld l, a
	ldh a, [hSavedBytecodeAddr+1]
	ld h, a
	push hl

	jp ExecBytecodes

.return:
; Save the entity's script's frame in wram
	call SaveCurrCallStackVars

; Restore prev frame
	call HLequCurrReturnCallStackIdx
	ld a, [hl]
	jp LoadCallStackSavedVars


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
	call HLequCurrReturnCallStackIdx
	ld a, [hl]
	cp $ff
	jr nz, .returnUpCallStack

; Return from python vm
	pop hl
	ret

.returnUpCallStack:
	ld b, a
	call PopStack
	push hl

; Restore prev frame
	ld a, b
	ldh [hCurrCallStackIdx], a

; Restore prev stack
	swap a
	ld e, a
	ld d, HIGH(wCallStackSavedVars)
	ld hl, hPyCodeAddr
	ld c, hPyOpcode-hPyCodeAddr
	rst MemcpySmall

	pop hl
	call PushStack

; Return from the function
	pop hl
	ret


StoreName:
StoreGlobal:
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


JumpForward:
; Get current ptr (points to next instruction)
	pop hl

; Add param*2 to get next addr
	ldh a, [hPyParam]
	add a
	add l
	ld l, a
	jr nc, :+
	inc h
:	push hl
	jp ExecBytecodes


JumpAbsolute:
; Ignore current ptr
	pop hl

; HL = bytecode addr (start of bytecodes)
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


PopJumpIfFalse:
	call PopStack
	push hl

	call HLequCurrFrameStackPtrs
	inc hl
	call FreeStackPoppedData

	pop hl
	ld a, [hl+]
	cp TYPE_BOOL
	jp nz, Debug

; If 0 (False), jump
	ld a, [hl]
	and a
	jp z, JumpAbsolute

	jp ExecBytecodes


PopJumpIfTrue:
	call PopStack
	push hl

	call HLequCurrFrameStackPtrs
	inc hl
	call FreeStackPoppedData

	pop hl
	ld a, [hl+]
	cp TYPE_BOOL
	jp nz, Debug

; If 1 (True), jump
	ld a, [hl]
	and a
	jp nz, JumpAbsolute

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
	.nextStringLen:
		call HLequCurrFrameStackPtrs
		dec l
		dec l
		ld a, l
		ldh [hPyStackTop], a

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
		jr nz, .nextStringLen

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

	call DEequCurrFrameStackPtrs

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

; HL = address of name 0 (end marker)
; HL-1 => HIGH(ptr) to heap length
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	dec hl

; HL points to region to heapify names
	ld b, [hl]
	dec hl
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

;-----------------------------------------------------------------------------
; Frames
;-----------------------------------------------------------------------------
;
; wFrameStackPtrs:
;   $100*x bytes each for every block frame in the global frame stack
; hCurrCallStackIdx:
;   determines which $100 bytes to look at
; hPyStackTop:
;   index into wFrameStackPtrs for the current block frame
;   where a new pointer will be stored
;
;-----------------------------------------------------------------------------

; Local to a single block frame
hPyLocalStart:
hPyCodeAddr: dw ; points to a PyBlock's addr
hPyConstAddr: dw ; points to a PyBlock's .consts
hPyNamesAddr: dw ; points to a PyBlock's .names
hBytecodeAddr:: dw ; points to a PyBlock's .bytecode
hSavedBytecodeAddr:: dw ; points to the next instruction to execute in .bytecode
hPyStackTop:: db
; hPyBank: db ; bank where the current PyBlock resides
; Keep hPyOpcode here
hPyOpcode: db
hPyParam:: db
hPyLocalEnd:

; For generic singly-linked list string tables
hStringListExtraBytes:: db

; Call stack which 1st points to a global frame
hCurrCallStackIdx:: db

hGlobalNamesPtr:: dw


SECTION "PYVM Wram Frame data", WRAMX[$d000] ; ALIGN[8]
; Local to a single block frame

; This should be 1st so we can use HIGH(wFrameStackPtrs)
wFrameStackPtrs:: ds $80 ; word-sized (low, then high)
wPyFastNames:: ds $7e ; word-sized ptrs to 'fast' data rather than names
wReturnCallStackIdx:: db
wCurrCallStackIdx:: db
; No usage, but keep
wLocalFrameIgnore: ds (CALL_STACK_LEN-1) * $100 ; per frame


SECTION "PYVM Wram Global data", WRAM0, ALIGN[8]

; todo: Per-module (a concept which doesn't exist yet)
SAVED_VARS_LEN = $10
assert SAVED_VARS_LEN > hPyLocalEnd-hPyLocalStart
wCallStackSavedVars: ds CALL_STACK_LEN * SAVED_VARS_LEN
