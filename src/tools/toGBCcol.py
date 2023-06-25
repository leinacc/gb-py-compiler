import sys

hexcode = sys.argv[1]
hexcode = int(hexcode, 16)
b = hexcode & 0xff
hexcode >>= 8
g = hexcode & 0xff
hexcode >>= 8
r = hexcode & 0xff
r //= 8
g //= 8
b //= 8
full = (b<<10)|(g<<5)|r
print(f'{full:04x}')
