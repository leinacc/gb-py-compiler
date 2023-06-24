INCLUDE "defines.asm"

SECTION "Entities code", ROM0

InitEntites::
    ld hl, wEntity00
    ld bc, (wEntity01-wEntity00)*NUM_ENTITIES
    xor a
    rst Memset
    ld [wCurrOamIdxToFill], a
    ret


; A - animation definition idx
; B - tile x
; C - tile y
; DE - addr of script (bank is the current one)
; H - pals base idx
; L - tiles base idx
; wTempEntityMtilesAddr.w
; wTempEntityMattrsAddr.w
AddEntity::
    push de
    push hl
    push af
    push de
    push bc    

    ld hl, wEntity00_InUse
    ld b, NUM_ENTITIES
    ld de, wEntity01-wEntity00

    .nextSlot:
        ld a, [hl]
        and a
        jr z, .foundSlot

        add hl, de
        dec b
        jr nz, .nextSlot

    jp Debug

.foundSlot
    push hl
    xor a
    ld c, wEntity01-wEntity00
    rst MemsetSmall
    pop hl

; InUse
    inc a
    ld [hl+], a

; TileX
    pop bc
    ld a, b
    ld [hl+], a

; TileY
    ld a, c
    ld [hl+], a

; ScriptDef addr
    pop de
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl+], a

; ScriptDef bank
    ldh a, [hCurROMBank]
    ld [hl+], a

; ScreenX
    ld a, b
    swap a
    ld [hl+], a

; ScreenY
    ld a, c
    swap a
    ld [hl+], a

; AnimDef
    pop af
    ld e, a
    ld d, 0
    push hl
    ld hl, AnimTable
    add hl, de
    add hl, de
    add hl, de
    ld e, l
    ld d, h
    pop hl

    ld c, 3
    rst MemcpySmall

; PalBaseIdx and TilesBaseIdx
    pop de
    ld a, d
    ld [hl+], a
    ld a, e
    ld [hl+], a

; MetatilesTilesSrc
    ld a, [wTempEntityMtilesAddr]
    ld [hl+], a
    ld a, [wTempEntityMtilesAddr+1]
    ld [hl+], a
    ldh a, [hCurROMBank]
    ld [hl+], a

; MetatilesAttrsSrc
    ld a, [wTempEntityMattrsAddr]
    ld [hl+], a
    ld a, [wTempEntityMattrsAddr+1]
    ld [hl+], a
    ldh a, [hCurROMBank]
    ld [hl+], a
    push hl

; Start its script on a new frame
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
    ld [hl], c

; Save Entity.CallStackIdx
    pop hl
    ld [hl], c

    pop hl
    ld a, [hl+]
    cp TYPE_FUNCTION
    jp nz, Debug

    jp StartEntityFrameStack


UpdateEntities::
; todo: put camera code in its own python-called routine
    ld hl, wCurrEntity
    ld de, wEntity00_InUse
    ld c, wEntity01-wEntity00
    rst MemcpySmall

    ld a, [wCurrEntity_ScreenX]
    sub $a0/2
    jr nc, :+
    xor a
:   cp $100-$a0
    jr c, :+
    ld a, $100-$a0
:   ldh [hSCX], a

    ld a, [wCurrEntity_ScreenY]
    sub $90/2
    jr nc, :+
    xor a
:   cp $100-$90
    jr c, :+
    ld a, $100-$90
:   ldh [hSCY], a

; actual entity update code
    ld de, wEntity00_InUse
    ld b, NUM_ENTITIES
    .nextEntity:
        push de
        push bc

    ; Proceed only if slot is in use
        ld a, [de]
        and a
        jr z, .toNextEntity

    ; Store entity details in a way where we can get it faster
        push de
        ld hl, wCurrEntity
        ld c, wEntity01-wEntity00
        rst MemcpySmall

        call MoveEntFromInput
        call MoveEntity
        call RunEntityScript
        call UpdateAnimation
        call SendEntityDataToShadowOam

    ; Save updated details
        ld de, wCurrEntity
        pop hl
        ld c, wEntity01-wEntity00
        rst MemcpySmall

    .toNextEntity:
        pop bc
        pop de
        ld hl, wEntity01-wEntity00
        add hl, de
        ld e, l
        ld d, h
        dec b
        jr nz, .nextEntity

    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a
    xor a
    ld [wCurrOamIdxToFill], a
    ret


