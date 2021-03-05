#
# Phantasy Star retranslation makefile
#

# The emulator for testing
EMU = "..\..\..\c\meka\meka\mekaw.exe"

WLAZ80 = "..\..\..\c\wla-dx\binaries\wla-z80.exe"
WLALINK = "..\..\..\c\wla-dx\binaries\wlalink.exe"
FLIPS = "..\..\..\sms-build-tools\flips\flips.exe"
BMP2TILE = ..\..\..\c^#\bmp2tile\bmp2tile.exe
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
!IF "$(LANGUAGE)" == "en"
WORD_COUNT = 91
!ENDIF
!IF "$(LANGUAGE)" == "fr"
WORD_COUNT = 54
!ENDIF
!IF "$(LANGUAGE)" == "pt-br"
WORD_COUNT = 48
!ENDIF
!IF "$(LANGUAGE)" == "ca"
WORD_COUNT = 48
!ENDIF

DUMMY: ps1jert.$(LANGUAGE).ips ps1jert.$(LANGUAGE).bps

PLAY: ps1jert.sms
  $(EMU) ps1jert.sms

# generate_words
# Analyses the script to determine which words can be substituted for best "compression"
# Converts the word list to a TBL file and an asm file
words.tbl words.asm: tools.py script.yaml
  $(PY) tools.py generate_words words.tbl words.asm script.yaml $(LANGUAGE) $(WORD_COUNT)

# bitmap_decode
# Decompresses tile data with the "Phantasy Star RLE" compression, for later recompression.
# This is done to free up ROM space.
new_graphics\bg1.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 40020
new_graphics\bg2.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 40f36
new_graphics\bg3.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 41c82
new_graphics\bg5.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 43406
new_graphics\bg8.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 44650
new_graphics\bg9.bin   : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 457d4
new_graphics\bg10.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 464c1
new_graphics\bg11.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 46f68
new_graphics\bg13.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 5ac8d
new_graphics\bg14.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 2c010
new_graphics\bg16.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 5eb6f
new_graphics\bg29.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 27b24
new_graphics\bg30.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 524ea
new_graphics\bg31.bin  : $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 4c010
new_graphics\world1.bin: $(PSJ) tools.py ; $(PY) tools.py bitmap_decode $@ $(PSJ) 747b8

# Recompression for the above
new_graphics\bg1.psgcompr   : new_graphics\bg1.bin    ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg2.psgcompr   : new_graphics\bg2.bin    ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg3.psgcompr   : new_graphics\bg3.bin    ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg5.psgcompr   : new_graphics\bg5.bin    ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg8.psgcompr   : new_graphics\bg8.bin    ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg9.psgcompr   : new_graphics\bg9.bin    ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg10.psgcompr  : new_graphics\bg10.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg11.psgcompr  : new_graphics\bg11.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg13.psgcompr  : new_graphics\bg13.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg14.psgcompr  : new_graphics\bg14.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg16.psgcompr  : new_graphics\bg16.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg29.psgcompr  : new_graphics\bg29.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg30.psgcompr  : new_graphics\bg30.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\bg31.psgcompr  : new_graphics\bg31.bin   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\world1.psgcompr: new_graphics\world1.bin ; $(BMP2TILE) $** -noremovedupes -savetiles $@

# Graphics conversion from PNG
new_graphics\font-polaris-part1.psgcompr: $*.$(LANGUAGE).png       ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\font-polaris-part2.psgcompr: $*.$(LANGUAGE).png       ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\font-aw2284-part1.psgcompr: $*.$(LANGUAGE).png      ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\font-aw2284-part2.psgcompr: $*.$(LANGUAGE).png      ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\font-credits.psgcompr: $*.png                   ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\name-entry-cursor.psgcompr: $*.png       ; $(BMP2TILE) $** -noremovedupes -savetiles $@
new_graphics\world2.psgcompr: $*.$(LANGUAGE).png      ; $(BMP2TILE) $** -noremovedupes -savetiles $@

