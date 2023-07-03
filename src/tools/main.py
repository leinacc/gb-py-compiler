from gbpy import load_bg_palettes, load_bg_tiles, load_obj_palettes, \
    load_obj_tiles, load_room, load_metatiles, add_entity


def cutscene_movement():
    from gbpy import enable_movement, entity_noop
    enable_movement()
    while 1:
        entity_noop()


def main():
    from gbpy import update_entities, wait_vblank

    cryptPals = load_bg_palettes("crypt.pal")
    cryptTiles = load_bg_tiles("crypt.2bpp")
    load_metatiles("room1.bin")
    load_room("crypt_mtiles.bin", "crypt_mattrs.bin", cryptTiles, cryptPals)

    orcPals = load_obj_palettes("orc.pal")
    orcTiles = load_obj_tiles("orc.2bpp")
    # tile x, tile y, script, anim def idx, pal ptr, tiles ptr, metatile tiles/attrs
    # todo: player = entity id
    player = add_entity(
        5, 6, cutscene_movement, 0, orcPals, orcTiles, "orc_mtiles.bin", "orc_mattrs.bin",
    )

    while 1:
        update_entities()
        wait_vblank()

main()
