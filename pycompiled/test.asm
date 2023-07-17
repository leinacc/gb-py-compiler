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
		dw .const7
		dw .const8
		dw .const9
		dw .const10
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
		db TYPE_NONE
	.const3:
		db TYPE_FUNCTION
		dw PyBlock_player_movement
	.const4:
		db TYPE_STR, $10
		db "player_movement", $ff
	.const5:
		db TYPE_FUNCTION
		dw PyBlock_door_script
	.const6:
		db TYPE_STR, $0c
		db "door_script", $ff
	.const7:
		db TYPE_FUNCTION
		dw PyBlock_pplate_script
	.const8:
		db TYPE_STR, $0e
		db "pplate_script", $ff
	.const9:
		db TYPE_FUNCTION
		dw PyBlock_main
	.const10:
		db TYPE_STR, $05
		db "main", $ff
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
	dw .name12
	dw .name13
	db $cf
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
		db $07, "player", $ff
	.name9:
		db $05, "door", $ff
	.name10:
		db $10, "player_movement", $ff
	.name11:
		db $0c, "door_script", $ff
	.name12:
		db $0e, "pplate_script", $ff
	.name13:
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
	db $61, $08
	db $64, $02
	db $61, $09
	db $64, $03
	db $64, $04
	db $84, $00
	db $5a, $0a
	db $64, $05
	db $64, $06
	db $84, $00
	db $5a, $0b
	db $64, $07
	db $64, $08
	db $84, $00
	db $5a, $0c
	db $64, $09
	db $64, $0a
	db $84, $00
	db $5a, $0d
	db $65, $0d
	db $83, $00
	db $01, $00
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
		dw .const7
		dw .const8
		dw .const9
		dw .const10
		dw .const11
		dw .const12
		dw .const13
		dw .const14
		dw .const15
		dw .const16
		dw .const17
		dw .const18
		dw .const19
		dw .const20
		dw .const21
		dw .const22
		dw .const23
		dw .const24
		dw .const25
		dw .const26
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
			db "update_entities", $ff
		.tupleItem1
			db TYPE_STR, $0c
			db "wait_vblank", $ff
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
		db TYPE_STR, $09
		db "door.pal", $ff
	.const15:
		db TYPE_STR, $0a
		db "door.2bpp", $ff
	.const16:
		db TYPE_INT
		db $0c
	.const17:
		db TYPE_INT
		db $08
	.const18:
		db TYPE_INT
		db $01
	.const19:
		db TYPE_STR, $10
		db "door_mtiles.bin", $ff
	.const20:
		db TYPE_STR, $10
		db "door_mattrs.bin", $ff
	.const21:
		db TYPE_STR, $13
		db "pressure_plate.pal", $ff
	.const22:
		db TYPE_STR, $14
		db "pressure_plate.2bpp", $ff
	.const23:
		db TYPE_INT
		db $0a
	.const24:
		db TYPE_INT
		db $04
	.const25:
		db TYPE_STR, $1a
		db "pressure_plate_mtiles.bin", $ff
	.const26:
		db TYPE_STR, $1a
		db "pressure_plate_mattrs.bin", $ff
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
	dw .name12
	dw .name13
	dw .name14
	db $e9
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $10, "update_entities", $ff
	.name2:
		db $0c, "wait_vblank", $ff
	.name3:
		db $11, "load_bg_palettes", $ff
	.name4:
		db $0e, "load_bg_tiles", $ff
	.name5:
		db $0f, "load_metatiles", $ff
	.name6:
		db $0a, "load_room", $ff
	.name7:
		db $12, "load_obj_palettes", $ff
	.name8:
		db $0f, "load_obj_tiles", $ff
	.name9:
		db $0b, "add_entity", $ff
	.name10:
		db $10, "player_movement", $ff
	.name11:
		db $07, "player", $ff
	.name12:
		db $0c, "door_script", $ff
	.name13:
		db $05, "door", $ff
	.name14:
		db $0e, "pplate_script", $ff
.bytecode:
	db $64, $01
	db $64, $02
	db $6c, $00
	db $6d, $01
	db $7d, $00
	db $6d, $02
	db $7d, $01
	db $01, $00
	db $74, $03
	db $64, $03
	db $83, $01
	db $7d, $02
	db $74, $04
	db $64, $04
	db $83, $01
	db $7d, $03
	db $74, $05
	db $64, $05
	db $83, $01
	db $01, $00
	db $74, $06
	db $64, $06
	db $64, $07
	db $7c, $03
	db $7c, $02
	db $83, $04
	db $01, $00
	db $74, $07
	db $64, $08
	db $83, $01
	db $7d, $04
	db $74, $08
	db $64, $09
	db $83, $01
	db $7d, $05
	db $74, $09
	db $64, $0a
	db $64, $0b
	db $74, $0a
	db $64, $01
	db $7c, $04
	db $7c, $05
	db $64, $0c
	db $64, $0d
	db $83, $08
	db $61, $0b
	db $74, $07
	db $64, $0e
	db $83, $01
	db $7d, $06
	db $74, $08
	db $64, $0f
	db $83, $01
	db $7d, $07
	db $74, $09
	db $64, $10
	db $64, $11
	db $74, $0c
	db $64, $12
	db $7c, $06
	db $7c, $07
	db $64, $13
	db $64, $14
	db $83, $08
	db $61, $0d
	db $74, $07
	db $64, $15
	db $83, $01
	db $7d, $08
	db $74, $08
	db $64, $16
	db $83, $01
	db $7d, $09
	db $74, $09
	db $64, $17
	db $64, $18
	db $74, $0e
	db $64, $12
	db $7c, $08
	db $7c, $09
	db $64, $19
	db $64, $1a
	db $83, $08
	db $01, $00
	db $09, $00
	db $7c, $00
	db $83, $00
	db $01, $00
	db $7c, $01
	db $83, $00
	db $01, $00
	db $71, $55


