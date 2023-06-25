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
		dw .const5
		dw .const6
	.const0:
		db TYPE_INT
		db $00
	.const1:
		db TYPE_TUPLE
		db $07
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		dw .tupleItem3
		dw .tupleItem4
		dw .tupleItem5
		dw .tupleItem6
		.tupleItem0
			db TYPE_STR, $11
			db "load_bg_palettes", $ff
		.tupleItem1
			db TYPE_STR, $0e
			db "load_bg_tiles", $ff
		.tupleItem2
			db TYPE_STR, $12
			db "load_obj_palettes", $ff
		.tupleItem3
			db TYPE_STR, $0f
			db "load_obj_tiles", $ff
		.tupleItem4
			db TYPE_STR, $0a
			db "load_room", $ff
		.tupleItem5
			db TYPE_STR, $0f
			db "load_metatiles", $ff
		.tupleItem6
			db TYPE_STR, $0b
			db "add_entity", $ff
	.const2:
		db TYPE_FUNCTION
		dw PyBlock_cutscene_movement
	.const3:
		db TYPE_STR, $12
		db "cutscene_movement", $ff
	.const4:
		db TYPE_FUNCTION
		dw PyBlock_main
	.const5:
		db TYPE_STR, $05
		db "main", $ff
	.const6:
		db TYPE_NONE
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	dw .name4
	dw .name5
	dw .name6
	dw .name7
	dw .name8
	dw .name9
	db $9f
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $11, "load_bg_palettes", $ff
	.name2:
		db $0e, "load_bg_tiles", $ff
	.name3:
		db $12, "load_obj_palettes", $ff
	.name4:
		db $0f, "load_obj_tiles", $ff
	.name5:
		db $0a, "load_room", $ff
	.name6:
		db $0f, "load_metatiles", $ff
	.name7:
		db $0b, "add_entity", $ff
	.name8:
		db $12, "cutscene_movement", $ff
	.name9:
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
	db $6d, $05
	db $5a, $05
	db $6d, $06
	db $5a, $06
	db $6d, $07
	db $5a, $07
	db $01, $00
	db $64, $02
	db $64, $03
	db $84, $00
	db $5a, $08
	db $64, $04
	db $64, $05
	db $84, $00
	db $5a, $09
	db $65, $09
	db $83, $00
	db $01, $00
	db $64, $06
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
		dw .const7
		dw .const8
		dw .const9
		dw .const10
		dw .const11
		dw .const12
		dw .const13
		dw .const14
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
			db TYPE_STR, $10
			db "update_entities", $ff
		.tupleItem1
			db TYPE_STR, $0c
			db "wait_vblank", $ff
		.tupleItem2
			db TYPE_STR, $09
			db "load_vwf", $ff
	.const3:
		db TYPE_STR, $0a
		db "crypt.pal", $ff
	.const4:
		db TYPE_STR, $0b
		db "crypt.2bpp", $ff
	.const5:
		db TYPE_STR, $0a
		db "room1.bin", $ff
	.const6:
		db TYPE_STR, $11
		db "crypt_mtiles.bin", $ff
	.const7:
		db TYPE_STR, $11
		db "crypt_mattrs.bin", $ff
	.const8:
		db TYPE_STR, $08
		db "orc.pal", $ff
	.const9:
		db TYPE_STR, $09
		db "orc.2bpp", $ff
	.const10:
		db TYPE_INT
		db $05
	.const11:
		db TYPE_INT
		db $06
	.const12:
		db TYPE_STR, $0f
		db "orc_mtiles.bin", $ff
	.const13:
		db TYPE_STR, $0f
		db "orc_mattrs.bin", $ff
	.const14:
		db TYPE_STR, $1f
		db "My 	1r	2a	3i	4n	5b	6o	7w	0 VWF", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	dw .name4
	dw .name5
	dw .name6
	dw .name7
	dw .name8
	dw .name9
	dw .name10
	dw .name11
	db $c5
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $10, "update_entities", $ff
	.name2:
		db $0c, "wait_vblank", $ff
	.name3:
		db $09, "load_vwf", $ff
	.name4:
		db $11, "load_bg_palettes", $ff
	.name5:
		db $0e, "load_bg_tiles", $ff
	.name6:
		db $0f, "load_metatiles", $ff
	.name7:
		db $0a, "load_room", $ff
	.name8:
		db $12, "load_obj_palettes", $ff
	.name9:
		db $0f, "load_obj_tiles", $ff
	.name10:
		db $0b, "add_entity", $ff
	.name11:
		db $12, "cutscene_movement", $ff
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
	db $74, $04
	db $64, $03
	db $83, $01
	db $7d, $03
	db $74, $05
	db $64, $04
	db $83, $01
	db $7d, $04
	db $74, $06
	db $64, $05
	db $83, $01
	db $01, $00
	db $74, $07
	db $64, $06
	db $64, $07
	db $7c, $04
	db $7c, $03
	db $83, $04
	db $01, $00
	db $74, $08
	db $64, $08
	db $83, $01
	db $7d, $05
	db $74, $09
	db $64, $09
	db $83, $01
	db $7d, $06
	db $74, $0a
	db $64, $0a
	db $64, $0b
	db $74, $0b
	db $64, $01
	db $7c, $05
	db $7c, $06
	db $64, $0c
	db $64, $0d
	db $83, $08
	db $7d, $07
	db $7c, $02
	db $64, $0e
	db $83, $01
	db $01, $00
	db $09, $00
	db $7c, $00
	db $83, $00
	db $01, $00
	db $7c, $01
	db $83, $00
	db $01, $00
	db $71, $35


