INCLUDE "defines.asm"

SECTION "Entities code", ROM0

InitEntites::
    ld hl, wEntity00
    ld bc, (wEntity01-wEntity00)*NUM_ENTITIES
    xor a
    rst Memset
    ld [wCurrOamIdxToFill], a
    ld [wEntityIdToProcess], a
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
    ld c, 0

    .nextSlot:
        ld a, [hl]
        and a
        jr z, .foundSlot

        add hl, de
        inc c
        dec b
        jr nz, .nextSlot

    jp Debug

.foundSlot
    ld a, c
    ld [wChosenEntitySlot], a

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

; todo: fix camera
    ld a, [wCurrEntity_ScreenX]
    sub $a0/2-8
    jr nc, :+
    xor a
:   cp $100-$a0
    jr c, :+
    ld a, $100-$a0
:   ldh [hSCX], a

    ld a, [wCurrEntity_ScreenY]
    sub $90/2-8
    jr nc, :+
    xor a
:   cp $100-$90
    jr c, :+
    ld a, $100-$90
:   ldh [hSCY], a

; actual entity update code
    ld hl, wEntity00_InUse
    ld a, [wEntityIdToProcess]
    ld de, wEntity01-wEntity00
    and a
    jr z, .afterChoseEnt

    :   add hl, de
        dec a
        jr nz, :-

.afterChoseEnt:
    ld d, h
    ld e, l

; Proceed only if slot is in use
    ld a, [de]
    and a
    jr z, .displayEnts

; Store entity details in a way where we can get it faster
    push de
    ld hl, wCurrEntity
    ld c, wEntity01-wEntity00
    rst MemcpySmall

    call ContEntityFrameStack

; Save updated details
    ld de, wCurrEntity
    pop hl
    ld c, wEntity01-wEntity00
    rst MemcpySmall

.displayEnts:
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


; HL - address within wRoomMetatiles
; Returns zflag set if the metatile is walkable
IsPosAWalkableMetatile:
    push bc
    push de

    ld a, [hl]
    cp $11
    jr z, .checkEnts

    cp $14
    jr z, .checkEnts

    pop de
    pop bc
    ret ; nz - cause solid

.checkEnts:
; Save the tile pos we're checking
    ld a, l
    ld [wMetatileYXtoCheck], a

; Check for solid entities
    ld hl, wEntity00_InUse
    ld de, wEntity01-wEntity00
    ld b, NUM_ENTITIES

    .nextEntity:
    ; Check if slot in use
        push hl

        ld a, [hl+]
        and a
        jr z, .toNextEntity

    ; A = metatile YX of the entity
        ld a, [hl+]
        ld c, a
        ld a, [hl]
        swap a
        or c
        ld c, a

        ld a, [wMetatileYXtoCheck]
        cp c
        jr nz, .toNextEntity

        ld a, l
        add wCurrEntity_InputCtrl-wCurrEntity_TileY
        ld l, a
        jr nc, :+
        inc h
    :   ld a, [hl]
        bit ENTCTRL_IS_SOLID, a
        jr nz, .isSolid

    .toNextEntity:
        pop hl

        add hl, de
        dec b
        jr nz, .nextEntity

; No solid tile found - it's walkable
    xor a
    pop de
    pop bc
    ret

.isSolid:
    pop hl
    pop de
    pop bc
    ret ; nz


UpdateEntity::
    ld a, [wCurrEntity_State]
    add a
    ld hl, EntityStateTable
    add l
    ld l, a
    jr nc, :+
    inc h
:   ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp hl


EntityStateTable:
    dw EntityStateStill
    dw EntityStateMoving
    dw EntityStateUsingAbility


EntityStateStill:
    call ProcessEntDirectionsInput

    ld a, [wCurrEntity_InputCtrl]
    bit ENTCTRL_USES_ABILITIES, a
    ret z

; Return if action btn not pressed
    ldh a, [hPressedKeys]
    bit PADB_B, a
    ret z

    ld b, ENTSTATE_USING_ABILITY
    jp SetEntityState


EntityStateMoving:
    call ProcessEntWallWalk

    ld a, [wCurrEntity_MoveCtr]
    and a
    jr z, .setStill

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

.setStill:
    call PassTurnToNextEntity
    ld b, ENTSTATE_STILL
    jp SetEntityState


PassTurnToNextEntity::
; Find the next entity ID that can be processed
    ld a, [wEntityIdToProcess]
 
; HL = curr entity
    ld hl, wEntity00_InUse
    ld de, wEntity01-wEntity00
    and a
    jr z, .afterChosenEntity

    :   add hl, de
        dec a
        jr nz, :-

.afterChosenEntity:
    .nextEntity:
        add hl, de

    ; +1 to entity ID, resetting the ID to process and struct ptr HL if
    ; we've looped around all entities
        ld a, [wEntityIdToProcess]
        inc a
        cp NUM_ENTITIES
        jr nz, .setNextEntId

        ld hl, wEntity00_InUse
        xor a

    .setNextEntId:
        ld [wEntityIdToProcess], a

        ld a, [hl]
        and a
        jr z, .nextEntity

; We've found an entity ID to process and we've already saved it.. return
    ret


EntityStateUsingAbility:
    call HLequAddrInMetatiles

; Check direction pressed
    ldh a, [hHeldKeys]
    bit PADB_DOWN, a
    ld de, $10
    jr nz, .checkVert

    bit PADB_UP, a
    ld de, -$10
    jr nz, .checkVert

    bit PADB_LEFT, a
    ld de, -1
    jr nz, .checkHoriz

    bit PADB_RIGHT, a
    ld de, 1
    jr nz, .checkHoriz

; Return if action btn not pressed
    ldh a, [hPressedKeys]
    bit PADB_B, a
    ret z

    ld b, ENTSTATE_STILL
    jp SetEntityState

.checkVert:
    ld a, h
    add hl, de

; Must be on the same page
    cp h
    ret nz

; Must not be walkable
    call IsPosAWalkableMetatile
    ret z

    ld c, 1

    .nextVert:
        ld a, h
        add hl, de
        cp h
        ret nz

    ; Keep looping until walkable
        inc c
        call IsPosAWalkableMetatile
        jr nz, .nextVert

; We can move into the spot
    ld a, e
    cp $10

    ld b, c
    jr z, .moveDown

    call ForceMoveUp    
    jr .walkWall

.moveDown:
    call ForceMoveDown
    jr .walkWall

.checkHoriz:
; Save the row we're on
    ld a, l
    and $f0
    ld b, a
    add hl, de

; Must be on the same row
    ld a, l
    and $f0
    cp b
    ret nz

; Must not be walkable
    call IsPosAWalkableMetatile
    ret z

    ld c, 1

    .nextHoriz:
        add hl, de
        ld a, l
        and $f0
        cp b
        ret nz

    ; Keep looping until walkable
        inc c
        call IsPosAWalkableMetatile
        jr nz, .nextHoriz

; We can move into the spot
    ld a, e
    cp 1

    ld b, c
    jr z, .moveRight

    call ForceMoveLeft
    jr .walkWall

.moveRight:
    call ForceMoveRight

.walkWall:
    ld a, [wCurrEntity_InputCtrl]
    res ENTCTRL_DIR_MOVABLE, a
    set ENTCTRL_WALL_WALKING, a
    ld [wCurrEntity_InputCtrl], a

    ld b, ENTSTATE_MOVING
    jp SetEntityState


; B - new state
; Trashes A
SetEntityState:
    ld a, [wCurrEntity_State]
    cp b
    ret z

    ld a, b
    ld [wCurrEntity_State], a
    xor a
    ld [wCurrEntity_AnimCtr], a
    ret


; B - num tiles
ForceMoveDown:
    ld a, [wCurrEntity_TileY]
    add b
    ld [wCurrEntity_TileY],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	xor a
	ld [wCurrEntity_XSpeed], a
	inc a
	ld [wCurrEntity_YSpeed], a

    xor a
    ld [wCurrEntity_AnimCtr], a
    ld a, DIR_DOWN
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveDown::
    call HLequAddrInMetatiles
    ld de, $10
    add hl, de
    call IsPosAWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileY]
    add b
    ld [wCurrEntity_TileY],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	xor a
	ld [wCurrEntity_XSpeed], a
	inc a
	ld [wCurrEntity_YSpeed], a
    ld b, ENTSTATE_MOVING
    call SetEntityState

.setDir:
    ld a, [wCurrEntity_Dir]
    cp DIR_DOWN
    ret z

    xor a
    ld [wCurrEntity_AnimCtr], a
    ld a, DIR_DOWN
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
ForceMoveUp:
    ld a, [wCurrEntity_TileY]
    sub b
    ld [wCurrEntity_TileY],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	xor a
	ld [wCurrEntity_XSpeed], a
	dec a
	ld [wCurrEntity_YSpeed], a

    xor a
    ld [wCurrEntity_AnimCtr], a
    ld a, DIR_UP
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveUp::
    call HLequAddrInMetatiles
    ld de, -$10
    add hl, de
    call IsPosAWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileY]
    sub b
    ld [wCurrEntity_TileY],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	xor a
	ld [wCurrEntity_XSpeed], a
	dec a
	ld [wCurrEntity_YSpeed], a
    ld b, ENTSTATE_MOVING
    call SetEntityState

.setDir:
assert DIR_UP == 0
    ld a, [wCurrEntity_Dir]
    and a
    ret z

    xor a
    ld [wCurrEntity_AnimCtr], a
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
ForceMoveLeft:
    ld a, [wCurrEntity_TileX]
    sub b
    ld [wCurrEntity_TileX],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	ld a, $ff
	ld [wCurrEntity_XSpeed], a
	xor a
	ld [wCurrEntity_YSpeed], a

    xor a
    ld [wCurrEntity_AnimCtr], a
    ld a, DIR_LEFT
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveLeft::
    call HLequAddrInMetatiles
    ld de, -1
    add hl, de
    call IsPosAWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileX]
    sub b
    ld [wCurrEntity_TileX],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	ld a, $ff
	ld [wCurrEntity_XSpeed], a
	xor a
	ld [wCurrEntity_YSpeed], a
    ld b, ENTSTATE_MOVING
    call SetEntityState

