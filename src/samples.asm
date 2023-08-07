INCLUDE "defines.asm"

SECTION "Samples", ROM0

ExampleSamplesTest::
	ld de, StarsTileData
	call BHLequFarSrcOfFilenameInDEsSrcLen
	call FarAllocateBGTileData

	ld de, StarsPalettes
	call BHLequFarSrcOfFilenameInDEsSrcLen
	call FarAllocateBGPalettes

	ld c, $20
	ld hl, $9800
	xor a
	.nextRow:
		ld b, 8
		.next4Cols:
			push af
			wait_vram
			pop af

			ld [hl+], a
			inc a

			push af
			wait_vram
			pop af

			ld [hl+], a
			inc a

			push af
			wait_vram
			pop af

			ld [hl+], a
			inc a

			push af
			wait_vram
			pop af

			ld [hl+], a
			sub 3

			dec b
			jr nz, .next4Cols

		add 4
		cp $10
		jr nz, :+
		xor a

	:	dec c
		jr nz, .nextRow

	xor a
	ldh [hSCY], a

; Turn on the screen
	ldh a, [hLCDC]
	or LCDCF_ON
	ldh [hLCDC], a
	ldh [rLCDC], a
	rst WaitVBlank

	call PlaySample

	.nextFrame:
	:	ldh a, [rLY]
		cp $90
		jr c, :-

		ldh a, [hSCY]
		ldh [rSCY], a
		add 3
		ldh [hSCY], a
	
	:	ldh a, [rLY]
		cp $90
		jr nc, :-

		jr .nextFrame

:	rst WaitVBlank
	jr :-

StarsTileData:
	Str "stars.2bpp"

StarsPalettes:
	Str "stars.pal"


PlaySample::
	call SetupAudioRegs
    call LoadTimerInterrupt
	call StartVoiceSample
	jp StartStatInterrupt


SetupAudioRegs:
; Clear all audio regs
	ld a, $8f
	ldh [rAUDENA], a
	xor a
	ldh [rAUDVOL], a
	ld a, $ff
	ldh [rAUDTERM], a
	xor a
	ldh [rAUDVOL], a
	ldh [rAUD1HIGH], a
	ldh [rAUD1SWEEP], a
	ldh [rAUD1LEN], a
	ldh [rAUD1ENV], a
	ldh [rAUD1LOW], a
	ldh [rAUD2HIGH], a
	ldh [rAUD2LEN], a
	ldh [rAUD2ENV], a
	ldh [rAUD2LOW], a
	ldh [rAUD3ENA], a
	ldh [rAUD4POLY], a
	ldh [rAUD4ENV], a
	ldh [rAUD4LEN], a
	ldh [rAUD3HIGH], a
	ldh [rAUD3ENA], a
	ldh [rAUD3LEN], a
	ldh [rAUD3LOW], a

; Fill all $10 bytes of wave ram
	ld a, $ff     
	ld hl, _AUD3WAVERAM 
:	ld [hl+], a   
	bit 4, l      
	jr nz, :-

; Set all audio regs
	ld a, $20     
	ldh [rAUD3LEVEL], a
	ld a, $ff     
	ldh [rAUD3LOW], a
	ld a, $07     
	ldh [rAUD3HIGH], a
	ld a, $80     
	ldh [rAUD3ENA], a
	ld a, $08     
	ldh [rAUD1SWEEP], a
	ld a, $c7     
	ldh [rAUD1LEN], a
	ld a, $f8     
	ldh [rAUD1ENV], a
	ld a, $ff     
	ldh [rAUD1LOW], a
	ld a, $07     
	ldh [rAUD1HIGH], a
	ld a, $ff     
	ldh [rAUD2LEN], a
	ld a, $f8     
	ldh [rAUD2ENV], a
	ld a, $ff     
	ldh [rAUD2LOW], a
	ld a, $07     
	ldh [rAUD2HIGH], a
	ld a, $ff     
	ldh [rAUD4LEN], a
	ldh [rAUD4POLY], a
	ld a, $f8     
	ldh [rAUD4ENV], a
	xor a         
	ldh [rAUD3ENA], a
	ret


LoadTimerInterrupt:
    ld hl, hTimerInterrupt
    ld de, .timerInt
    ld c, hTimerInterrupt.end-hTimerInterrupt
    rst MemcpySmall
    ret

.timerInt:
LOAD "Voice Samples Code", HRAM
hTimerInterrupt::
; Change this `reti` to `push af` to enable voice samples
	reti

.loadAddr:
; Load in the next sample byte into AUDVOL
	ld a, [wSampleBuffer0]
	ldh [rAUDVOL], a

; Inc sample src, flipping page, once a buffer's end is reached
	ldh a, [.loadAddr+1]
	inc a
	ldh [.loadAddr+1], a
	jr z, .flipPage

	pop af
	reti

.flipPage:
	ldh a, [.loadAddr+2]
	xor $01
	ldh [.loadAddr+2], a
	pop af
	reti

.end:
ENDL


StartVoiceSample:
    ld a, _RETI
    ldh [hTimerInterrupt], a

; Preserve rom bank
    ldh a, [hCurROMBank]
    ld [wSamplesPreservedRomBank], a

; Save samples rom bank and addr (keeping it in HL)
    ld hl, ExampleSample0
    ld a, BANK(ExampleSample0)
    ld [wSamplesRomBank], a
    ldh [hCurROMBank], a
    ld [rROMB0], a

    ld a, l
    ld [wCurrSamplesSrc], a
    ld a, h
    ld [wCurrSamplesSrc+1], a

