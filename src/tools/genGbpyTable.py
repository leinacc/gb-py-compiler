import gb
from gperf import process_words


gbpy_words = [
    word for word in dir(gb)
    if not word.startswith('__')
]

asso_values, hash_algo, wordlist = process_words(gbpy_words, "GbpyRoutines")

output = f"""SECTION "Gbpy module table", ROM0

{asso_values}

{hash_algo}

GbpyModule::
    db TYPE_GBPY_MODULE
"""

for routine in wordlist:
    if not routine:
        output += '    dw AsmStub\n'
    else:
        doc = getattr(gb, routine).__doc__
        output += f"""
    /*{doc}*/
    dw Asm_{routine}
"""

with open("src/include/gbpy_table.asm", "w") as f:
    f.write(output)
