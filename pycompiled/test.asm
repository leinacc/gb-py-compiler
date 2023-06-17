PyBlock__module_:
	dw .consts
	dw .names
	dw .bytecode
	.consts:
		dw .const0
		dw .const1
		dw .const2
	.const0:
		dw PyBlock_main
	.const1:
		db TYPE_STR, $05
		db "main", $ff
	.const2:
		db TYPE_NONE
.names:
	dw .name0
	.name0:
		db $05, "main", $ff
.bytecode:
	db $64, $00
	db $64, $01
	db $84, $00
	db $5a, $00
	db $64, $02
	db $53, $00


PyBlock_main:
	dw .consts
	dw .names
	dw .bytecode
	.consts:
		dw .const0
		dw .const1
		dw .const2
		dw .const3
		dw .const4
		dw .const5
		dw .const6
	.const0:
		db TYPE_NONE
	.const1:
		db TYPE_INT
		db $00
	.const2:
		db TYPE_TUPLE
		db $03
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		.tupleItem0
			db TYPE_STR, $0b
			db "load_tiles", $ff
		.tupleItem1
			db TYPE_STR, $0d
			db "print_string", $ff
		.tupleItem2
			db TYPE_STR, $0c
			db "wait_vblank", $ff
	.const3:
		db TYPE_STR, $0b
		db "ascii.2bpp", $ff
	.const4:
		db TYPE_INT
		db $17
	.const5:
		db TYPE_STR, $11
		db "Hello,\nGBCompo '", $ff
	.const6:
		db TYPE_STR, $02
		db "!", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $0b, "load_tiles", $ff
	.name2:
		db $0d, "print_string", $ff
	.name3:
		db $0c, "wait_vblank", $ff
.bytecode:
	db $64, $01
	db $64, $02
	db $6c, $00
	db $6d, $01
	db $7d, $00
	db $6d, $02
	db $7d, $01
	db $6d, $03
	db $7d, $02
	db $01, $00
	db $7c, $00
	db $64, $03
	db $83, $01
	db $7d, $03
	db $64, $04
	db $7d, $04
	db $7c, $01
	db $64, $05
	db $7c, $04
	db $9b, $00
	db $64, $06
	db $9d, $03
	db $7c, $03
	db $83, $02
	db $01, $00
	db $09, $00
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $1a


FileSystem::
	dw .next0
	db $0b, "ascii.2bpp", $ff
		dw File0
		dw File0.end-File0
.next0:
	dw $ffff

File0:
	INCBIN "data/ascii.2bpp"
.end:
