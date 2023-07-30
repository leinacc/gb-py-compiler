import os


# File system
output =  "FileSystem::\n"
fnames = os.listdir("data")
for i, fname in enumerate(fnames):
    str_len = len(fname) + 1
    output += f"\tStr \"{fname}\"\n"
    output += f"\t\tdw File{i}\n"
    output += f"\t\tdw File{i}.end-File{i}\n"
output += "\tdb $ff\n"

for i, fname in enumerate(fnames):
    output += f"\nFile{i}:\n"
    output += f"\tINCBIN \"data/{fname}\"\n"
    output += ".end:\n"

with open("pycompiled/file_system.asm", "w") as f:
    f.write(output)
