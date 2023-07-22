import json
import sys

# eg crypt_5_5
tiledMapFname = sys.argv[1]


# Load Tiled output
with open(f"tiled/{tiledMapFname}.json") as f:
    tiledData = json.loads(f.read())

metatiles = [mIdx-1 for mIdx in tiledData["layers"][0]["data"]]

with open(f"data/{tiledMapFname}.room", "wb") as f:
    f.write(bytearray(metatiles))
