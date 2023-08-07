import png
import sys

# Usage: `metatilesExtract.py crypt` for `images/crypt.map`
name = sys.argv[1]
r = png.Reader(filename=f"images/{name}.png")
width, height = r.read()[:2]
assert width % 16 == 0
assert height % 16 == 0
numMCols = width // 16
numMRows = height // 16


# Load superfamiconv output
with open(f"images/{name}.map", "rb") as f:
    sfcData = f.read()

# Data is interwoven tile idxes + tile attrs
# Additionally, it loops every 8px row, not every 16px row

# Output TL, TR, BL, BR
tileOutput = []
attrOutput = []
for mRowIdx in range(numMRows):
    for mColIdx in range(numMCols):
        # 2 bytes per tile, 2 bytes each metatile dimension
        mByteIdx = (mRowIdx*numMCols*2*2 + mColIdx*2) * 2
        tileOutput.append(sfcData[mByteIdx])
        attrOutput.append(sfcData[mByteIdx+1])
        tileOutput.append(sfcData[mByteIdx+2])
        attrOutput.append(sfcData[mByteIdx+3])
        mByteIdx += numMCols*2 * 2
        tileOutput.append(sfcData[mByteIdx])
        attrOutput.append(sfcData[mByteIdx+1])
        tileOutput.append(sfcData[mByteIdx+2])
        attrOutput.append(sfcData[mByteIdx+3])

with open(f"data/{name}_mtiles.bin", "wb") as f:
    f.write(bytearray(tileOutput))

with open(f"data/{name}_mattrs.bin", "wb") as f:
    f.write(bytearray(attrOutput))
