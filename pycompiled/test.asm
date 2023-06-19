PyBlock__module_:
	dw .consts
	dw .names
	dw .bytecode
	.consts:
		dw .const0
		dw .const1
		dw .const2
		dw .const3
		dw .const4
	.const0:
		db TYPE_INT
		db $00
	.const1:
		db TYPE_TUPLE
		db $04
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		dw .tupleItem3
		.tupleItem0
			db TYPE_STR, $0e
			db "load_palettes", $ff
		.tupleItem1
			db TYPE_STR, $0b
			db "load_tiles", $ff
		.tupleItem2
			db TYPE_STR, $0a
			db "load_room", $ff
		.tupleItem3
			db TYPE_STR, $0f
			db "load_metatiles", $ff
	.const2:
		db TYPE_FUNCTION
		dw PyBlock_main
	.const3:
		db TYPE_STR, $05
		db "main", $ff
	.const4:
		db TYPE_NONE
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	dw .name4
	dw .name5
	db $4f
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $0e, "load_palettes", $ff
	.name2:
		db $0b, "load_tiles", $ff
	.name3:
		db $0a, "load_room", $ff
	.name4:
		db $0f, "load_metatiles", $ff
	.name5:
		db $05, "main", $ff
.bytecode:
	db $64, $00
	db $64, $01
	db $6c, $00
	db $6d, $01
	db $5a, $01
	db $6d, $02
	db $5a, $02
	db $6d, $03
	db $5a, $03
	db $6d, $04
	db $5a, $04
	db $01, $00
	db $64, $02
	db $64, $03
	db $84, $00
	db $5a, $05
	db $65, $05
	db $83, $00
	db $01, $00
	db $64, $04
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
	.const0:
		db TYPE_NONE
	.const1:
		db TYPE_STR, $0a
		db "crypt.pal", $ff
	.const2:
		db TYPE_STR, $0c
		db "crypt.tiles", $ff
	.const3:
		db TYPE_STR, $0a
		db "room1.bin", $ff
	.const4:
		db TYPE_STR, $11
		db "crypt_mtiles.bin", $ff
	.const5:
		db TYPE_STR, $11
		db "crypt_mattrs.bin", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	db $3f
	.name0:
		db $0e, "load_palettes", $ff
	.name1:
		db $0b, "load_tiles", $ff
	.name2:
		db $0a, "load_room", $ff
	.name3:
		db $0f, "load_metatiles", $ff
.bytecode:
	db $74, $00
	db $64, $01
	db $83, $01
	db $01, $00
	db $74, $01
	db $64, $02
	db $83, $01
	db $01, $00
	db $74, $02
	db $64, $03
	db $83, $01
	db $01, $00
	db $74, $03
	db $64, $04
	db $64, $05
	db $83, $02
	db $01, $00
	db $64, $00
	db $53, $00


FileSystem::
	db $0b, "ascii.2bpp", $ff
		dw File0
		dw File0.end-File0
	db $0c, "crypt.tiles", $ff
		dw File1
		dw File1.end-File1
	db $11, "crypt_mattrs.bin", $ff
		dw File2
		dw File2.end-File2
	db $0a, "room1.bin", $ff
		dw File3
		dw File3.end-File3
	db $11, "crypt_mtiles.bin", $ff
		dw File4
		dw File4.end-File4
	db $0a, "crypt.pal", $ff
		dw File5
		dw File5.end-File5
	db $ff

File0:
	INCBIN "data/ascii.2bpp"
.end:

File1:
	INCBIN "data/crypt.tiles"
.end:

File2:
	INCBIN "data/crypt_mattrs.bin"
.end:

File3:
	INCBIN "data/room1.bin"
.end:

File4:
	INCBIN "data/crypt_mtiles.bin"
.end:

File5:
	INCBIN "data/crypt.pal"
.end:
