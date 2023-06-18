from gbpy import load_tiles, print_string, wait_vblank


def add(num1, num2):
    return num1 + num2


def main():
    tilesPtr = load_tiles("ascii.2bpp")
    print_string(f"Hello,\nGBCompo '{add(1, 1)}{add(1, 2)}!", tilesPtr)
    while 1:
        wait_vblank()

main()