; Trashes A and C
HLequAddrInMetatiles:
; A = offset based on tile X and Y
    ld a, [wCurrEntity_TileY]
    swap a
    ld c, a
    ld a, [wCurrEntity_TileX]
    or c

; Offset into shadow metatiles
    add LOW(wRoomMetatiles)
    ld l, a
    ld h, HIGH(wRoomMetatiles)
    ret nc
    inc h
    ret


; Returns zflag set if the metatile is walkable
IsAaWalkableMetatile:
    cp $11
    ret z

    cp $14
    ret


; B - num tiles
MoveDown::
    call HLequAddrInMetatiles
    ld de, $10
    add hl, de
    ld a, [hl+]
    call IsAaWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileY]
    inc a
    ld [wCurrEntity_TileY],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	xor a
	ld [wCurrEntity_XSpeed], a
	inc a
	ld [wCurrEntity_YSpeed], a

.setDir:
    xor a
    ld [wCurrEntity_AnimCtr], a
    ld a, 2
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveUp::
    call HLequAddrInMetatiles
    ld de, -$10
    add hl, de
    ld a, [hl+]
    call IsAaWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileY]
    dec a
    ld [wCurrEntity_TileY],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	xor a
	ld [wCurrEntity_XSpeed], a
	dec a
	ld [wCurrEntity_YSpeed], a

.setDir:
    xor a
    ld [wCurrEntity_AnimCtr], a
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveLeft::
    call HLequAddrInMetatiles
    ld de, -1
    add hl, de
    ld a, [hl+]
    call IsAaWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileX]
    dec a
    ld [wCurrEntity_TileX],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	ld a, $ff
	ld [wCurrEntity_XSpeed], a
	xor a
	ld [wCurrEntity_YSpeed], a

.setDir:
    xor a
    ld [wCurrEntity_AnimCtr], a
	ld a, 3
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveRight::
    call HLequAddrInMetatiles
    ld de, 1
    add hl, de
    ld a, [hl+]
    call IsAaWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileX]
    inc a
    ld [wCurrEntity_TileX],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	ld a, 1
	ld [wCurrEntity_XSpeed], a
	xor a
	ld [wCurrEntity_YSpeed], a

.setDir:
    xor a
    ld [wCurrEntity_AnimCtr], a
	ld a, 1
	ld [wCurrEntity_Dir], a
    ret


MoveEntFromInput:
    ld a, [wCurrEntity_PlayerMoved]
    and a
    ret z

    ld a, [wCurrEntity_MoveCtr]
    and a
    ret nz

    ldh a, [hHeldKeys]
    ld b, 1
    bit PADB_DOWN, a
    jp nz, MoveDown

    bit PADB_UP, a
    jp nz, MoveUp

    bit PADB_LEFT, a
    jp nz, MoveLeft

    bit PADB_RIGHT, a
    jp nz, MoveRight

    ret


MoveEntity:
    ld a, [wCurrEntity_MoveCtr]
    and a
    ret z

    dec a
    ld [wCurrEntity_MoveCtr], a

    ld a, [wCurrEntity_ScreenX]
    ld b, a
    ld a, [wCurrEntity_XSpeed]
    add b
    ld [wCurrEntity_ScreenX], a

    ld a, [wCurrEntity_ScreenY]
    ld b, a
    ld a, [wCurrEntity_YSpeed]
    add b
    ld [wCurrEntity_ScreenY], a
    ret


RunEntityScript:
    ld a, [wCurrEntity_MoveCtr]
    and a
    ret nz

    jp ContEntityFrameStack


; Trashes everything
UpdateAnimation:
; todo: init anim in AddEntity?
    ld a, [wCurrEntity_AnimCtr]
    and a
    jr z, .initAnim

    dec a
    jr z, .nextAnim

    ld [wCurrEntity_AnimCtr], a
    ret

.initAnim:
; HL = table of direction ptrs
    ld a, [wCurrEntity_AnimDef]
    ld l, a
    ld a, [wCurrEntity_AnimDef+1]
    ld h, a

; HL = anim dirs table
    ld a, [wCurrEntity_Dir]
    add a
    add l
    ld l, a
    jr nc, :+
    inc h
:   ld a, [hl+]
    ld h, [hl]
    ld l, a

; Save it
    ld a, l
    ld [wCurrEntity_AnimDirsTable], a
    ld a, h
    ld [wCurrEntity_AnimDirsTable+1], a

