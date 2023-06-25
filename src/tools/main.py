from gbpy import load_bg_palettes, load_bg_tiles, load_obj_palettes, \
    load_obj_tiles, load_room, load_metatiles, add_entity


def cutscene_movement():
    # from gbpy import move_left, move_right, move_up, move_down
    from gbpy import enable_movement, entity_noop
    enable_movement()
    while 1:
        entity_noop()
        # move_left(1)
        # move_up(4)
        # move_right(1)
        # move_down(4)


def main():
    from gbpy import update_entities, wait_vblank, load_vwf#, camera_follow

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
    # camera_follow(player)

    load_vwf("My \t1r\t2a\t3i\t4n\t5b\t6o\t7w\t0 VWF")

    while 1:
        update_entities()
        wait_vblank()

main()
