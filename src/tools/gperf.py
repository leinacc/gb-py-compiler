import subprocess
from typing import List


def get_asso_values(gperf_output: str, prefix: str):
    asso_vals_i = gperf_output.index("asso_values[]")
    asso_vals_open_i = gperf_output.index('{', asso_vals_i)
    asso_vals_close_i = gperf_output.index('}', asso_vals_open_i)

    asso_vals = [
        int(value.strip()) for value in
        gperf_output[asso_vals_open_i+1:asso_vals_close_i].split(',')
    ]
    return f"""{prefix}AssoValues:
    db """ + ", ".join(f'${b:02x}' for b in asso_vals) + '\n'


def get_hash_algo(gperf_output: str, prefix: str):
    """
    Map the highest non-applicable hval length to the string index that's
    used as an asso_values lookup, for numbers higher than it

    Example 1: the following makes (5, 6, 0)
      hval += asso_values[(unsigned char)str[6]];
    case 5:
    
    Example 2: the following makes (0, 0, 0)
      hval += asso_values[(unsigned char)str[0]];
      break;

    Example 3: the following makes (8, 8, 1)
      hval += asso_values[(unsigned char)str[8]+1];
    case 8:
    """ 
    asso_thresholds = []
    asso_threshold_open_i = gperf_output.index('str[')
    asso_threshold_close_i = gperf_output.index(']', asso_threshold_open_i)
    asso_threshold = int(gperf_output[asso_threshold_open_i+4:asso_threshold_close_i])
    asso_threshold_add = 0
    if gperf_output[asso_threshold_close_i+1] == '+':
        asso_threshold_add_close_i = gperf_output.index(']', asso_threshold_close_i+1)
        asso_threshold_add = int(gperf_output[asso_threshold_close_i+2:asso_threshold_add_close_i])

    if asso_threshold == 0:
        # todo: does it always omit the hval_len
        # todo: does it always use str[0]
        return f"""; HL - points to a Str macro
; Returns A = the hashed value
{prefix}Hash:
    inc hl
    ld a, [hl]
    ld hl, {prefix}AssoValues
    add l
    ld l, a
    jr nc, :+
    inc h
:   ld a, [hl]
    ret
"""

    """
    Given [16]case16, [8]case8, [0], I want
        cp 8+1
        jr c, .idx0

        cp 16+1
        jr c, .idx8

        ld e, 16
        call AddAssoVal

    .idx8:
        ld e, 8
        call AddAssoVal

    .idx0:
        ld e, 0
        call AddAssoVal

    ;.ret

    Given [6]6, I want
        cp 6+1
        jr c, .ret

        ld e, 6
        call AddAssoVal

    .ret

    ie
    * if 0 is the last entry, there is no ret (remove it after)
    * for each entry backward, do
        cp {entry}+1
        jr c, .idx{next}
        or replace .idx{next} with .ret for the last entry
    * for each entry forward, do
        ld e, 16
        call AddAssoVal

        .idx{next}:
        or replace .idx{next} with .ret for the last entry
    """
    while True:
        try:
            case_open_i = gperf_output.index('case ', asso_threshold_close_i)
        except ValueError:
            asso_thresholds.append( (0, asso_threshold, asso_threshold_add) )
            break
        case_close_i = gperf_output.index(':', case_open_i)
        asso_thresholds.append( (
            int(gperf_output[case_open_i+5:case_close_i]),
            asso_threshold,
            asso_threshold_add,
        ) )

        # Get next threshold
        try:
            asso_threshold_open_i = gperf_output.index('str[', case_close_i)    
        except ValueError:
            break

        asso_threshold_close_i = gperf_output.index(']', asso_threshold_open_i)
        asso_threshold = int(gperf_output[asso_threshold_open_i+4:asso_threshold_close_i])
        asso_threshold_add = 0
        if gperf_output[asso_threshold_close_i+1] == '+':
            asso_threshold_add_close_i = gperf_output.index(']', asso_threshold_close_i+1)
            asso_threshold_add = int(gperf_output[asso_threshold_close_i+2:asso_threshold_add_close_i])

    # Now generate the hash algo
    hash_algo = f"""; A - index into {prefix}AssoValues
; B - current hval sum
{prefix}AddAssoVal:
; Add the asso value to the sum
    ld hl, {prefix}AssoValues
    add l
    ld l, a
    jr nc, :+
    inc h
:   ld a, b
    add [hl]
    ld b, a
    ret

    
; HL - points to a Str macro
; Returns A = the hashed value
{prefix}Hash::
; B = asso val
    ld a, [hl+]
    sub 1
    ld b, a
    ld d, 0

"""
    zero_last = asso_thresholds[-1][0] == 0
    zero_add = 0
    if zero_last:
        entry = asso_thresholds.pop()
        zero_thresh = entry[1]
        zero_add = entry[2]

    for i in range(len(asso_thresholds)-1, -1, -1):
        cp_val, _, _ = asso_thresholds[i]
        hash_algo += f'    cp {cp_val}+1\n'
        if i == len(asso_thresholds)-1:
            if zero_last:
                hash_algo += f'    jr c, .idx0'
            else:
                hash_algo += f'    jr c, .ret'
        else:
            _, next_idx, _ = asso_thresholds[i+1]
            hash_algo += f'    jr c, .idx{next_idx}'
        hash_algo += '\n\n'

    for i in range(0, len(asso_thresholds)):
        _, curr_idx, add_val = asso_thresholds[i]
        hash_algo += get_asso_call_output(prefix, curr_idx, add_val)
        if i == len(asso_thresholds)-1:
            if zero_last:
                hash_algo += '.idx0:\n'
                hash_algo += get_asso_call_output(prefix, zero_thresh, zero_add)
            else:
                hash_algo += '.ret:\n'
        else:
            _, next_idx, _ = asso_thresholds[i+1]
            hash_algo += f'.idx{next_idx}:\n'

    hash_algo += '    ld a, b\n'
    hash_algo += '    ret\n'
    return hash_algo


def get_asso_call_output(prefix, idx, add_val):
    output = f"""    ld e, {idx}
    push hl
    add hl, de
    ld a, [hl]
"""
    if add_val:
        output += f'    add {add_val}\n'
    output += f"""    call {prefix}AddAssoVal
    pop hl

"""

    return output


def get_word_list(gperf_output: str):
    word_list_i = gperf_output.index('wordlist[]')
    word_list_open_i = gperf_output.index('{', word_list_i)
    word_list_close_i = gperf_output.index('}', word_list_open_i)
    word_list = gperf_output[word_list_open_i+1:word_list_close_i].split(',')

    clean_word_list = []
    for word_entry in word_list:
        open_i = word_entry.index('"')
        close_i = word_entry.index('"', open_i+1)
        clean_word_list.append(word_entry[open_i+1:close_i])
    return clean_word_list


def process_words(words: List[str], prefix: str):
    """
    Return asso_values, the hash algo, and the wordlist
    """
    gperf_output: str = subprocess.run(
        "gperf", 
        input='\n'.join(sorted(words)).encode("utf-8"), 
        capture_output=True,
    ).stdout.decode("utf-8")
    # print(gperf_output)

    return (
        get_asso_values(gperf_output, prefix),
        get_hash_algo(gperf_output, prefix),
        get_word_list(gperf_output),
    )