PyBlock_pplate_script:
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
		db $03
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		.tupleItem0
			db TYPE_STR, $0e
			db "collides_with", $ff
		.tupleItem1
			db TYPE_STR, $14
			db "disable_other_solid", $ff
		.tupleItem2
			db TYPE_STR, $0c
			db "entity_noop", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	dw .name4
	dw .name5
	db $52
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $0e, "collides_with", $ff
	.name2:
		db $14, "disable_other_solid", $ff
	.name3:
		db $0c, "entity_noop", $ff
	.name4:
		db $07, "player", $ff
	.name5:
		db $05, "door", $ff
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
	db $09, $00
	db $09, $00
	db $7c, $00
	db $74, $04
	db $83, $01
	db $72, $15
	db $7c, $01
	db $74, $05
	db $83, $01
	db $01, $00
	db $6e, $04
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $0c
	db $09, $00
	db $7c, $00
	db $74, $04
	db $83, $01
	db $73, $1f
	db $6e, $04
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $1a
	db $71, $0b


PyBlock_door_script:
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
			db TYPE_STR, $0d
			db "enable_solid", $ff
		.tupleItem1
			db TYPE_STR, $0c
			db "entity_noop", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	db $28
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $0d, "enable_solid", $ff
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


PyBlock_player_movement:
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
		db $03
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		.tupleItem0
			db TYPE_STR, $10
			db "enable_movement", $ff
		.tupleItem1
			db TYPE_STR, $11
			db "enable_abilities", $ff
		.tupleItem2
			db TYPE_STR, $0d
			db "allow_1_move", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	db $40
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $10, "enable_movement", $ff
	.name2:
		db $11, "enable_abilities", $ff
	.name3:
		db $0d, "allow_1_move", $ff
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
	db $83, $00
	db $01, $00
	db $7c, $01
	db $83, $00
	db $01, $00
	db $09, $00
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $11


FileSystem::
	db $0b, "ascii.2bpp", $ff
		dw File0
		dw File0.end-File0
	db $10, "door_mattrs.bin", $ff
		dw File1
		dw File1.end-File1
	db $09, "door.pal", $ff
		dw File2
		dw File2.end-File2
	db $09, "orc.2bpp", $ff
		dw File3
		dw File3.end-File3
	db $14, "pressure_plate.2bpp", $ff
		dw File4
		dw File4.end-File4
	db $11, "crypt_mattrs.bin", $ff
		dw File5
		dw File5.end-File5
	db $1a, "pressure_plate_mtiles.bin", $ff
		dw File6
		dw File6.end-File6
	db $08, "orc.pal", $ff
		dw File7
		dw File7.end-File7
	db $1a, "pressure_plate_mattrs.bin", $ff
		dw File8
		dw File8.end-File8
	db $0f, "orc_mtiles.bin", $ff
		dw File9
		dw File9.end-File9
	db $10, "door_mtiles.bin", $ff
		dw File10
		dw File10.end-File10
	db $0a, "room1.bin", $ff
		dw File11
		dw File11.end-File11
	db $0b, "crypt.2bpp", $ff
		dw File12
		dw File12.end-File12
	db $11, "crypt_mtiles.bin", $ff
		dw File13
		dw File13.end-File13
	db $0a, "door.2bpp", $ff
		dw File14
		dw File14.end-File14
	db $13, "pressure_plate.pal", $ff
		dw File15
		dw File15.end-File15
	db $0a, "crypt.pal", $ff
		dw File16
		dw File16.end-File16
	db $0f, "orc_mattrs.bin", $ff
		dw File17
		dw File17.end-File17
	db $ff

File0:
	INCBIN "data/ascii.2bpp"
.end:

File1:
	INCBIN "data/door_mattrs.bin"
.end:

File2:
	INCBIN "data/door.pal"
.end:

File3:
	INCBIN "data/orc.2bpp"
.end:

File4:
	INCBIN "data/pressure_plate.2bpp"
.end:

File5:
	INCBIN "data/crypt_mattrs.bin"
.end:

File6:
	INCBIN "data/pressure_plate_mtiles.bin"
.end:

File7:
	INCBIN "data/orc.pal"
.end:

File8:
	INCBIN "data/pressure_plate_mattrs.bin"
.end:

File9:
	INCBIN "data/orc_mtiles.bin"
.end:

File10:
	INCBIN "data/door_mtiles.bin"
.end:

File11:
	INCBIN "data/room1.bin"
.end:

File12:
	INCBIN "data/crypt.2bpp"
.end:

File13:
	INCBIN "data/crypt_mtiles.bin"
.end:

File14:
	INCBIN "data/door.2bpp"
.end:

File15:
	INCBIN "data/pressure_plate.pal"
.end:

File16:
	INCBIN "data/crypt.pal"
.end:

File17:
	INCBIN "data/orc_mattrs.bin"
.end:
