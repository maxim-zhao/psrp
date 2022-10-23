import sys
import os
import re
import yaml

start_code = 0x6d  # see WordListStart in asm


def generate_words(tbl_file, asm_file, script_file, language, word_count):
    with open(script_file, "r", encoding="utf-8") as f:
        script = yaml.load(f, Loader=yaml.BaseLoader)  # BaseLoader keeps everything as strings

    # dict of word to count
    words = {}
    for entry in script:
        # Discard unused entries
        if "offsets" not in entry or entry["offsets"] == "":
            continue;
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
    # compress, so common letter sequences are cheaper than unusual ones the Huffman trees are also stored outside the
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
        dest.write(buffer[:offset - 3])


class Menu:
    def __init__(self, node, language):
        try:
            self.name = node["name"]
            self.emit_data = node["emitData"] == "true" if "emitData" in node else True
            self.ptrs = [int(x.strip(), base=16) for x in node["ptrs"].split(",")] if "ptrs" in node else []
            self.dims = [int(x.strip(), base=16) for x in node["dims"].split(",")] if "dims" in node else []
            self.lines = node[language].splitlines()
            self.width = max(len(x) for x in self.lines)
            if min(len(x) for x in self.lines) != self.width:
                print(f"Warning: uneven line lengths in menu {self.name}\n")
            self.height = int(node["height"]) if "height" in node else len(self.lines)
        except:
            print(f"Error parsing menu {node}")
            raise

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
            f.write(f"  PatchB ${ptr + 0:x} {self.width}*2\n")
            f.write(f"  PatchB ${ptr + 1:x} {self.height}\n")


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


class Table:
    def __init__(self, filename):
        self.index_to_text = {}
        self.text_to_symbol = {}
        with open(filename, "r", encoding="utf-8") as f:
            for line in f.read().splitlines():
                match = re.fullmatch("([0-9a-zA-Z]+)=(.+)", line)
                if match:
                    value = bytes.fromhex(match.group(1))
                    text = match.group(2)
                    self.text_to_symbol[text] = value
                    index = int.from_bytes(value, byteorder="little")
                    if index < 256 and index not in self.index_to_text:
                        self.index_to_text[index] = text

        self.longest_value = max(len(x) for x in self.text_to_symbol)

    def find_longest_match(self, s):
        """
        Returns the bytes value and string length for the longest match for the start of string s,
        or None if no match
        """
        # We do this by trying one character at a time until we fail.
        length = 0
        match = -1
        max_length = min(self.longest_value, len(s))
        candidate = ""
        for trial_length in range(1, max_length+1):
            candidate += s[trial_length - 1]
            if candidate in self.text_to_symbol:
                # Remember it
                length = trial_length
                match = self.text_to_symbol[candidate]
        if length == 0:
            print(f"Unable to find match for {s}")
            return None
        else:
            return match, length

    def text_for_index(self, index):
        return self.index_to_text.get(index)


class ScriptingCode:
    # This matches an enum in the assembly code with the same names
    SymbolPlayer, SymbolMonster, SymbolItem, SymbolNumber, SymbolBlank, SymbolNewLine, SymbolWaitMore, SymbolEnd, \
        SymbolDelay, SymbolWait, SymbolPostHint, SymbolArticle, SymbolSuffix, SymbolPronoun = range(0x5f, 0x6d)


def get_word_length(s):
    # We count characters that are not ' ' or '<'
    for i in range(len(s)):
        if s[i] == ' ' or s[i] == '<':
            break
    return i


class ScriptEntry:
    def __init__(self, entry, language, entry_number, table: Table, max_width):
        # Get the text and replace ' with ’
        self.text = entry[language].replace("'", "’")

        # The "offsets" text is a comma-separated list of either a label or hex offsets to patch.
        self.offsets = []
        self.label = f"Script{entry_number}"
        for offset in [x.strip() for x in entry["offsets"].split(",")]:
            if re.match("[0-9A-Fa-f]{4}\\w*", offset):
                self.offsets.append(int(offset, base=16))
            else:
                self.label = offset

        # Initialise parsing state
        self.internal_hint = 0  # Set to a number if an "internal hint" has happened
        self.current_line_length = 0  # Length of the current line
        self.max_width = max_width  # Max width of a line
        self.script_hints = False  # True if some runtime text insertion is needed
        self.script_end = False  # True when an ending tag is encountered

        # Get the text into a new string and remove line breaks
        s = self.text.replace("\n", "")

        # Work through the string
        self.buffer = bytearray()
        while len(s) > 0:
            # Check for a tag
            match = re.match("<([^>]+?)( ([A-Za-z0-9]{2}))?>", s)
            if match:
                # Consume the matched text
                s = s[len(match.group(0)):]
                # Parse the tag
                self.parse_tag(match, s)
            else:
                # Not a tag

                # If it's a space, consider wrapping
                if s[0] == " ":
                    next_word_length = get_word_length(s[1:])
                    line_length_with_next_word = self.current_line_length + 1 + next_word_length
                    if line_length_with_next_word > self.max_width and not self.script_hints:
                        # Replace space with <line>
                        self.buffer.append(ScriptingCode.SymbolNewLine)
                        self.current_line_length = 0
                        # Skip space
                        s = s[1:]
                        continue
                    if self.script_hints and next_word_length > 0:
                        # real-time line formatting needed
                        self.buffer.append(ScriptingCode.SymbolPostHint)
                        self.buffer.append(next_word_length + self.internal_hint)

                        # manual hint flag reset
                        self.internal_hint = 0

                # Look up in table
                value, length = table.find_longest_match(s)
                if not value:
                    raise Exception(f"Unmapped character '{s[0]}'")

                # Append to the line
                self.current_line_length += length
                self.buffer += bytearray(value)
                # Consume from the string
                s = s[length:]

                # Stop at an ending tag
                if self.script_end:
                    if len(s) > 0:
                        raise Exception("Text after end tag")
                    break
        if not self.script_end:
            raise Exception("Missing end tag")

    def parse_tag(self, match, s):
        # parses the match as a tag into self.buffer
        # s is the text after it
        tag = match.group(1)
        if tag == "internal hint" and match.group(3) is not None:
            self.internal_hint = int(match.group(3), base=16)
            self.script_hints = True
        elif tag == "player":
            self.check_suffix_length(1, 6, s)
            self.buffer.append(ScriptingCode.SymbolPlayer)
        elif tag == "monster":
            self.check_suffix_length(1, self.max_width, s)
            self.buffer.append(ScriptingCode.SymbolMonster)
        elif tag == "item":
            self.check_suffix_length(1, self.max_width, s)
            self.buffer.append(ScriptingCode.SymbolItem)
        elif tag == "number":
            self.check_suffix_length(1, 5, s)
            self.buffer.append(ScriptingCode.SymbolNumber)
        elif tag == "line":
            # add newline
            self.buffer.append(ScriptingCode.SymbolNewLine)
            self.current_line_length = 0
            self.script_hints = False
        elif tag == "wait more":
            self.buffer.append(ScriptingCode.SymbolWaitMore)
            self.current_line_length = 0
            self.script_hints = False
        elif tag == "end":
            self.buffer.append(ScriptingCode.SymbolEnd)
            # de-init
            self.script_end = True
            self.script_hints = False
            self.current_line_length = 0
        elif tag == "delay":
            self.buffer.append(ScriptingCode.SymbolDelay)
            self.buffer.append(ScriptingCode.SymbolEnd)
            # de-init
            self.script_end = True
            self.script_hints = False
            self.current_line_length = 0
        elif tag == "wait":
            self.buffer.append(ScriptingCode.SymbolWait)
            self.buffer.append(ScriptingCode.SymbolEnd)
            # de-init
            self.script_end = True
            self.script_hints = False
            self.current_line_length = 0
        # Articles
        # TODO: extract these from the tbl?
        elif tag == "article":
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(1)  # lowercase
            self.script_hints = True
        elif tag == "Article":
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(2)  # uppercase
            self.script_hints = True
        elif tag == "de" or tag == "do" or tag == "del":
            # Possessives (fr, pt-br, ca, es)
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(3)
            self.script_hints = True
        elif tag == "à":
            # Directives (fr)
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(4)
            self.script_hints = True
        elif tag == "use article" and match.groups(3) is not None:
            # Fallback on manual numbers (should not be used in the final script)
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(int(match.groups(3), base=16))
            self.script_hints = True
        elif tag == "s":
            # Simplistic pluralisation
            self.buffer.append(ScriptingCode.SymbolSuffix)
            self.script_hints = True
        elif tag == "Nom":
            # Nominative (de), no lowercase needed?
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(1)
            pass
        elif tag == "gen":
            # Genetive (de), no uppercase needed?
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(2)
            pass
        elif tag == "dat":
            # Dative (de), no uppercase needed?
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(3)
            pass
        elif tag == "acc":
            # Accusative (de), no uppercase needed?
            self.buffer.append(ScriptingCode.SymbolArticle)
            self.buffer.append(4)
            pass
        elif tag == "he" or tag == "she" or tag == "Sie" or tag == "Er" or tag == "ela" or tag == "Elle" or tag == "Il" or tag == "ell" or tag == "ella" or tag == "él":
            # Pronoun
            self.buffer.append(ScriptingCode.SymbolPronoun)
            self.buffer.append(0)
            self.script_hints = True
            pass
        elif tag == "his" or tag == "her" or tag == "sie" or tag == "er" or tag == "elle" or tag == "il" or tag == "el seu" or tag == "la seva" or tag == "su":
            # Careful, "him/her" would get confused here
            # Pronoun
            self.buffer.append(ScriptingCode.SymbolPronoun)
            self.buffer.append(1)
            self.script_hints = True
            pass
        else:
            raise Exception(f"Ignoring tag \"{match.group(0)}\"")

    def check_suffix_length(self, min_length, max_length, s):
        # Adds a "post hint" if there is a suffix on this tag
        # Check for any suffix text
        suffix_length = get_word_length(s)
        # Emit a "post hint" if there isn't one already
        if not self.script_hints:
            if self.current_line_length + suffix_length + min_length > self.max_width:
                suffix_length = 0
            if self.current_line_length + suffix_length + max_length <= self.max_width:
                suffix_length = 0
        if suffix_length > 0:
            self.buffer.append(ScriptingCode.SymbolPostHint)
            self.buffer.append(suffix_length)
        self.script_hints = True


class BitWriter:
    """Deals with writing bits into a buffer"""
    def __init__(self):
        self.buffer = bytearray()
        self.bit_count = 0
        self.current_byte = 0

    def add(self, bit: bool):
        # Add bit to current_byte, from the right
        self.current_byte = (self.current_byte << 1) & 0xff
        if bit:
            self.current_byte += 1
        self.bit_count += 1

        # Add to buffer when full
        if self.bit_count == 8:
            self.buffer.append(self.current_byte)
            self.bit_count = 0

    def flush(self):
        while self.bit_count != 0:
            self.add(False)


class Node:
    # Pass symbol/count for a leaf, left/right for a parent
    def __init__(self, symbol=None, count=None, left=None, right=None):
        self.symbol = symbol
        self.count = count
        self.left = left
        self.right = right
        self.bits = []

        if left is not None:
            self.symbol = -1
            self.count = left.count + right.count
            # Prepend the "bits" of the children so they can learn their "path"
            left.prepend_bits(False)
            right.prepend_bits(True)

    def prepend_bits(self, value):
        # If we are a leaf, take the bit
        if self.symbol > -1:
            self.bits.insert(0, value)
        else:
            # propagate to children
            self.left.prepend_bits(value)
            self.right.prepend_bits(value)

    def emit_symbols(self, f):
        if self.symbol > -1:
            f.write(f" ${self.symbol:02x}")
            return 1
        return self.right.emit_symbols(f) + self.left.emit_symbols(f)

    def emit_structure(self, bit_writer):
        # Stringify each node's type (1 = value, 0 = parent), left to right
        if self.symbol > -1:
            bit_writer.add(True)
            return
        bit_writer.add(False)
        self.left.emit_structure(bit_writer)
        self.right.emit_structure(bit_writer)

    def __str__(self):
        return f"{self.symbol:02x} x {self.count}"


class Tree:
    def __init__(self, preceding_byte, nodes):
        self.name = f"HuffmanTree{preceding_byte:02X}"
        self.nodes_by_symbol = {node.symbol:node for node in nodes}

        if len(nodes) == 0:
            # Nothing to do
            self.root = None
            return

        # Sort the nodes by count descending. This puts the lowest counts at the end.
        sorted_nodes = []
        for node in nodes:
            self.insert(sorted_nodes, node)

        # Then combine them into each other to make a Huffman tree
        while len(sorted_nodes) > 1:
            # When we build the tree, we put the smaller node on the left.
            left = sorted_nodes.pop()
            right = sorted_nodes.pop()
            node = Node(left=left, right=right)
            self.insert(sorted_nodes, node)

        # Then keep the root
        self.root = sorted_nodes[0]

    @staticmethod
    def insert(nodes, node):
        # Nodes are assumed to be in decreasing order by count.
        # Insert this node at the first position that is less than it, i.e. the rightmost place for it
        for index in range(len(nodes)):
            if nodes[index].count < node.count:
                nodes.insert(index, node)
                return
        # Nowhere found, must go at the end
        nodes.append(node)

    def empty(self):
        return self.root is None

    def emit_symbols(self, f):
        if self.root is None:
            return 0
        return self.root.emit_symbols(f)

    def emit_structure(self, f):
        if self.root is None:
            return 0

        bit_writer = BitWriter()
        self.root.emit_structure(bit_writer)
        bit_writer.flush()

        f.write(".db")
        for b in bit_writer.buffer:
            f.write(f" %{b:08b}")

        return len(bit_writer.buffer)

    def emit_bits(self, symbol: int, bit_writer: BitWriter):
        # Find the node for this symbol
        node = self.nodes_by_symbol[symbol]
        # Emit its bits
        for bit in node.bits:
            bit_writer.add(bit)


def script_inserter(data_file, patch_file, trees_file, script_file, language, tbl_file):
    table = Table(tbl_file)
    with open(script_file, "r", encoding="utf-8") as f:
        script_yaml = yaml.load(f, Loader=yaml.CBaseLoader)

    entry_number = 0
    max_width = -1

    script = []
    for node in script_yaml:
        # If it has dimensions, use them from now on
        if "width" in node:
            max_width = int(node["width"])

        # If there's no offsets specified, it means the item is unused
        if "offsets" not in node or node["offsets"] == "":
            continue

        try:
            script_entry = ScriptEntry(node, language, entry_number, table, max_width)
            script.append(script_entry)
        except:
            print(f"Error parsing line: {node}\n")
            raise

        entry_number += 1

    # Measure script
    script_symbols_count = 0
    char_count = 0
    symbol_counts = [0] * 256
    for entry in script:
        script_symbols_count += len(entry.buffer)
        char_count += len(entry.text)
        for b in entry.buffer:
            symbol_counts[b] += 1

    # We don't exactly know the dict size, we assume it's all the non-tag-looking words in the table file
    # They are stored as length-prefixed strings
    dict_size = sum([len(x)+1 for x in table.text_to_symbol.keys() if len(x) > 1 and x[0] != "<"])

    print(f"Dictionary encoding gives {script_symbols_count} bytes for {char_count} characters " +
          f"in {len(script)} script entries with a {dict_size} bytes dictionary " +
          f"({(char_count - (script_symbols_count + dict_size))/char_count*100:.2f}% compression)")

    for i in range(256):
        if symbol_counts[i] == 0:
            text = table.text_for_index(i)
            if text is not None:
                print(f"Symbol ${i:02X} is unused (\"{text}\")")

    # Now we Huffman compress the data with per-byte trees
    # First we count the frequencies per preceding byte
    counts = [[0 for i in range(256)] for j in range(256)]
    for entry in script:
        preceding_byte = ScriptingCode.SymbolEnd
        for b in entry.buffer:
            counts[preceding_byte][b] += 1
            preceding_byte = b

    # Next we build trees for each of them
    trees = []
    for preceding_byte in range(0, 256):
        # Make a tree from this entry
        # First we make nodes for all the values with non-zero counts
        nodes = []
        for symbol in range(0, 256):
            count = counts[preceding_byte][symbol]
            if count > 0:
                nodes.append(Node(symbol=symbol, count=count))

        trees.append(Tree(preceding_byte, nodes))

    # Remove any trailing "empty trees" (i.e. unused symbols). We can't not add them as gaps need to be filled.
    while trees[-1].empty():
        trees.pop()

    # Emit Huffman trees as assembly
    with open(trees_file, "w", encoding="utf-8") as f:
        f.write("TreeVector:\n.dw")
        # Labels
        for tree in trees:
            if tree.empty():
                f.write(" $ffff")
            else:
                f.write(f" {tree.name}")
        f.write("\n")
        trees_size = len(trees) * 2
        # Data
        for preceding_byte in range(0, len(trees)):
            tree = trees[preceding_byte]
            if tree.empty():
                continue
            f.write(f"; Dictionary elements that can follow element ${preceding_byte:x}\n.db")
            trees_size += tree.emit_symbols(f)
            f.write(f"\n{tree.name}: ; Binary tree structure for the above\n")
            trees_size += tree.emit_structure(f)
            f.write("\n")

        print(f"Huffman trees take {trees_size} bytes")

    # Emit the Huffman-encoded script
    with open(data_file, "w", encoding="utf-8") as f:
        f.write("; Script entries, Huffman compressed\n")

        script_size = 0

        for entry in script:
            f.write(f"\n{entry.label}:\n/*{entry.text}*/\n.db")

            # Starting tree number
            preceding_byte = ScriptingCode.SymbolEnd

            # Write into a buffer
            bit_writer = BitWriter()
            for symbol in entry.buffer:
                trees[preceding_byte].emit_bits(symbol, bit_writer)

                # Use new symbol as fresh index
                preceding_byte = symbol

            bit_writer.flush()

            script_size += len(bit_writer.buffer)

            # Emit as assembly
            for b in bit_writer.buffer:
                f.write(f" %{b:08b}")

    with open(patch_file, "w", encoding="utf-8") as f:
        f.write("; Patches to point at new script entries\n")
        for entry in script:
            for offset in entry.offsets:
                f.write(f" PatchW ${offset + 1:04x} {entry.label}\n")

    print(f"Huffman compressed script is {script_size} bytes")

    total_size = script_size + trees_size + dict_size

    print(f"Total space is {script_size} + {trees_size} + {dict_size} = {total_size} bytes " +
          f"({(char_count - total_size) / char_count * 100:.2f}% compression)")


def fix_makefile(path):
   with open(path, 'r') as f:
       lines = f.readlines()
   with open(path, 'w') as f:
       f.writelines([re.sub('\\\\(.)', '/\\1', x) for x in lines if not 'INTERNAL' in x])


def join(f1, f2, dest):
    with open(f1, 'r', encoding="utf-8") as f:
        lines = f.readlines()
    with open(f2, 'r', encoding="utf-8") as f:
        lines = lines + f.readlines()
    with open(dest, 'w', encoding="utf-8") as f:
        f.writelines(lines)


def clean(path):
    for root, dirs, files in os.walk(path):
        for file in files:
            os.remove(os.path.join(root, file))


def generate_font_lookup(tbl_file, lookup_file):
    tbl = Table(tbl_file)
    max_symbol = max(filter(lambda x: x < 0x5f, tbl.index_to_text.keys()))
    print(f"Max key is {hex(max_symbol)}")
    with open(lookup_file, "w", encoding="utf-8") as f:
        f.write(".stringmap tilemap \"")
        for i in range(max_symbol + 1):
            text = tbl.text_for_index(i)
            if text is None:
                print(f"No symbol for index {hex(i)}!")
                f.write(" "); # blank fill
            else:
                f.write(text)
        f.write("\"")



def main():
    verb = sys.argv[1]
    if verb == 'generate_words':
        generate_words(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], int(sys.argv[6]))
    elif verb == 'bitmap_decode':
        bitmap_decode(sys.argv[2], sys.argv[3], int(sys.argv[4], base=16))
    elif verb == 'menu_creator':
        menu_creator(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
    elif verb == 'script_inserter':
        script_inserter(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7])
    elif verb == 'fix_makefile':
        fix_makefile(sys.argv[2])
    elif verb == 'join':
        join(sys.argv[2], sys.argv[3], sys.argv[4])
    elif verb == 'clean':
        clean(sys.argv[2])
    elif verb == 'generate_font_lookup':
        generate_font_lookup(sys.argv[2], sys.argv[3])
    else:
        raise Exception(f"Unknown verb \"{verb}\"")


if __name__ == "__main__":
    main()
