import json
import sys

full_fname = sys.argv[1]

# eg crypt_5_5
fname = full_fname.split('/')[1].split('.')[0]


# Load Tiled output
with open(full_fname) as f:
    tiledData = json.loads(f.read())

metatiles = [mIdx-1 for mIdx in tiledData["layers"][0]["data"]]

with open(f"data/{fname}.room", "wb") as f:
    f.write(bytearray(metatiles))
