
; First, let's include libraries

INCLUDE "hardware.inc/hardware.inc"
	rev_Check_hardware_inc 3.0

INCLUDE "rgbds-structs/structs.asm"


; A couple more hardware defines

NB_SPRITES equ 40


; I generally discourage the use of pseudo-instructions for a variety of reasons,
; but this one includes a label, and manually giving them different names is tedious.
MACRO wait_vram
.waitVRAM\@
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .waitVRAM\@
ENDM

; `ld b, X` followed by `ld c, Y` is wasteful (same with other reg pairs).
; This writes to both halves of the pair at once, without sacrificing readability
; Example usage: `lb bc, X, Y`
MACRO lb
	assert -128 <= (\2) && (\2) <= 255, "Second argument to `lb` must be 8-bit!"
	assert -128 <= (\3) && (\3) <= 255, "Third argument to `lb` must be 8-bit!"
	ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM


; SGB packet types
RSRESET
PAL01     rb 1
PAL23     rb 1
PAL12     rb 1
PAL03     rb 1
ATTR_BLK  rb 1
ATTR_LIN  rb 1
ATTR_DIV  rb 1
ATTR_CHR  rb 1
SOUND     rb 1 ; $08
SOU_TRN   rb 1
PAL_SET   rb 1
PAL_TRN   rb 1
ATRC_EN   rb 1
TEST_EN   rb 1
ICON_EN   rb 1
DATA_SND  rb 1
DATA_TRN  rb 1 ; $10
MLT_REQ   rb 1
JUMP      rb 1
CHR_TRN   rb 1
PCT_TRN   rb 1
ATTR_TRN  rb 1
ATTR_SET  rb 1
MASK_EN   rb 1
OBJ_TRN   rb 1 ; $18
PAL_PRI   rb 1

SGB_PACKET_SIZE equ 16

; sgb_packet packet_type, nb_packets, data...
MACRO sgb_packet
PACKET_SIZE equ _NARG - 1 ; Size of what's below
	db (\1 << 3) | (\2)
	REPT _NARG - 2
		SHIFT
		db \2
	ENDR

	ds SGB_PACKET_SIZE - PACKET_SIZE, 0
ENDM


; 64 bytes, should be sufficient for most purposes. If you're really starved on
; check your stack usage and consider setting this to 32 instead. 16 is probably not enough.
STACK_SIZE equ $40


; Use this to cause a crash.
; I don't recommend using this unless you want a condition:
; `call cc, Crash` is 3 bytes (`cc` being a condition); `error cc` is only 2 bytes
; This should help minimize the impact of error checking
MACRO error
	IF _NARG == 0
		rst Crash
	ELSE
		assert Crash == $0038
		; This assembles to XX FF (with XX being the `jr` instruction)
		; If the condition is fulfilled, this jumps to the operand: $FF
		; $FF encodes the instruction `rst $38`!
		jr \1, @+1
	ENDC
ENDM


; Python VM
rsreset
def TYPE_NONE rb 1
def TYPE_INT rb 1
def TYPE_TUPLE rb 1
def TYPE_STR rb 1
def TYPE_GBPY_MODULE rb 1
def TYPE_ASM rb 1
def TYPE_FUNCTION rb 1

CALL_STACK_LEN equ 8


; Entities
DIR_UP equ 0
DIR_RIGHT equ 1
DIR_DOWN equ 2
DIR_LEFT equ 3

	struct Entity
	; Keep the following in order (before the new line)
	; For init and resetting
	bytes 1, InUse
	bytes 1, TileX
	bytes 1, TileY
	bytes 3, ScriptDef
	bytes 1, ScreenX
	bytes 1, ScreenY
	bytes 3, AnimDef ; ptr to animation definition
	bytes 1, PalBaseIdx
	bytes 1, TilesBaseIdx
	bytes 3, MetatilesTilesSrc
	bytes 3, MetatilesAttrsSrc
	bytes 1, CallStackIdx

	bytes 2, AnimDirsTable
	bytes 1, AnimIdx ; which cel is being displayed
	bytes 1, AnimCtr ; num frames until next cel is displayed
	bytes 1, MetatileIdx
	bytes 1, State
	bytes 1, Dir
	bytes 1, XSpeed
	bytes 1, YSpeed
	bytes 1, MoveCtr
	; bit 0: is the entity movable with direction buttons?
	; bit 1: is the entity able to use abilities?
	bytes 1, InputCtrl
	end_struct

NUM_ENTITIES equ $10

rsreset
def ENTCTRL_DIR_MOVABLE rb 1
def ENTCTRL_USES_ABILITIES rb 1

rsreset
def ENTSTATE_STILL rb 1
def ENTSTATE_MOVING rb 1
def ENTSTATE_USING_ABILITY rb 1
