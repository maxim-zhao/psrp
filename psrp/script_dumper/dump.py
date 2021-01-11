import sys
import json
import re

def text_at(f, p, dictionary):
    f.seek(p)
    line = ''
    while 1:
        # get byte
        c = f.read(1)
        i = ord(c)
        if i >= 0x80:
            word = dictionary[i - 0x80]
            line += word
        else:
            c = c.decode(encoding='ascii')
            line += c
            if i in (0x62, 0x63, 0x65):
                break;
    return line
    
def parse_text(s):
    d = {
        chr(0x5b): "<player>",
        chr(0x5c): "<monster>",
        chr(0x5d): "<item>",
        chr(0x5e): "<number>",
        chr(0x60): "<line>\n",
        chr(0x61): "<wait more>\n",
        chr(0x62): "<prompt>",
        chr(0x63): "<wait>",
        chr(0x64): "<delay>\n",
        chr(0x65): "<end>",
        '@': "'",
        ';': ":"
    }
    # forwards-only replace
    regex = re.compile("|".join(map(re.escape, d.keys())))
    # replace tokens and fix punctuation
    s = regex.sub(lambda mo: d[mo.group(0)], s)
    # wrap lines
    s = re.sub("^([^<]{18})([^<])", "\\1\n\\2", s, flags = re.MULTILINE)
    # convert to YAML
    if "\n" in s:
        return "  us: |\n    " + "\n    ".join(s.splitlines())
    else:
        return "  us: " + s
    
def read_dictionary(f):
    # dictionary
    dictionary = {}
    
    for index in range(128):
        # get pointer
        f.seek(0xba81 + index * 2)
        p = int.from_bytes(f.read(2), byteorder='little')
        # follow it
        f.seek(p)
        # read word
        word = ''
        while 1:
            c = f.read(1)
            if c == b'\x65':
                break;
            word += c.decode(encoding='ascii')
        dictionary[index] = word
        
    return dictionary

def dump(rom, offset, size, base):
    with open(rom, mode='rb') as f:
        dictionary = read_dictionary(f)
        
        # script
        for index in range(0, size, 2):
            print(f"[{hex(index+2).replace('x','0')[-3:]}]")
            f.seek(offset + index)
            p = int.from_bytes(f.read(2), byteorder='little')
            # follow it
            if p >= 0x8000:
                p = p - 0x8000 + base
                # print(f"Pointer {hex(p)}")
            line = parse_text(text_at(f, p, dictionary))
            print(line)
            
            
def dump_raw(rom, start, end):
    with open(rom, mode='rb') as f:
        dictionary = read_dictionary(f)
        
        # script
        f.seek(start)
        for index in range(0, 10000, 2):
            print(f"[{hex(index).replace('x','0')[-3:]}]")
            line = parse_text(text_at(f, f.tell(), dictionary))
            print(line)
            if f.tell() >= end:
                break;

def main():
    verb = sys.argv[1]
    if verb == 'dump':
        # Pointed script
        # dump(sys.argv[2], 0x8000, 0x2aa, 0x8000)
        # Dialogue
        # dump_raw(sys.argv[2], 0x33108, 0x33fdc)
        # Full script block
        dump_raw(sys.argv[2], 0x82aa, 0xbf49)
  
if __name__ == "__main__":
    main()