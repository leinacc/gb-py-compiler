from gbpy import load_palettes, load_tiles, load_room, load_metatiles


def main():
    load_palettes("crypt.pal")
    load_tiles("crypt.tiles")
    load_room("room1.bin")
    load_metatiles("crypt_mtiles.bin", "crypt_mattrs.bin")

main()
