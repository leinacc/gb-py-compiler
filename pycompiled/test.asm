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
		db $08
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		dw .tupleItem3
		dw .tupleItem4
		dw .tupleItem5
		dw .tupleItem6
		dw .tupleItem7
		.tupleItem0
			db TYPE_STR
			Str "load_bg_palettes"
		.tupleItem1
			db TYPE_STR
			Str "load_bg_tiles"
		.tupleItem2
			db TYPE_STR
			Str "load_obj_palettes"
		.tupleItem3
			db TYPE_STR
			Str "load_obj_tiles"
		.tupleItem4
			db TYPE_STR
			Str "load_room"
		.tupleItem5
			db TYPE_STR
			Str "load_metatiles"
		.tupleItem6
			db TYPE_STR
			Str "add_entity"
		.tupleItem7
			db TYPE_STR
			Str "show_status"
	.const2:
		db TYPE_NONE
	.const3:
		db TYPE_FUNCTION
		dw PyBlock_player_movement
	.const4:
		db TYPE_STR
		Str "player_movement"
	.const5:
		db TYPE_FUNCTION
		dw PyBlock_door_script
	.const6:
		db TYPE_STR
		Str "door_script"
	.const7:
		db TYPE_FUNCTION
		dw PyBlock_pplate_script
	.const8:
		db TYPE_STR
		Str "pplate_script"
	.const9:
		db TYPE_FUNCTION
		dw PyBlock_main
	.const10:
		db TYPE_STR
		Str "main"
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
	db $de
	.name0:
		Str "gbpy"
	.name1:
		Str "load_bg_palettes"
	.name2:
		Str "load_bg_tiles"
	.name3:
		Str "load_obj_palettes"
	.name4:
		Str "load_obj_tiles"
	.name5:
		Str "load_room"
	.name6:
		Str "load_metatiles"
	.name7:
		Str "add_entity"
	.name8:
		Str "show_status"
	.name9:
		Str "player"
	.name10:
		Str "door"
	.name11:
		Str "player_movement"
	.name12:
		Str "door_script"
	.name13:
		Str "pplate_script"
	.name14:
		Str "main"
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
	db $6d, $08
	db $5a, $08
	db $01, $00
	db $64, $02
	db $61, $09
	db $64, $02
	db $61, $0a
	db $64, $03
	db $64, $04
	db $84, $00
	db $5a, $0b
	db $64, $05
	db $64, $06
	db $84, $00
	db $5a, $0c
	db $64, $07
	db $64, $08
	db $84, $00
	db $5a, $0d
	db $64, $09
	db $64, $0a
	db $84, $00
	db $5a, $0e
	db $65, $0e
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
			db TYPE_STR
			Str "update_entities"
		.tupleItem1
			db TYPE_STR
			Str "wait_vblank"
	.const3:
		db TYPE_STR
		Str "crypt.pal"
	.const4:
		db TYPE_STR
		Str "crypt.2bpp"
	.const5:
		db TYPE_STR
		Str "crypt_5_5.room"
	.const6:
		db TYPE_STR
		Str "crypt_mtiles.bin"
	.const7:
		db TYPE_STR
		Str "crypt_mattrs.bin"
	.const8:
		db TYPE_STR
		Str "orc.pal"
	.const9:
		db TYPE_STR
		Str "orc.2bpp"
	.const10:
		db TYPE_INT
		db $05
	.const11:
		db TYPE_INT
		db $06
	.const12:
		db TYPE_STR
		Str "orc_mtiles.bin"
	.const13:
		db TYPE_STR
		Str "orc_mattrs.bin"
	.const14:
		db TYPE_STR
		Str "door.pal"
	.const15:
		db TYPE_STR
		Str "door.2bpp"
	.const16:
		db TYPE_INT
		db $07
	.const17:
		db TYPE_INT
		db $08
	.const18:
		db TYPE_INT
		db $01
	.const19:
		db TYPE_STR
		Str "door_mtiles.bin"
	.const20:
		db TYPE_STR
		Str "door_mattrs.bin"
	.const21:
		db TYPE_STR
		Str "pressure_plate.pal"
	.const22:
		db TYPE_STR
		Str "pressure_plate.2bpp"
	.const23:
		db TYPE_INT
		db $0a
	.const24:
		db TYPE_INT
		db $04
	.const25:
		db TYPE_STR
		Str "pressure_plate_mtiles.bin"
	.const26:
		db TYPE_STR
		Str "pressure_plate_mattrs.bin"
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
	dw .name15
	db $f8
	.name0:
		Str "gbpy"
	.name1:
		Str "update_entities"
	.name2:
		Str "wait_vblank"
	.name3:
		Str "load_bg_palettes"
	.name4:
		Str "load_bg_tiles"
	.name5:
		Str "load_metatiles"
	.name6:
		Str "load_room"
	.name7:
		Str "load_obj_palettes"
	.name8:
		Str "load_obj_tiles"
	.name9:
		Str "add_entity"
	.name10:
		Str "player_movement"
	.name11:
		Str "player"
	.name12:
		Str "door_script"
	.name13:
		Str "door"
	.name14:
		Str "pplate_script"
	.name15:
		Str "show_status"
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
	db $74, $0f
	db $83, $00
	db $01, $00
	db $09, $00
	db $7c, $00
	db $83, $00
	db $01, $00
	db $7c, $01
	db $83, $00
	db $01, $00
	db $71, $58


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
		db $05
		dw .tupleItem0
		dw .tupleItem1
		dw .tupleItem2
		dw .tupleItem3
		dw .tupleItem4
		.tupleItem0
			db TYPE_STR
			Str "collides_with"
		.tupleItem1
			db TYPE_STR
			Str "disable_other_solid"
		.tupleItem2
			db TYPE_STR
			Str "entity_noop"
		.tupleItem3
			db TYPE_STR
			Str "look_other_down"
		.tupleItem4
			db TYPE_STR
			Str "look_down"
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	dw .name4
	dw .name5
	dw .name6
	dw .name7
	db $72
	.name0:
		Str "gbpy"
	.name1:
		Str "collides_with"
	.name2:
		Str "disable_other_solid"
	.name3:
		Str "entity_noop"
	.name4:
		Str "look_other_down"
	.name5:
		Str "look_down"
	.name6:
		Str "player"
	.name7:
		Str "door"
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
	db $6d, $04
	db $7d, $03
	db $6d, $05
	db $7d, $04
	db $01, $00
	db $09, $00
	db $09, $00
	db $7c, $00
	db $74, $06
	db $83, $01
	db $72, $20
	db $7c, $01
	db $74, $07
	db $83, $01
	db $01, $00
	db $7c, $03
	db $74, $07
	db $83, $01
	db $01, $00
	db $7c, $04
	db $83, $00
	db $01, $00
	db $6e, $04
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $10
	db $09, $00
	db $7c, $00
	db $74, $06
	db $83, $01
	db $73, $2a
	db $6e, $04
	db $7c, $02
	db $83, $00
	db $01, $00
	db $71, $25
	db $71, $0f


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
			db TYPE_STR
			Str "enable_solid"
		.tupleItem1
			db TYPE_STR
			Str "entity_noop"
.names:
	dw .name0
	dw .name1
	dw .name2
	db $28
	.name0:
		Str "gbpy"
	.name1:
		Str "enable_solid"
	.name2:
		Str "entity_noop"
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
			db TYPE_STR
			Str "enable_movement"
		.tupleItem1
			db TYPE_STR
			Str "enable_abilities"
		.tupleItem2
			db TYPE_STR
			Str "allow_1_move"
.names:
	dw .name0
	dw .name1
	dw .name2
	dw .name3
	db $40
	.name0:
		Str "gbpy"
	.name1:
		Str "enable_movement"
	.name2:
		Str "enable_abilities"
	.name3:
		Str "allow_1_move"
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
	Str "ascii.2bpp"
		dw File0
		dw File0.end-File0
	Str "door_mattrs.bin"
		dw File1
		dw File1.end-File1
	Str "door.pal"
		dw File2
		dw File2.end-File2
	Str "orc.2bpp"
		dw File3
		dw File3.end-File3
	Str "pressure_plate.2bpp"
		dw File4
		dw File4.end-File4
	Str "stars.2bpp"
		dw File5
		dw File5.end-File5
	Str "crypt_mattrs.bin"
		dw File6
		dw File6.end-File6
	Str "pressure_plate_mtiles.bin"
		dw File7
		dw File7.end-File7
	Str "stars.pal"
		dw File8
		dw File8.end-File8
	Str "orc.pal"
		dw File9
		dw File9.end-File9
	Str "power_icons.2bpp"
		dw File10
		dw File10.end-File10
	Str "crypt_4_5.room"
		dw File11
		dw File11.end-File11
	Str "crypt_5_5.room"
		dw File12
		dw File12.end-File12
	Str "pressure_plate_mattrs.bin"
		dw File13
		dw File13.end-File13
	Str "orc_mtiles.bin"
		dw File14
		dw File14.end-File14
	Str "power_icons_mtiles.bin"
		dw File15
		dw File15.end-File15
	Str "door_mtiles.bin"
		dw File16
		dw File16.end-File16
	Str "crypt.2bpp"
		dw File17
		dw File17.end-File17
	Str "crypt_mtiles.bin"
		dw File18
		dw File18.end-File18
	Str "power_icons_mattrs.bin"
		dw File19
		dw File19.end-File19
	Str "door.2bpp"
		dw File20
		dw File20.end-File20
	Str "power_icons.pal"
		dw File21
		dw File21.end-File21
	Str "pressure_plate.pal"
		dw File22
		dw File22.end-File22
	Str "crypt.pal"
		dw File23
		dw File23.end-File23
	Str "orc_mattrs.bin"
		dw File24
		dw File24.end-File24
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
	INCBIN "data/stars.2bpp"
.end:

File6:
	INCBIN "data/crypt_mattrs.bin"
.end:

File7:
	INCBIN "data/pressure_plate_mtiles.bin"
.end:

File8:
	INCBIN "data/stars.pal"
.end:

File9:
	INCBIN "data/orc.pal"
.end:

File10:
	INCBIN "data/power_icons.2bpp"
.end:

File11:
	INCBIN "data/crypt_4_5.room"
.end:

File12:
	INCBIN "data/crypt_5_5.room"
.end:

File13:
	INCBIN "data/pressure_plate_mattrs.bin"
.end:

File14:
	INCBIN "data/orc_mtiles.bin"
.end:

File15:
	INCBIN "data/power_icons_mtiles.bin"
.end:

File16:
	INCBIN "data/door_mtiles.bin"
.end:

File17:
	INCBIN "data/crypt.2bpp"
.end:

File18:
	INCBIN "data/crypt_mtiles.bin"
.end:

File19:
	INCBIN "data/power_icons_mattrs.bin"
.end:

File20:
	INCBIN "data/door.2bpp"
.end:

File21:
	INCBIN "data/power_icons.pal"
.end:

File22:
	INCBIN "data/pressure_plate.pal"
.end:

File23:
	INCBIN "data/crypt.pal"
.end:

File24:
	INCBIN "data/orc_mattrs.bin"
.end:
