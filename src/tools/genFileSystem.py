import os
from gperf import process_words


fnames = [
    fname for fname in os.listdir("data") if not fname.endswith(".room") and fname != ".gitkeep"
]
fnames += [
    fname.replace(".json", ".room") for fname in os.listdir("tiled") if fname.endswith(".json")
]

asso_values, hash_algo, wordlist = process_words(fnames, "FileSystem")

output = f"""SECTION "File System", ROM0

{asso_values}

{hash_algo}

FileSystem::
"""

for i, fname in enumerate(wordlist):
    if not fname:
        output += "    BankAddr Debug\n"
    else:
        output += f"    BankAddr File{i}\n"


output += '\n\nSECTION "Files", ROMX, BANK[$06]\n'

for i, fname in enumerate(wordlist):
    if not fname:
        continue
    output += f"\nFile{i}:\n"
    output += f"\tdw .end-.start\n"
    output += ".start:\n"
    output += f"\tINCBIN \"data/{fname}\"\n"
    output += ".end:\n"


with open("src/include/file_system.asm", "w") as f:
    f.write(output)
