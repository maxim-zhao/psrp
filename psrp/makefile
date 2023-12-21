WLAZ80 = wla-z80.exe
WLALINK = wlalink.exe
FLIPS = flips.exe
BMP2TILE = bmp2tile.exe
PY = "py"
7Z = "7z"

# The original PSJ ROM
PSJ = PS1-J.SMS

# The dictionary size. Maximum is about 145, depending on how many script codes are used for grammar - see script.tbl for the language in question.
# A larger word count allows the script chunk to be smaller at the cost of a larger word dictionary and larger Huffman trees.
# The optimal word count (for smallest overall data size) depends on the script. Iterating through the options can help to find the best value. `make sizes.en.txt` and similar to do that.
WORD_COUNT_en = 51
WORD_COUNT_fr = 117
WORD_COUNT_pt-br = 58
WORD_COUNT_ca = 56
WORD_COUNT_es = 67
WORD_COUNT_de = 89
WORD_COUNT_literal = 53

# These are targets that aren't files
.PHONY: all clean default

# Disable built-in rules
.SUFFIXES:

# Default target is all the patch files
default: all

# We have to put this before the following one to make it take precedence: if we have a PNG file, use it.
generated/%.bin: new_graphics/%.png
	$(BMP2TILE) $< -noremovedupes -savetiles $@

# Decompress bitmaps
generated/%.bin: $(PSJ) tools.py
	$(PY) tools.py bitmap_decode $@ $(PSJ) $(basename $(notdir $@))

# Recompress bitmaps
generated/%.psgcompr: generated/%.bin
	$(BMP2TILE) $< -noremovedupes -savetiles $@

# Graphics conversion from PNG for ones where we supply PNGs.
generated/%.psgcompr: new_graphics/%.png
	$(BMP2TILE) $< -noremovedupes -savetiles $@

# And per-language ones. There's a <LANGUAGE>/<filename> hidden in the %.
generated/%.psgcompr: %.png tools.py
	$(PY) tools.py mkdir $(dir $@)
	$(BMP2TILE) $< -noremovedupes -savetiles $@

# We generate tiles and tilemap for the title screen, these need specific parameters
generated/title.top.psgcompr generated/title.top.tilemap.pscompr generated/title-pal.bin &: new_graphics/titlescreen.top.png
	$(BMP2TILE) $^ -tileoffset 0 -savetiles generated/title.top.psgcompr -savetilemap generated/title.top.tilemap.pscompr -palsms -savepalette generated/title-pal.bin
generated/title.bottom.%.psgcompr generated/title.bottom.%.tilemap.pscompr &: %/titlescreen.png
	$(BMP2TILE) $^ -tileoffset 256 -savetiles generated/title.bottom.$*.psgcompr -savetilemap generated/title.bottom.$*.tilemap.pscompr

# Generate menu data
generated/%/menus.asm generated/%/menu-patches.asm &: tools.py menus.yaml %/menus.yaml
	$(PY) tools.py menu_creator generated/$*/menus.asm generated/$*/menu-patches.asm menus.yaml $*/menus.yaml $*

# Analyse the script to determine which words can be substituted for best "compression"
# Converts the word list to a TBL file and an asm file
generated/words.%.tbl generated/words.%.asm &: tools.py script.yaml
	$(PY) tools.py generate_words generated/words.$*.tbl generated/words.$*.asm script.yaml $* $(WORD_COUNT_$*)

# Combine the words and letters symbol dictionaries
generated/script_with_words.%.tbl: %/script.tbl generated/words.%.tbl
	$(PY) tools.py join $^ $@

# Generate the script data
generated/script.%.asm generated/tree.%.asm &: generated/script_with_words.%.tbl tools.py script.yaml
	$(PY) tools.py script_inserter generated/script.$*.asm generated/tree.$*.asm script.yaml $* generated/script_with_words.$*.tbl

# Generate the font lookup
generated/font-lookup.%.asm: %/script.tbl tools.py
	$(PY) tools.py generate_font_lookup $< generated/font-lookup.$*.asm 

# Generate the dependencies list for assembly
generated/auto.makefile.%: asm/*
	$(WLAZ80) -M -t -D LANGUAGE=$* -o generated/ps1jert.$*.sms.o -I asm asm/ps1jert.sms.asm > $@

# Now we add in the recipe to actually compile...
generated/ps1jert.%.sms.o:
	$(WLAZ80) -D LANGUAGE=$* -o $@ -I asm asm/ps1jert.sms.asm

# And then link
ps1jert.%.sms: generated/ps1jert.%.sms.o
	echo [objects] > generated/linkfile.$*
	echo "$<" >> generated/linkfile.$*
	$(WLALINK) -d -r -v -S generated/linkfile.$* $@

# And make patches
ps1jert.%.ips: $(PSJ) ps1jert.%.sms
	$(FLIPS) --create $(PSJ) ps1jert.$*.sms $@
ps1jert.%.bps: $(PSJ) ps1jert.%.sms
	$(FLIPS) --create $(PSJ) ps1jert.$*.sms $@


# Generate all the IPS and BPSes for each language found, from */script.tbl
LANGUAGES = $(subst /script.tbl,,$(wildcard */script.tbl))
all: $(foreach lang,$(LANGUAGES),ps1jert.$(lang).ips ps1jert.$(lang).bps)

# Mark various targets as "precious". This makes make keep the files rather than auto-delete them.
.PRECIOUS: ps1jert.%.sms

# We include all languages' makefiles here.
# Make will automatically regenerate them as needed.
# This unfortunately means we generate them for all languages when we only ask for one -
# but I can't find a way to avoid that without running sub-makes.
-include $(foreach lang,$(LANGUAGES),generated/auto.makefile.$(lang))

psrp.zip: all
	$(7Z) a ../psrp.zip *.?ps ../*.md

clean:
	$(PY) tools.py clean generated

sizes.%.txt: script.yaml
	del $@
	for /l %%n in (1,1,140) do @del generated\*.$*.asm generated\*.$*.tbl & (($(MAKE) -j WORD_COUNT_$*=%%n ps1jert.$*.sms 2>&1 || echo ROM:      [failed]) | find "ROM: ") >> $@

../PhantasyStar-SMS-%.zip: ps1jert.%.ips ps1jert.%.bps ../README.md ../translating.md ../translation-notes.md ../technical.md
	$(7Z) a -mx9 $@ $^

zips: $(foreach lang,$(LANGUAGES),../PhantasyStar-SMS-$(lang).zip)
