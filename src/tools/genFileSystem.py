import os


# File system
output = """INCLUDE "defines.asm"

SECTION "File System", ROM0

FileSystem::
"""
fnames = [
    fname for fname in os.listdir("data") if not fname.endswith(".room")
]
fnames += [
    fname.replace(".json", ".room") for fname in os.listdir("tiled") if fname.endswith(".json")
]
for i, fname in enumerate(fnames):
    output += f"\tStr \"{fname}\"\n"
    output += f"\t\tdb BANK(File{i})\n"
    output += f"\t\tdw File{i}\n"
output += "\tdb $ff\n\n"

output += 'SECTION "Files", ROMX, BANK[$06]\n'

for i, fname in enumerate(fnames):
    output += f"\nFile{i}:\n"
    output += f"\tdw .end-.start\n"
    output += ".start:\n"
    output += f"\tINCBIN \"data/{fname}\"\n"
    output += ".end:\n"

with open("src/file_system.asm", "w") as f:
    f.write(output)