; todo: get the 'num pages' from automation (in this case $4eb)
    ld a, LOW($05e2)
    ld [wPagesOfSamplesLeft], a
    ld a, HIGH($05e2)
    ld [wPagesOfSamplesLeft+1], a

; Set sample rate to get around 15KHz
    ld a, $df
    ldh [rTMA], a

;
    ldh a, [hTimerInterrupt.loadAddr+2]
    xor $01
    ld [wPageHiToReadSamplesOff], a

; Skip to this inner routine as we've already preserved the curr rom bank
    call LoadAPageOfVoiceSamplesBankUnpreserved

; Set this to $ff, so we read off the page we just loaded soon
    ld a, $ff
    ldh [hTimerInterrupt.loadAddr+1], a
    ld a, $44
    ld [wSampleBuffer0+$ff], a

    ld a, TACF_START|TACF_262KHZ
    ldh [rTAC], a
    ld hl, rIF
    res IEB_TIMER, [hl]
    ld hl, rIE
    set IEB_TIMER, [hl]
    ret


StartStatInterrupt:
; Set lcdc int address
    ld a, _JP
    ld [wStatInterrupt], a
    ld a, LOW(.statInt)
    ld [wStatInterrupt+1], a
    ld a, HIGH(.statInt)
    ld [wStatInterrupt+2], a

; Set relevant hardware regs to populate buffer at scanline 5
    ld a, STATF_LYC
    ldh [rSTAT], a
    ld hl, rIF
    res IEB_STAT, [hl]
    ld hl, rIE
    set IEB_STAT, [hl]
    ld a, $05
    ldh [rLYC], a

; Enable timer interrupt - to read from samples
    ld a, PUSH_AF
    ldh [hTimerInterrupt], a

    xor a
    ldh [rIF], a
    ret

.statInt:
    push af
    push hl

; Start letting timer read sample bytes
    ld hl, rIF
    res IEB_TIMER, [hl]
    ld hl, rIE
    set IEB_TIMER, [hl]
    ei

; If a voice sample is playing, load a page
    ldh a, [hTimerInterrupt]
    cp PUSH_AF
    jr nz, :+
    call LoadAPageOfVoiceSamples

:   pop hl
    pop af
    reti


LoadAPageOfVoiceSamples:
    ldh a, [hCurROMBank]
    ld [wSamplesPreservedRomBank], a

LoadAPageOfVoiceSamplesBankUnpreserved:
; Don't populate the page we're reading from
    ld a, [wPageHiToReadSamplesOff]
    ld b, a
    ldh a, [hTimerInterrupt.loadAddr+2]
    cp b
    ret z

; Set the new page that will be read off
    ld [wPageHiToReadSamplesOff], a

; Jump if we've got pages of samples left
    ld a, [wPagesOfSamplesLeft]
    dec a
    ld [wPagesOfSamplesLeft], a
    jr nz, .start

    ld a, [wPagesOfSamplesLeft+1]
    dec a
    ld [wPagesOfSamplesLeft+1], a
    jr nz, .start

; Else stop the entire setup
    ld a, _RETI
    ldh [hTimerInterrupt], a
    ld [wStatInterrupt], a

; todo: clear other things - reenable vblank int
    jr .restoreBank

.start:
; DE = the curr sample src addr. Also set the sample src bank
    ld a, [wCurrSamplesSrc]
    ld e, a
    ld a, [wCurrSamplesSrc+1]
    ld d, a

    ld a, [wSamplesRomBank]
    ldh [hCurROMBank], a
    ld [rROMB0], a

; HL = the beginning of the page to populate
    ldh a, [hTimerInterrupt.loadAddr+2]
    xor $01
    ld h, a
    ld l, $00

    .nextSampleByte:
    ; Get a new sample byte, inc'ing samples bank if we've reached the end
        ld a, [de]
        inc de
        ld b, a

        bit 7, d
        jr z, .storeSampleByte

        res 7, d
        set 6, d
        ld a, [wSamplesRomBank]
        inc a
        ld [wSamplesRomBank], a
        ldh [hCurROMBank], a
        ld [rROMB0], a
        ld a, b

    .storeSampleByte:
        ld [hl+], a

    ; End once a whole page is read
        ld a, l
        and a
        jr nz, .nextSampleByte

    ld a, d
    ld [wCurrSamplesSrc+1], a
    ld a, e
    ld [wCurrSamplesSrc], a

.restoreBank:
    ld a, [wSamplesPreservedRomBank]
    ldh [hCurROMBank], a
    ld [rROMB0], a
    ret


SAMPLE_START_BANK = $07
SAMPLE_FULL_BANKS = $13

FOR N, SAMPLE_FULL_BANKS

SECTION "Sample{N}", ROMX[$4000], BANK[SAMPLE_START_BANK+N]

ExampleSample{x:N}:
    INCBIN "res/kh_sample.bin", $4000*N, $4000

ENDR

SECTION "SampleLast", ROMX[$4000], BANK[SAMPLE_START_BANK+SAMPLE_FULL_BANKS]

ExampleSampleLast:
    INCBIN "res/kh_sample.bin", $4000*SAMPLE_FULL_BANKS


SECTION "Samples buffers", WRAM0, ALIGN[8]

wSampleBuffer0:
    ds $100
wSampleBuffer1:
    ds $100


SECTION "Samples misc vars", WRAM0

wSamplesRomBank:
    db
wCurrSamplesSrc:
    dw

wPagesOfSamplesLeft:
    dw

wPageHiToReadSamplesOff:
    db

wSamplesPreservedRomBank:
    db

wStatInterrupt::
    ds 3