PyBlock_cutscene_movement:
	dw .consts
	dw .names
	dw .bytecode
	.consts:
		dw .const0
		dw .const1
		dw .const2
	.const0:
		db TYPE_NONE
	.const1:
		db TYPE_INT
		db $00
	.const2:
		db TYPE_TUPLE
		db $02
		dw .tupleItem0
		dw .tupleItem1
		.tupleItem0
			db TYPE_STR, $10
			db "enable_movement", $ff
		.tupleItem1
			db TYPE_STR, $0c
			db "entity_noop", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	db $2b
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $10, "enable_movement", $ff
	.name2:
		db $0c, "entity_noop", $ff
.bytecode:
	db $64, $01
	db $64, $02
	db $6c, $00
	db $6d, $01
	db $7d, $00
	db $6d, $02
	db $7d, $01
	db $01, $00
	db $7c, $00
	db $83, $00
	db $01, $00
	db $09, $00
	db $7c, $01
	db $83, $00
	db $01, $00
	db $71, $0c


FileSystem::
	db $0b, "ascii.2bpp", $ff
		dw File0
		dw File0.end-File0
	db $09, "orc.2bpp", $ff
		dw File1
		dw File1.end-File1
	db $11, "crypt_mattrs.bin", $ff
		dw File2
		dw File2.end-File2
	db $08, "orc.pal", $ff
		dw File3
		dw File3.end-File3
	db $0f, "orc_mtiles.bin", $ff
		dw File4
		dw File4.end-File4
	db $0a, "room1.bin", $ff
		dw File5
		dw File5.end-File5
	db $0b, "crypt.2bpp", $ff
		dw File6
		dw File6.end-File6
	db $11, "crypt_mtiles.bin", $ff
		dw File7
		dw File7.end-File7
	db $0a, "crypt.pal", $ff
		dw File8
		dw File8.end-File8
	db $0f, "orc_mattrs.bin", $ff
		dw File9
		dw File9.end-File9
	db $ff

File0:
	INCBIN "data/ascii.2bpp"
.end:

File1:
	INCBIN "data/orc.2bpp"
.end:

File2:
	INCBIN "data/crypt_mattrs.bin"
.end:

File3:
	INCBIN "data/orc.pal"
.end:

File4:
	INCBIN "data/orc_mtiles.bin"
.end:

File5:
	INCBIN "data/room1.bin"
.end:

File6:
	INCBIN "data/crypt.2bpp"
.end:

File7:
	INCBIN "data/crypt_mtiles.bin"
.end:

File8:
	INCBIN "data/crypt.pal"
.end:

File9:
	INCBIN "data/orc_mattrs.bin"
.end:
