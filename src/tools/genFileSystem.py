import os
from gperf import process_words


fnames = [
    fname for fname in os.listdir("data") if not fname.endswith(".room") and fname != ".gitkeep"
]
fnames += [
    fname.replace(".json", ".room") for fname in os.listdir("tiled") if fname.endswith(".json")
]

asso_values, hash_algo, wordlist = process_words(fnames, "FileSystem")

output = f"""INCLUDE "defines.asm"

SECTION "File System", ROM0

{asso_values}

{hash_algo}

FileSystem::
"""

for i, fname in enumerate(wordlist):
    if not fname:
        output += "    BankAddr Debug\n"
    else:
        output += f"    BankAddr File{i}\n"

# for i, fname in enumerate(fnames):
#     output += f"\tStr \"{fname}\"\n"
#     output += f"\t\tdb BANK(File{i})\n"
#     output += f"\t\tdw File{i}\n"
# output += "\tdb $ff\n\n"

output += '\n\nSECTION "Files", ROMX, BANK[$06]\n'

for i, fname in enumerate(wordlist):
    if not fname:
        continue
    output += f"\nFile{i}:\n"
    output += f"\tdw .end-.start\n"
    output += ".start:\n"
    output += f"\tINCBIN \"data/{fname}\"\n"
    output += ".end:\n"

# for i, fname in enumerate(fnames):
#     output += f"\nFile{i}:\n"
#     output += f"\tdw .end-.start\n"
#     output += ".start:\n"
#     output += f"\tINCBIN \"data/{fname}\"\n"
#     output += ".end:\n"

with open("src/file_system.asm", "w") as f:
    f.write(output)
