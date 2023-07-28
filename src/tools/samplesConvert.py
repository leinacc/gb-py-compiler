"""
https://cloudconvert.com/mp3-to-wav
Audio codec - pcm_s16le
Channels - mono
Sample rate - 16KHz
"""

import sys
fname = sys.argv[1]
base_name = fname[:-4]
with open(fname, 'rb') as f:
    data = f.read()

# header = data[:0x24]
if data[0x24] == 0x4c:  # 'L'
    size = data[0x28]|(data[0x29]<<8)|(data[0x2a]<<16)|(data[0x2b]<<24)
    idx = 0x2c + size
else:
    idx = 0x24
data_chunk = data[idx+4:]

assert len(data_chunk)%2 == 0
output = []
min_word = 0
max_word = 0
for i in range(len(data_chunk)//2):
    word = data_chunk[i*2]|(data_chunk[i*2+1]<<8)
    if word >= 0x8000:
        word = -1 * (0x10000-word)

    if word < min_word:
        min_word = word
    if word > max_word:
        max_word = word

chunk_size = (max_word-min_word)//8

for i in range(len(data_chunk)//2):
    word = data_chunk[i*2]|(data_chunk[i*2+1]<<8)
    if word >= 0x8000:
        word = -1 * (0x10000-word)

    if word < min_word+chunk_size:
        output.append(0x00)
    elif word < min_word+chunk_size*2:
        output.append(0x11)
    elif word < min_word+chunk_size*3:
        output.append(0x22)
    elif word < min_word+chunk_size*4:
        output.append(0x33)
    elif word < min_word+chunk_size*5:
        output.append(0x44)
    elif word < min_word+chunk_size*6:
        output.append(0x55)
    elif word < min_word+chunk_size*7:
        output.append(0x66)
    else:
        output.append(0x77)

print(hex(min_word), hex(max_word))

with open(f"{base_name}.bin", 'wb') as f:
    f.write(bytearray(output))
