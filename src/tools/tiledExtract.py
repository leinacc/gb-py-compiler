import json
import sys

tiledMapFname = sys.argv[1]
superfamiconvMapFname = sys.argv[2]


# Load Tiled output
with open(tiledMapFname) as f:
    tiledData = json.loads(f.read())

metatiles = [mIdx-1 for mIdx in tiledData["layers"][0]["data"]]

with open("data/room1.bin", "wb") as f:
    f.write(bytearray(metatiles))


# Load superfamiconv output
with open(superfamiconvMapFname, "rb") as f:
    sfcData = f.read()

# Data is interwoven tile idxes + tile attrs
# Additionally, it loops every 8px row, not every 16px row
numMCols = 3
numMRows = 7

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

with open("data/crypt_mattrs.bin", "wb") as f:
    f.write(bytearray(tileOutput))

with open("data/crypt_mtiles.bin", "wb") as f:
    f.write(bytearray(attrOutput))
