;-----------------------------------------------------------------------------
; Heap
;-----------------------------------------------------------------------------
;
; * main ptr - reference to the last chunk, or $ffxx if heap not yet used
; * chunks:
;   * backward_ptr - ptr to the prev chunk, or $ffxx if the 1st ($d000)
;   * forward_ptr - ptr to the next chunk, or $ffxx if the last allocated data
;   * size - size of chunk including the 6-byte header
;   * user data - allocated data
; * allocate process:
;   * use main_ptr to point to the last used chunk
;   * use that chunk's size to find the next place to allocate data
;   * store chunk data
;   * update prev chunk's forward ptr to point to the new chunk
;   * update main_ptr to point to the new chunk
;   * return a pointer to the new chunk
; * free process:
;   * get a pointer to a chunk
;   * get its backwards and forwards chunks
;   * link them together
;   * if backwards chunk missing (1st item was freed), set the forward chunk's backwards ptr to -1
;   * if forwards chunk missing (last allocated item was freed), main ptr points to the backwards chunk
; * defragment process (todo: when allocate can't find space):
;   * loop through linked list of chunks, until forward_ptr == $ffxx
;   * whenever forward_ptr - curr_chunk_addr > size, memcopy the forward chunk closer
;
;-----------------------------------------------------------------------------

SECTION "Python VM Heap Code", ROM0

InitHeap::
	ld a, $ff
	ldh [hHeapMainPtr], a
	ldh [hHeapMainPtr+1], a
	ret


; BC - size
; Returns HL = pointer to the user data to fill
; Trashes A, DE, HL
Malloc::
; BC to include header
	ld a, 6
	add c
	ld c, a
	jr nc, :+
	inc b
; Check main_ptr
:	ldh a, [hHeapMainPtr]
	ld e, a
	ldh a, [hHeapMainPtr+1]
	ld d, a
	cp $ff
	jr nz, .heapInUse

; Init heap
	ld a, LOW(wHeapData)
	ldh [hHeapMainPtr], a
	ld a, HIGH(wHeapData)
	ldh [hHeapMainPtr+1], a
	ld hl, wHeapData ; chunk to populate

; Fill backwards ptr
	ld a, $ff
	ld [hl+], a
	ld [hl+], a
; Forwards ptr
	ld [hl+], a
	ld [hl+], a
; Size
	ld [hl], c
	inc hl
	ld [hl], b
; HL points to user data
	inc hl
	ret

; DE = addr of curr chunk
.heapInUse:
; Deref size of chunk
	ld h, d
	ld a, e ; keep de = the next 'prev ptr'
	add 4
	ld l, a
	jr nc, :+
	inc h
:	ld a, [hl+]
	ld h, [hl]
	ld l, a ; hl = size of chunk
	add hl, de ; hl = chunk to populate

; Set backwards chunk's forwards ptr, and main_ptr
	inc de
	inc de
	ld a, l
	ld [de], a
	ldh [hHeapMainPtr], a
	inc de
	ld a, h
	ld [de], a
	ldh [hHeapMainPtr+1], a
	dec de
	dec de
	dec de

; Backwards ptr
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
; Forwards ptr
	ld a, $ff
	ld [hl+], a
	ld [hl+], a
; Size
	ld [hl], c
	inc hl
	ld [hl], b
	inc hl

	ret


; HL - ptr to chunk to free
Free::
; DE = backwards ptr
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
; BC = forwards ptr
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	cp $ff
	jr nz, .hasForwardPtr

; No forward ptr - move main_ptr, set backwards chunk's forward ptr to -1
	ld a, e
	ldh [hHeapMainPtr], a
	ld a, d
	ldh [hHeapMainPtr+1], a
; If backwards ptr is also $ff, return. Next Malloc will init heap
	cp $ff
	ret z

	inc de
	inc de
	ld a, $ff
	ld [de], a
	inc de
	ld [de], a
	ret

.hasForwardPtr:
	ld a, d
	cp $ff
	jr nz, .hasBothPtrs

; No backwards ptr, but has forward ptr - set forward chunk's backward ptr to -1
; A = $ff already
	ld [bc], a
	inc bc
	ld [bc], a
	ret

.hasBothPtrs:
	ld h, d
	ld l, e
	inc de
	inc de
; DE points to prev chunk's forward ptr
; BC points to next chunk's backwards ptr
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	ld a, [hl+]
	ld [bc], a
	ld a, [hl]
	ld [bc], a
	ret


SECTION "PyVM Heap Hram", HRAM
hHeapMainPtr: dw

SECTION "PyVM Heap Wram", WRAMX[$d000]
wHeapData:: ds $1000