; Save the metatile idx and frame counter
    ld a, [hl+]
    ld [wCurrEntity_MetatileIdx], a
    ld a, [hl]
    ld [wCurrEntity_AnimCtr], a
    ret

.nextAnim:
; HL = anim dirs table
    ld a, [wCurrEntity_AnimDirsTable]
    ld l, a
    ld a, [wCurrEntity_AnimDirsTable+1]
    ld h, a
    ld c, l
    ld b, h

; Increase and add on the anim idx
    ld a, [wCurrEntity_AnimIdx]
    inc a
    ld [wCurrEntity_AnimIdx], a

.setNewAnim:
    add a
    add l
    ld l, a
    jr nc, :+
    inc h

; HL points next metatile idx
:   ld a, [hl+]
    cp $fe
    jr z, .jumpAnim

    ld [wCurrEntity_MetatileIdx], a
    ld a, [hl]
    ld [wCurrEntity_AnimCtr], a
    ret

.jumpAnim:
    ld a, [hl]
    ld [wCurrEntity_AnimIdx], a
    ld l, c
    ld h, b
    jr .setNewAnim


; wCurrEntity - entity struct
SendEntityDataToShadowOam:
    ld hl, wCurrEntity_ScreenX
    ldh a, [hSCX]
    ld b, a
    ld a, [hl+]
    add 8
    sub b
    ld b, a

    ldh a, [hSCY]
    ld c, a
    ld a, [hl]
    add 16
    sub c
    ld c, a

    ld a, [wCurrOamIdxToFill]
    ld l, a
    ld h, HIGH(wShadowOAM)

    call AddSprite

    ld a, l
    ld [wCurrOamIdxToFill], a

    ret


AnimTable:
    dl AnimDefSimple

WALK_CTR equ $0c

AnimDefSimple:
    dw .up
    dw .right
    dw .down
    dw .left

.up:
    db $06, WALK_CTR
    db $07, WALK_CTR
    db $08, WALK_CTR
    db $09, WALK_CTR
    db $fe, $00

.right:
    db $0b, WALK_CTR
    db $0c, WALK_CTR
    db $0d, WALK_CTR
    db $0e, WALK_CTR
    db $fe, $00

.down:
    db $01, WALK_CTR
    db $02, WALK_CTR
    db $03, WALK_CTR
    db $04, WALK_CTR
    db $fe, $00

.left:
    db $10, WALK_CTR
    db $11, WALK_CTR
    db $12, WALK_CTR
    db $13, WALK_CTR
    db $fe, $00


; B - starting screen X (pre-plus 8)
; C - starting screen Y (pre-plus 16)
; HL - dest addr in shadow oam
; Returns HL = next oam slot to fill
; Trashes all
AddSprite:
; DE = addr of metatile tile src
    ld a, [wCurrEntity_MetatilesTilesSrc]
    ld e, a
    ld a, [wCurrEntity_MetatilesTilesSrc+1]
    ld d, a
    ld a, [wCurrEntity_MetatileIdx]
    add a
    add a
    push af
    add e
    ld e, a
    jr nc, :+
    inc d

; Populate 4 tile idxes
:   ld a, c
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld a, [de]
    inc de
    ld [hl+], a
    push hl
    inc hl

    ld a, c
    ld [hl+], a
    ld a, b
    add 8
    ld [hl+], a
    ld a, [de]
    inc de
    ld [hl+], a
    inc hl

    ld a, c
    add 8
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld a, [de]
    inc de
    ld [hl+], a
    inc hl

    ld a, c
    add 8
    ld [hl+], a
    ld a, b
    add 8
    ld [hl+], a
    ld a, [de]
    ld [hl], a

; DE = addr of metatile attr src
    pop hl
    ld a, [wCurrEntity_MetatilesAttrsSrc]
    ld e, a
    ld a, [wCurrEntity_MetatilesAttrsSrc+1]
    ld d, a
    pop af
    add e
    ld e, a
    jr nc, :+
    inc d

; Populate 4 tile attrs
:   ld b, 4
    .nextAttr:
        ld a, [de]
        inc de
        ld [hl], a
        ld a, l
        add 4
        ld l, a
        jr nc, :+
        inc h

    :   dec b
        jr nz, .nextAttr

    dec hl
    dec hl
    dec hl
    ret


SECTION "Entities ram", WRAM0
FOR N, NUM_ENTITIES
    dstruct Entity, wEntity{02x:N}
ENDR

    dstruct Entity, wCurrEntity

wCurrOamIdxToFill: db
