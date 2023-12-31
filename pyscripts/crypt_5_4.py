from gbpy import load_bg_palettes, load_bg_tiles, load_obj_palettes, \
    load_obj_tiles, load_room, load_metatiles, show_status, add_player_entity, \
    enable_movement, enable_abilities, allow_1_move, update_entities, wait_vblank

def player_movement():
    enable_movement()
    enable_abilities()
    while 1:
        allow_1_move()


def main():
    cryptPals = load_bg_palettes("crypt.pal")
    cryptTiles = load_bg_tiles("crypt.2bpp")
    load_metatiles("crypt_5_4.room")
    load_room("crypt_mtiles.bin", "crypt_mattrs.bin", cryptTiles, cryptPals)

    orcPals = load_obj_palettes("orc.pal")
    orcTiles = load_obj_tiles("orc.2bpp")
    player = add_player_entity(
        player_movement, 0,
        orcPals, orcTiles,
        "orc_mtiles.bin", "orc_mattrs.bin",
    )

    show_status()

    while 1:
        update_entities()
        wait_vblank()

main()
