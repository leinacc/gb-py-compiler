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
	db $3e
	.name0:
		db $05, "gbpy", $ff
	.name1:
		db $0b, "load_tiles", $ff
	.name2:
		db $0d, "print_string", $ff
	.name3:
		db $0c, "wait_vblank", $ff
	.name4:
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
	db $01, $00
	db $64, $02
	db $64, $03
	db $84, $00
	db $5a, $04
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
	.const0:
		db TYPE_NONE
	.const1:
		db TYPE_STR, $0b
		db "ascii.2bpp", $ff
	.const2:
		db TYPE_INT
		db $17
	.const3:
		db TYPE_STR, $11
		db "Hello,\nGBCompo '", $ff
	.const4:
		db TYPE_STR, $02
		db "!", $ff
.names:
	dw .name0
	dw .name1
	dw .name2
	db $2e
	.name0:
		db $0b, "load_tiles", $ff
	.name1:
		db $0d, "print_string", $ff
	.name2:
		db $0c, "wait_vblank", $ff
.bytecode:
	db $74, $00
	db $64, $01
	db $83, $01
	db $7d, $00
	db $64, $02
	db $7d, $01
	db $74, $01
	db $64, $03
	db $7c, $01
	db $9b, $00
	db $64, $04
	db $9d, $03
	db $7c, $00
	db $83, $02
	db $01, $00
	db $09, $00
	db $74, $02
	db $83, $00
	db $01, $00
	db $71, $10


FileSystem::
	db $0b, "ascii.2bpp", $ff
		dw File0
		dw File0.end-File0
    db $ff

File0:
	INCBIN "data/ascii.2bpp"
.end:
