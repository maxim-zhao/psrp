import sys
import re
import yaml


start_code = 0x6c  # see WordListStart in asm


def generate_words(tbl_file, asm_file, script_file, language, word_count):
    with open(script_file, "r", encoding="utf-8") as f:
        script = yaml.load(f, Loader=yaml.BaseLoader)  # BaseLoader keeps everything as strings

    # dict of word to count
    words = {}
    for entry in script:
        # Check for a missing language
        if language not in entry:
            if "offsets" in entry:
                offsets = entry["offsets"]
                if len(offsets) > 0 and not offsets.isspace():
                    print(f"Warning: entry has no text for offsets {offsets}")
            continue
        # replace tags with space
        line = entry[language]
        line = re.sub(r"<[^>]*>", " ", line)
        # replace ' with ’
        line = line.replace("'", "’")
        # split to words defined as sequences of letters with an optional ’ at the start
        line_words = re.findall(r"’?[\w]+", line)
        # add to dictionary
        for word in line_words:
            if word in words:
                words[word] += 1
            else:
                words[word] = 1

    print(f"Script has {len(words)} unique words")

    # Then convert to weighted counts
    # The benefit of substituting a word is a bit complicated.
    # The substituted text storage is in a separate bank to the main script so moving low-frequency long words there can
    # be worthwhile. The space taken by a word is very much dependent on the letter frequency that we later Huffman
    # compress, so common letter sequences are cheaper than unusual ones; the Huffman trees are also stored outside the
    # script bank. Thus we can maximize the script space by selecting the words which are used the most, and are long
    # when Huffman encoded. As we don't know the Huffman length, we use the word length as a proxy.
    # Some tweaking of the weight function seems to find this gives the smallest size for the script block, which is the
    # most space-pressured.
    weighted_list = []
    for word, count in words.items():
        if len(word) == 1:
            continue
        weighted_list.append(((count - 1) * len(word), word))

    # Then sort by weight descending, word descending
    weighted_list.sort(reverse=True)

    with open(tbl_file, "w", encoding="utf-8") as tbl, open(asm_file, "w", encoding="utf-8") as asm:
        for index in range(word_count):
            code = start_code + index
            if code > 255:
                raise Exception("Word list too large!")
            word = weighted_list[index][1]
            tbl.write(f"{code:2X}={word}\n")
            asm.write(f"  String \"{word}\"\n")


def bitmap_decode(dest_file, source_file, offset):
    with open(source_file, "rb") as source, open(dest_file, "wb") as dest:
        source.seek(offset)
        # We decompress into here
        buffer = bytearray(0x4000)
        # Four bitplanes are interleaved
        for bitplane in range(4):
            offset = bitplane
            while True:
                # Get run byte
                b = ord(source.read(1))
                # 0 = end of bitplane
                if b == 0:
                    break
                run_len = b & 0x7f
                if b & 0x80 == 0x80:
                    # Raw run
                    for i in range(run_len):
                        buffer[offset] = ord(source.read(1))
                        offset += 4
                else:
                    # RLE run
                    b = ord(source.read(1))
                    for i in range(run_len):
                        buffer[offset] = b
                        offset += 4

        # Then save. Offset is that of the last byte written plus 4.
        dest.write(buffer[:offset-3])


class Menu:
    def __init__(self, node, language):
        self.name = node["name"]
        self.emit_data = node["emitData"] == "true" if "emitData" in node else True
        self.ptrs = [int(x.strip(), base=16) for x in node["ptrs"].split(",")] if "ptrs" in node else []
        self.dims = [int(x.strip(), base=16) for x in node["dims"].split(",")] if "dims" in node else []
        self.lines = node[language].splitlines()
        self.width = max(len(x) for x in self.lines)
        if min(len(x) for x in self.lines) != self.width:
            print(f"Warning: uneven line lengths in menu {self.name}\n")
        self.height = int(node["height"]) if "height" in node else len(self.lines)

    def write_data(self, f):
        if self.emit_data:
            # Emit the data at the current (unknown) address
            f.write(f"{self.name}:\n")
            for line in self.lines:
                f.write(f".stringmap tilemap \"{line}\"\n")
        f.write(f".define {self.name}_width  {self.width}\n")
        f.write(f".define {self.name}_height {self.height}\n")
        f.write(f".define {self.name}_dims   {self.width * 2 + self.height * 256}\n")

    def write_patches(self, f):
        f.write(f"; {self.name} patches\n")
        for ptr in self.ptrs:
            f.write(f"  PatchW ${ptr:x} {self.name}\n")
        for ptr in self.dims:
            f.write(f"  PatchB ${ptr+0:x} {self.width}*2\n")
            f.write(f"  PatchB ${ptr+1:x} {self.height}\n")


def menu_creator(data_asm, patches_asm, menus_yaml, language):
    # Read the file
    with open(menus_yaml, "r", encoding="utf-8") as f:
        menus = yaml.load(f, Loader=yaml.BaseLoader)

    # Parse
    menus = [Menu(x, language) for x in menus]

    # Emit
    with open(data_asm, "w", encoding="utf-8") as data, open(patches_asm, "w", encoding="utf-8") as patches:
        for menu in menus:
            menu.write_data(data)
            menu.write_patches(patches)


def main():
    verb = sys.argv[1]
    if verb == 'generate_words':
        generate_words(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], int(sys.argv[6]))
    elif verb == 'bitmap_decode':
        bitmap_decode(sys.argv[2], sys.argv[3], int(sys.argv[4], base=16))
    elif verb == 'menu_creator':
        menu_creator(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
    else:
        print(f"Unknown verb \"{verb}\"")


if __name__ == "__main__":
    main()
