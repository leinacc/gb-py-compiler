from gbpy import load_bg_palettes, load_bg_tiles, load_obj_palettes, \
    load_obj_tiles, load_room, load_metatiles, show_status, add_player_entity, \
    add_entity

player = None
door = None

def player_movement():
    from gbpy import enable_movement, enable_abilities, allow_1_move
    enable_movement()
    enable_abilities()
    while 1:
        allow_1_move()


def door_script():
    from gbpy import enable_solid, entity_noop
    enable_solid()
    while 1:
        entity_noop()


def pplate_script():
    from gbpy import collides_with, disable_other_solid, entity_noop, \
        look_other_down, look_down
    while 1:
        while 1:
            if collides_with(player):
                disable_other_solid(door)
                look_other_down(door)
                look_down()
                break
            entity_noop()
        while 1:
            if not collides_with(player):
                break
            entity_noop()


def main():
    from gbpy import update_entities, wait_vblank
    global door, player

    cryptPals = load_bg_palettes("crypt.pal")
    cryptTiles = load_bg_tiles("crypt.2bpp")
    load_metatiles("crypt_5_5.room")
    load_room("crypt_mtiles.bin", "crypt_mattrs.bin", cryptTiles, cryptPals)

    orcPals = load_obj_palettes("orc.pal")
    orcTiles = load_obj_tiles("orc.2bpp")
    # script, anim def idx, pal ptr, tiles ptr, metatile tiles/attrs
    player = add_player_entity(
        player_movement, 0,
        orcPals, orcTiles,
        "orc_mtiles.bin", "orc_mattrs.bin",
    )

    # script, anim def idx, pal ptr, tiles ptr, metatile tiles/attrs, tile x, tile y
    doorPals = load_obj_palettes("door.pal")
    doorTiles = load_obj_tiles("door.2bpp")
    door = add_entity(
        door_script, 1,
        doorPals, doorTiles,
        "door_mtiles.bin", "door_mattrs.bin",
        7, 8,
    )

    pressurePlatePals = load_obj_palettes("pressure_plate.pal")
    pressurePlateTiles = load_obj_tiles("pressure_plate.2bpp")
    add_entity(
        pplate_script, 1,
        pressurePlatePals, pressurePlateTiles, 
        "pressure_plate_mtiles.bin", "pressure_plate_mattrs.bin",
        10, 4
    )

    show_status()

    while 1:
        update_entities()
        wait_vblank()

main()
