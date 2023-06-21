INCLUDE "defines.asm"

SECTION "Entities code", ROM0

InitEntites::
    ld hl, wEntity00
    ld bc, (wEntity01-wEntity00)*NUM_ENTITIES
    xor a
    rst Memset
    ret


; A - animation definition idx
; B - tile x
; C - tile y
; DE - addr of script (bank is the current one)
; H - pals base idx
; L - tiles base idx
AddEntity::
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

    pop de
    ld a, d
    ld [hl+], a
    ld [hl], e

    ret


UpdateEntities::
    ld hl, wEntity00_InUse
    ld b, NUM_ENTITIES
    ld de, wEntity01-wEntity00
    .nextEntity
        push hl
        push bc

        ld a, [hl]
        and a
        jr z, .toNextEntity

        ld a, l
        add wEntity00_ScreenX-wEntity00
        ld l, a
        jr nc, :+
        inc h
    :   ld a, [hl+]
        add 8
        ld b, a
        ld a, [hl]
        add 16
        ld c, a

        ld hl, wShadowOAM
        ld a, c
        ld [hl+], a
        ld a, b
        ld [hl+], a
        ld a, $00
        ld [hl+], a
        ld a, $00
        ld [hl+], a

        ld a, c
        ld [hl+], a
        ld a, b
        add 8
        ld [hl+], a
        ld a, $00
        ld [hl+], a
        ld a, $20
        ld [hl+], a

        ld a, c
        add 8
        ld [hl+], a
        ld a, b
        ld [hl+], a
        ld a, $04
        ld [hl+], a
        ld a, $00
        ld [hl+], a

        ld a, c
        add 8
        ld [hl+], a
        ld a, b
        add 8
        ld [hl+], a
        ld a, $04
        ld [hl+], a
        ld a, $20
        ld [hl+], a

    .toNextEntity:
        pop bc
        pop hl
        add hl, de
        dec b
        jr nz, .nextEntity

    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a
    ret


AnimTable:
    dl AnimDefSimple


AnimDefSimple:
    db 0


SECTION "Entities ram", WRAM0
FOR N, NUM_ENTITIES
    dstruct Entity, wEntity{02x:N}
ENDR
