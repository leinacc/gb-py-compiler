import os
import sys

full_fname = sys.argv[1]
fname = full_fname.split('/')[1].split('.')[0]
with open(full_fname) as f:
    compiled = compile(f.read(), fname, "exec")


names = set()

outputs = []


def get_none_output(indents=0):
    return '\t'*indents + 'db TYPE_NONE\n'


def get_int_output(num, indents=0):
    indent = '\t' * indents
    output = indent + 'db TYPE_INT\n'
    output += indent + f'db ${num:02x}\n'
    return output


def get_str_output(text, indents=0):
    text = text.replace('\n', '\\n')
    indent = '\t' * indents
    output = indent + 'db TYPE_STR\n'
    output += indent + f'Str "{text}"\n'
    return output


def get_tuple_output(tup, indents=0):
    indent = '\t' * indents
    output = indent + 'db TYPE_TUPLE\n'
    output += indent + f'db ${len(tup):02x}\n'
    for i in range(len(tup)):
        output += indent + f'dw .tupleItem{i}\n'
    for i, el in enumerate(tup):
        output += indent + f'.tupleItem{i}:\n'
        if isinstance(el, str):
            output += get_str_output(el, indents+1)
            names.add(el)
        else:
            raise Exception("text")
    return output


def get_block_output(block, indents=0):
    clean_name = block.co_name.replace("<", "_").replace(">", "_")
    indent = '\t' * indents
    output = f"""PyBlock_{fname}_{clean_name}:
{indent}\tdw .consts
{indent}\tdw .names
{indent}\tdw .bytecode
{indent}\t.consts:
"""

    # 1. co_consts
    for i in range(len(block.co_consts)):
        output += f"{indent}\t\tdw .const{i}\n"
    for i, el in enumerate(block.co_consts):
        output += f"{indent}\t.const{i}:\n"
        if el is None:
            output += get_none_output(indents+2)
        elif isinstance(el, int):
            output += get_int_output(el, indents+2)
        elif isinstance(el, tuple):
            output += get_tuple_output(el, indents+2)
        elif isinstance(el, str):
            output += get_str_output(el, indents+2)
            names.add(el)
        elif type(el).__name__ == 'code':
            output += f"{indent}\t\tdb TYPE_FUNCTION\n"
            clean_name = el.co_name.replace("<", "_").replace(">", "_")
            output += f"{indent}\t\tdw PyBlock_{fname}_{clean_name}\n"
            outputs.insert(0, get_block_output(el))
        else:
            print(type(el), el)
            raise Exception("test")
        
    # 2: co_names
    output += f"{indent}.names:\n"
    for i in range(len(block.co_names)):
        output += f"{indent}\tdw .name{i}\n"
    heap_name_len = 1  # terminator
    for i, el in enumerate(block.co_names):
        heap_name_len += 1 + len(el) + 1 + 2
    output += f"{indent}\tdw ${heap_name_len:02x}\n"
    for i, el in enumerate(block.co_names):
        output += f"{indent}\t.name{i}:\n"
        output += f"{indent}\t\tStr \"{el}\"\n"

    # 3: co_varnames (mangled)

    # 4: bytecode
    output += f"{indent}.bytecode:\n"
    c = block.co_code
    for i in range(len(c)//2):
        output += f"{indent}\tdb ${c[i*2]:02x}, ${c[i*2+1]:02x}\n"

    return output


outputs.insert(0, get_block_output(compiled))


outputs.append('/*\n' + '\n'.join(sorted(names)) + '\n*/')


with open(f"pycompiled/{fname}.asm", "w") as f:
    f.write('\n\n'.join(outputs))
