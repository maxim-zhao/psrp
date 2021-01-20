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
                    print(f"Warning: entry has no text for offets {offsets}")
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


def main():
    verb = sys.argv[1]
    if verb == 'generate_words':
        generate_words(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], int(sys.argv[6]))
    else:
        print(f"Unknown verb \"{verb}\"")


if __name__ == "__main__":
    main()