new_graphics\title.top.psgcompr new_graphics\title.top.tilemap.pscompr new_graphics\title-pal.bin: new_graphics\titlescreen.top.png
  $(BMP2TILE) $** -tileoffset 0 -savetiles new_graphics\title.top.psgcompr -savetilemap new_graphics\title.top.tilemap.pscompr -palsms -savepalette new_graphics\title-pal.bin
new_graphics\title.bottom.psgcompr new_graphics\title.bottom.tilemap.pscompr: new_graphics\titlescreen.$(LANGUAGE).png
  $(BMP2TILE) $** -tileoffset 256 -savetiles new_graphics\title.bottom.psgcompr -savetilemap new_graphics\title.bottom.tilemap.pscompr

new_graphics\alisa-sprite.tiles.bin: new_graphics\alisa-sprite.png
  $(BMP2TILE) $** -noremovedupes -savetiles $@

# menu_creater

menus.asm menu-patches.asm : tools.py menus.yaml
  $(PY) tools.py menu_creator menus.asm menu-patches.asm menus.yaml $(LANGUAGE)

# script_inserter

script_with_words.tbl: script.$(LANGUAGE).tbl words.tbl
  copy /y /b script.$(LANGUAGE).tbl + words.tbl script_with_words.tbl

script.asm script-patches.asm tree.asm: script_with_words.tbl tools.py script.yaml
  $(PY) tools.py script_inserter script.asm script-patches.asm tree.asm script.yaml $(LANGUAGE) script_with_words.tbl

# All files needed for the final ROM
BINS = new_graphics\bg1.psgcompr  new_graphics\bg2.psgcompr  new_graphics\bg3.psgcompr  new_graphics\bg5.psgcompr \
       new_graphics\bg8.psgcompr  new_graphics\bg9.psgcompr  new_graphics\bg10.psgcompr new_graphics\bg11.psgcompr \
       new_graphics\bg13.psgcompr new_graphics\bg14.psgcompr new_graphics\bg16.psgcompr new_graphics\bg29.psgcompr \
       new_graphics\bg30.psgcompr new_graphics\bg31.psgcompr \
       new_graphics\world1.psgcompr new_graphics\world2.psgcompr \
       new_graphics\font-polaris-part1.psgcompr new_graphics\font-polaris-part2.psgcompr \
       new_graphics\font-aw2284-part1.psgcompr new_graphics\font-aw2284-part2.psgcompr \
       new_graphics\font-credits.psgcompr \
       new_graphics\name-entry-cursor.psgcompr \
       new_graphics\title.top.psgcompr new_graphics\title.top.tilemap.pscompr new_graphics\title-pal.bin \
       new_graphics\title.bottom.psgcompr new_graphics\title.bottom.tilemap.pscompr \
       new_graphics\alisa-sprite.tiles.bin

GENERATED_ASMS = menus.asm menu-patches.asm script.asm script-patches.asm tree.asm words.asm

# ROM building
ps1jert.sms.o: $(PSJ) $(GENERATED_ASMS) tilemap.$(LANGUAGE).tbl script.$(LANGUAGE).tbl credits.tbl $(BINS) ps1jert.sms.asm
  $(WLAZ80) -D LANGUAGE=$(LANGUAGE) -o "ps1jert.sms.o" "ps1jert.sms.asm"

ps1jert.sms: ps1jert.sms.o
  $(WLALINK) -d -r -v -S linkfile "ps1jert.sms"
  @echo Successful: translated file is ps1jert.sms

CLEANFILES = $(BINS) $(GENERATED_ASMS) script_with_words.tbl words.tbl new_graphics\*.bin

ps1jert.$(LANGUAGE).ips: $(PSJ) ps1jert.sms
  $(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).ips

ps1jert.$(LANGUAGE).bps: $(PSJ) ps1jert.sms
  $(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).bps

clean:
  del $(CLEANFILES)
