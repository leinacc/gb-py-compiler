from gbpy import load_palettes, load_tiles, load_room, load_metatiles#, add_entity, move_left, update_entities


# def cutscene_movement():
#     move_left(1)


def main():
    palsPtr = load_palettes("crypt.pal")
    tilesPtr = load_tiles("crypt.tiles")
    load_metatiles("room1.bin")
    load_room("crypt_mtiles.bin", "crypt_mattrs.bin", tilesPtr, palsPtr)

    # player = add_entity(5, 4, cutscene_movement)

    # while 1:
    #     update_entities()


main()
