import os
import sys

fname = sys.argv[1]
with open(fname) as f:
    compiled = compile(f.read(), fname, "exec")


outputs = []


def get_block_output(block):
    clean_name = block.co_name.replace("<", "_").replace(">", "_")
    output = f"""PyBlock_{clean_name}:
\tdw .consts
\tdw .names
\tdw .bytecode
\t.consts:
"""

    # 1. co_consts
    for i in range(len(block.co_consts)):
        output += f"\t\tdw .const{i}\n"
    for i, el in enumerate(block.co_consts):
        output += f"\t.const{i}:\n"
        if el is None:
            output += "\t\tdb TYPE_NONE\n"
        elif isinstance(el, int):
            output += "\t\tdb TYPE_INT\n"
            output += f"\t\tdb ${el:02x}\n"
        elif isinstance(el, tuple):
            output += "\t\tdb TYPE_TUPLE\n"
            output += f"\t\tdb ${len(el):02x}\n"
            for j in range(len(el)):
                output += f"\t\tdw .tupleItem{j}\n"
            for j, ell in enumerate(el):
                output += f"\t\t.tupleItem{j}\n"
                if isinstance(ell, str):
                    str_len = len(ell) + 1
                    val = ell.replace('\n', '\\n')
                    output += f"\t\t\tdb TYPE_STR\n"
                    output += f"\t\t\tStr \"{val}\"\n"
                else:
                    raise Exception("test")
        elif isinstance(el, str):
            str_len = len(el) + 1
            val = el.replace('\n', '\\n')
            output += f"\t\tdb TYPE_STR\n"
            output += f"\t\tStr \"{val}\"\n"
        elif type(el).__name__ == 'code':
            output += f"\t\tdb TYPE_FUNCTION\n"
            clean_name = el.co_name.replace("<", "_").replace(">", "_")
            output += f"\t\tdw PyBlock_{clean_name}\n"
            outputs.insert(0, get_block_output(el))
        else:
            print(type(el), el)
            raise Exception("test")
        
    # 2: co_names
    output += ".names:\n"
    for i in range(len(block.co_names)):
        output += f"\tdw .name{i}\n"
    heap_name_len = 1  # terminator
    for i, el in enumerate(block.co_names):
        heap_name_len += 1 + len(el) + 1 + 2
    output += f"\tdb ${heap_name_len:02x}\n"
    for i, el in enumerate(block.co_names):
        str_len = len(el) + 1
        output += f"\t.name{i}:\n"
        output += f"\t\tStr \"{el}\"\n"

    # 3: co_varnames (mangled)

    # 4: bytecode
    output += ".bytecode:\n"
    c = block.co_code
    for i in range(len(c)//2):
        output += f"\tdb ${c[i*2]:02x}, ${c[i*2+1]:02x}\n"

    return output


outputs.insert(0, get_block_output(compiled))

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

outputs.append(output)

with open("pycompiled/test.asm", "w") as f:
    f.write('\n\n'.join(outputs))
