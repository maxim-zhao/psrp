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
# The optimal word count depends on the script. Iterating through the options can help to find the best value. CMD one-liner:
# for /l %n in (1,1,140) do @del words.tbl & ((nmake WORD_COUNT=%n LANGUAGE=pt-br ps1jert.sms 2>&1 || echo 0 unused bytes) | find "unused bytes") >> sizes.txt
# On 2021-01-06 the optimal value for total size was 91 for English and 54 for French.
ifeq ("$(LANGUAGE)", "en")
WORD_COUNT = 91
endif
ifeq ("$(LANGUAGE)", "fr")
WORD_COUNT = 54
endif
ifeq ("$(LANGUAGE)", "pt-br")
WORD_COUNT = 48
endif
ifeq ("$(LANGUAGE)", "ca")
WORD_COUNT = 45
endif

# Default targets are the patch files for our language
DUMMY: ps1jert.$(LANGUAGE).ips ps1jert.$(LANGUAGE).bps

play: ps1jert.sms
	$(EMU) ps1jert.sms

# bitmap_decode
# Decompresses tile data with the "Phantasy Star RLE" compression, for later recompression.
# This is done to free up ROM space.
generated/bg1.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 40020
generated/bg2.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 40f36
generated/bg3.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 41c82
generated/bg5.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 43406
generated/bg8.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 44650
generated/bg9.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 457d4
generated/bg10.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 464c1
generated/bg11.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 46f68
generated/bg13.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 5ac8d
generated/bg14.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 2c010
generated/bg16.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 5eb6f
generated/bg29.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 27b24
generated/bg30.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 524ea
generated/bg31.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 4c010
generated/world1.bin: $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 747b8

# Recompression for the above
generated/%.psgcompr: generated/%.bin
	$(BMP2TILE) $< -noremovedupes -savetiles $@

# Graphics conversion from PNG
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
