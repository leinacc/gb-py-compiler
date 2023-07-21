;-----------------------------------------------------------------------------
; Heap
;-----------------------------------------------------------------------------
;
; * chunks:
;   * 0:backward_ptr.w - ptr to the prev chunk, or $ffxx if the 1st (todo: seems useless)
;   * 2:forward_ptr.w - ptr to the next chunk, or $ffxx if the last allocated data
;   * 4:size.w - size of chunk including the 6-byte header
;   * 6:is_free.b - if the chunk had been freed, and is ready for re-use
;   * 7:user data - allocated data
;   * are contiguous
; * allocate process:
;   * loop through chunks, finding free chunks, or until we reach the last chunk
;   * if the free chunk can accommodate our chunk, re-use it
;   * else use the last chunk's size to find the next place to allocate data
;   * store chunk data
;   * update prev chunk's forward ptr to point to the new chunk
;   * update main_ptr to point to the new chunk
;   * return a pointer to the new chunk
; * free process:
;   * get a pointer to a chunk
;   * mark it as free ($ff)
;
;-----------------------------------------------------------------------------

SECTION "Python VM Heap Code", ROM0

InitHeap::
	xor a
	ldh [hHeapInitd], a
	ret


; BC - size
; Returns HL = pointer to the user data to fill
; Trashes A, DE, HL
Malloc::
; BC to include header
	ld a, 7
	add c
	ld c, a
	jr nc, :+
	inc b

; Start looping from the start of heap, until we get:
; * a free chunk that can hold BC OR
; * the last chunk (has forward_ptr of $ff)
:	ld hl, wHeapData

	ldh a, [hHeapInitd]
	and a
	jr nz, .checkChunk

	inc a
	ldh [hHeapInitd], a
	ld de, $ffff
	jr .alloc

.checkChunk:
	push hl
	inc hl
	inc hl
	inc hl
	ld a, [hl+] ; read from HIGH(forward_ptr)
	cp $ff
	jr z, .foundLastChunk

; DE = the curr chunk's size
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl] ; is_free
	and a
	jr nz, .checkIfFreeChunkIsBigEnough

.toNextChunk:
; Not the last chunk, or free, so go to the next chunk
	pop hl
	add hl, de
	jr .checkChunk

.checkIfFreeChunkIsBigEnough:
; This is not the last chunk, so we don't override the forwards_ptr
	ld a, e
	sub c
	ld a, d
	sbc b
	jr nc, .chunkIsBigEnough

	jr .toNextChunk

.chunkIsBigEnough:
; Set that it's no longer free
	pop af
	xor a
	ld [hl+], a
	ret

.foundLastChunk:
; DE = the curr chunk's size
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a

; HL = the curr chunk, then the chunk to use, DE = the prev chunk
	pop hl
	push hl

	add hl, de
	pop de

; Fill the prev chunk's forwards_ptr
	inc de
	inc de
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	dec de
	dec de
	dec de

.alloc:
; Fill the curr chunk's details (backwards_ptr=DE, forward_ptr=$ffff, size=BC, is_free=0)
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, $ff
	ld [hl+], a
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a
	xor a
	ld [hl+], a
	ret


; HL - ptr to a chunk's userdata to free
Free::
	dec hl
	ld a, $ff
	ld [hl], a
	ret


SECTION "PyVM Heap Hram", HRAM
hHeapInitd: db

SECTION "PyVM Heap Wram", WRAMX[$dc00] ; ALIGN[8]
wHeapData:: ds $400
.end::
; todo: fix bug in that despite checking for wHeapData.end, we can still allocate over it
