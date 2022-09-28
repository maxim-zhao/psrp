#
# Phantasy Star retranslation makefile
#

# The emulator for testing
EMU = "..\..\..\c\meka\meka\mekaw.exe"

WLAZ80 = wla-z80.exe
WLALINK = wlalink.exe
FLIPS = flips.exe
BMP2TILE = bmp2tile.exe
PY = "py"

# The original PSJ ROM
PSJ = ps1-j.sms

# The language data to use
LANGUAGE = en

# The dictionary size. Maximum is 164.
# A larger word count allows the script chunk to be smaller at the cost of a larger word dictionary and larger Huffman trees.
# The optimal word count depends on the script. Iterating through the options can help to find the best value. Use the "sizes" makefile target to do that.
WORD_COUNT_en = 98
WORD_COUNT_fr = 50
WORD_COUNT_pt-br = 31
WORD_COUNT_ca = 65
WORD_COUNT_es = 42
WORD_COUNT_de = 89
WORD_COUNT_literal = 57
WORD_COUNT = $(WORD_COUNT_$(LANGUAGE))

# Default targets are the patch files for our language
DUMMY: ps1jert.$(LANGUAGE).ips ps1jert.$(LANGUAGE).bps

play: ps1jert.sms
	$(EMU) ps1jert.sms

# bitmap_decode
# Decompresses tile data with the "Phantasy Star RLE" compression, for later recompression.
# This is done to free up ROM space.

# Decompress bitmaps
generated/%.bin: $(PSJ) tools.py
	$(PY) tools.py bitmap_decode $@ $(PSJ) $(basename $(notdir $@))

# Recompress bitmaps
generated/%.psgcompr: generated/%.bin
	$(BMP2TILE) $< -noremovedupes -savetiles $@

# Graphics conversion from PNG for ones where we also translate text. Makefile ordering means these take precendence if possible.
generated/%.psgcompr: new_graphics\%.png
	$(BMP2TILE) $< -noremovedupes -savetiles $@

generated/%.psgcompr: new_graphics\%.$(LANGUAGE).png
	$(BMP2TILE) $< -noremovedupes -savetiles $@

generated/title.top.psgcompr generated/title.top.tilemap.pscompr generated/title-pal.bin: new_graphics\titlescreen.top.png
	$(BMP2TILE) $^ -tileoffset 0 -savetiles generated/title.top.psgcompr -savetilemap generated/title.top.tilemap.pscompr -palsms -savepalette generated/title-pal.bin
generated/title.bottom.psgcompr generated/title.bottom.tilemap.pscompr: new_graphics\titlescreen.$(LANGUAGE).png
	$(BMP2TILE) $^ -tileoffset 256 -savetiles generated/title.bottom.psgcompr -savetilemap generated/title.bottom.tilemap.pscompr

generated/alisa-sprite.tiles.bin: new_graphics\alisa-sprite.png
	$(BMP2TILE) $^ -noremovedupes -savetiles $@

# Generate menu data
generated/menus.asm generated/menu-patches.asm : tools.py menus.yaml
	$(PY) tools.py menu_creator generated/menus.asm generated/menu-patches.asm menus.yaml $(LANGUAGE)

# Analyse the script to determine which words can be substituted for best "compression"
# Converts the word list to a TBL file and an asm file
generated/words.tbl generated/words.asm: tools.py script.yaml
	$(PY) tools.py generate_words generated/words.tbl generated/words.asm script.yaml $(LANGUAGE) $(WORD_COUNT)

# Combine the words and letters symbol dictionaries
generated/script_with_words.tbl: script.$(LANGUAGE).tbl generated/words.tbl
	$(PY) tools.py join $^ $@

# Generate the script data
generated/script.asm generated/script-patches.asm generated/tree.asm: generated/script_with_words.tbl tools.py script.yaml
	$(PY) tools.py script_inserter generated/script.asm generated/script-patches.asm generated/tree.asm script.yaml $(LANGUAGE) generated/script_with_words.tbl

# Generate the font lookup
generated/font-lookup.asm: script.$(LANGUAGE).tbl
	$(PY) tools.py generate_font_lookup $^ generated/font-lookup.asm 

# ROM building

# Generate the dependencies list for assembly
generated/auto.makefile: ps1jert.sms.asm
	$(WLAZ80) -M -D LANGUAGE=$(LANGUAGE) -D WLA_DX_BUG_WORKAROUND -o ps1jert.sms.o $^ > $@
	$(PY) tools.py fix_makefile $@

include generated/auto.makefile

ps1jert.sms.o: ps1jert.sms.asm
	$(WLAZ80) -D LANGUAGE=$(LANGUAGE) -o "$@" "ps1jert.sms.asm"

ps1jert.sms: ps1jert.sms.o
	$(WLALINK) -d -r -v -S linkfile "ps1jert.sms"

ps1jert.$(LANGUAGE).ips: $(PSJ) ps1jert.sms
	$(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).ips

ps1jert.$(LANGUAGE).bps: $(PSJ) ps1jert.sms
	$(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).bps

clean:
	$(PY) tools.py clean generated

sizes: clean
	del sizes.txt
	for /l %%n in (1,1,140) do @del generated\words.tbl & ((make WORD_COUNT=%%n LANGUAGE=$(LANGUAGE) ps1jert.sms 2>&1 || echo ROM:      [failed]) | find "ROM: ") >> sizes.txt
