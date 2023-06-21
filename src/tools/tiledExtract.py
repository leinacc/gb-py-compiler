import json
import sys

tiledMapFname = sys.argv[1]


# Load Tiled output
with open(tiledMapFname) as f:
    tiledData = json.loads(f.read())

metatiles = [mIdx-1 for mIdx in tiledData["layers"][0]["data"]]

with open("data/room1.bin", "wb") as f:
    f.write(bytearray(metatiles))