.setDir:
    ld a, [wCurrEntity_Dir]
    cp DIR_LEFT
    ret z

    xor a
    ld [wCurrEntity_AnimCtr], a
	ld a, DIR_LEFT
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
ForceMoveRight:
    ld a, [wCurrEntity_TileX]
    add b
    ld [wCurrEntity_TileX],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	ld a, 1
	ld [wCurrEntity_XSpeed], a
	xor a
	ld [wCurrEntity_YSpeed], a

    xor a
    ld [wCurrEntity_AnimCtr], a
    ld a, DIR_RIGHT
	ld [wCurrEntity_Dir], a
    ret


; B - num tiles
MoveRight::
    call HLequAddrInMetatiles
    ld de, 1
    add hl, de
    call IsPosAWalkableMetatile
    jr nz, .setDir

    ld a, [wCurrEntity_TileX]
    add b
    ld [wCurrEntity_TileX],a

    ld a, b
    swap a
    ld [wCurrEntity_MoveCtr], a

	ld a, 1
	ld [wCurrEntity_XSpeed], a
	xor a
	ld [wCurrEntity_YSpeed], a

    ld b, ENTSTATE_MOVING
    call SetEntityState

.setDir:
    ld a, [wCurrEntity_Dir]
    cp DIR_RIGHT
    ret z

    xor a
    ld [wCurrEntity_AnimCtr], a
	ld a, DIR_RIGHT
	ld [wCurrEntity_Dir], a
    ret


ProcessEntDirectionsInput:
    ld a, [wCurrEntity_InputCtrl]
    bit ENTCTRL_DIR_MOVABLE, a
    ret z

; Entity can't be moving already
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

    ld b, ENTSTATE_STILL
    jp SetEntityState


ProcessEntWallWalk:
    ld a, [wCurrEntity_InputCtrl]
    bit ENTCTRL_WALL_WALKING, a
    ret z

; Entity can't be moving already
    ld a, [wCurrEntity_MoveCtr]
    and a
    ret nz

    ld a, [wCurrEntity_InputCtrl]
    set ENTCTRL_DIR_MOVABLE, a
    res ENTCTRL_WALL_WALKING, a
    ld [wCurrEntity_InputCtrl], a

    ld b, ENTSTATE_STILL
    jp SetEntityState


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
    xor a
    ld [wCurrEntity_AnimIdx], a

; HL = table of state ptrs, eg AnimDefSimple
    ld a, [wCurrEntity_AnimDef]
    ld l, a
    ld a, [wCurrEntity_AnimDef+1]
    ld h, a

; HL = state table of direction ptrs, eg AnimDefSimple_still
    ld a, [wCurrEntity_State]
    add a
    add l
    ld l, a
    jr nc, :+
    inc h
:   ld a, [hl+]
    ld h, [hl]
    ld l, a

; HL = anim dirs table, eg AnimDefSimple_still.up
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
    dw AnimDefSimple
    dw AnimDef2State


AnimDef2State:
    dw .still

.still:
    dw .defaultUp
    dw .defaultUp ; right
    dw .down
    dw .defaultUp ; left

.defaultUp:
    db $01, $ff
    db $fe, $00

.down:
    db $02, $ff
    db $fe, $00


WALK_CTR equ $04

AnimDefSimple:
    dw AnimDefSimple_still
    dw AnimDefSimple_moving
    dw AnimDefSimple_usingAbilities


AnimDefSimple_usingAbilities:
AnimDefSimple_still:
    dw .up
    dw .right
    dw .down
    dw .left

.up:
    db $05, $ff
    db $fe, $00

.right:
    db $0a, $ff
    db $fe, $00

.down:
    db $00, $ff
    db $fe, $00

.left:
    db $0f, $ff
    db $fe, $00


AnimDefSimple_moving:
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

; Populate 4 tile Y, X and tile idxes
:   ld a, c
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld a, [de]
    inc de
    ld [hl+], a
    push hl ; push ptr to tile attr, to -1 for tile idx (to add tile offset)
    push hl ; push ptr to tile attr
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

; Add offset to tile idxes
    ld a, [wCurrEntity_TilesBaseIdx]
    ld b, 4
    ld c, a
    pop hl
    dec hl

    .nextTileIdx:
        ld a, [hl]
        add c
        ld [hl+], a
        inc hl
        inc hl
        inc hl

        dec b
        jr nz, .nextTileIdx

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
:   ld a, [wCurrEntity_PalBaseIdx]
    ld c, a
    ld b, 4
    .nextAttr:
        ld a, [de]
        inc de
        or c
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
; each entity runs code in their script til entity_noop,
; or they don't if their script is None
wEntityIdToProcess: db

; For checking solid entities
wMetatileYXtoCheck: db