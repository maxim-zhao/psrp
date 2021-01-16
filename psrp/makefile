#
# Phantasy Star retranslation makefile
#

# The emulator for testing
EMU = "..\..\..\c\meka\meka\mekaw.exe"

WLAZ80 = "..\..\..\c\wla-dx\binaries\wla-z80.exe"
WLALINK = "..\..\..\c\wla-dx\binaries\wlalink.exe"
FLIPS = "..\..\..\sms-build-tools\flips\flips.exe"

# Assume default CPP = cl
CPPFLAGS = /Os /EHsc /W4 /MP /FS /GS- /MD /nologo /WX

# The original PSJ ROM
PSJ = ps1-j.sms

# The language data to use
LANGUAGE = en

# The dictionary size. Maximum is 164.
# A larger word count allows the script chunk to be smaller at the cost of a larger word dictionary and larger Huffman trees.
# The optimal word count depends on the script. Iterating through the options can help to find the best value. CMD one-liner:
# for /l %n in (1,1,140) do @del substring_formatter\words.tbl & ((nmake WORD_COUNT=%n LANGUAGE=pt-br ps1jert.sms 2>&1 || echo 0 unused bytes) | find "unused bytes") >> sizes.txt
# On 2021-01-06 the optimal value for total size was 91 for English and 54 for French.
!IF "$(LANGUAGE)" == "en"
WORD_COUNT = 91
!ENDIF
!IF "$(LANGUAGE)" == "fr"
WORD_COUNT = 54
!ENDIF
!IF "$(LANGUAGE)" == "pt-br"
WORD_COUNT = 41
!ENDIF

DUMMY: ps1jert.$(LANGUAGE).ips ps1jert.$(LANGUAGE).bps

PLAY: ps1jert.sms
  $(EMU) ps1jert.sms

# word_count
# Analyses the script to determine which words can be substituted for best "compression"
word_count\word_count.exe : word_count\*.cpp mini-yaml/yaml/Yaml.cpp
  $(CPP) $(CPPFLAGS) $** /Fe:word_count\word_count.exe

word_count\words.txt : script.yaml word_count\word_count.exe
  word_count\word_count.exe word_count\words.txt script.yaml $(LANGUAGE)

# substring_formatter
# Converts the word list from word_count to a dictionary and a TBL file for those words
substring_formatter\substring_formatter.exe : substring_formatter\*.cpp
  $(CPP) $(CPPFLAGS) $** /Fe:substring_formatter\substring_formatter.exe

substring_formatter\words.tbl substring_formatter\words.asm: substring_formatter\substring_formatter.exe word_count\words.txt
  substring_formatter\substring_formatter.exe $(WORD_COUNT) word_count\words.txt substring_formatter\words.tbl substring_formatter\words.asm

# bitmap_decode
# Decompresses tile data with the "Phantasy Star RLE" compression, for later recompression.
# This is done to free up ROM space.
BITMAP_DECODE = bitmap_decode\bitmap_decode.exe

$(BITMAP_DECODE) : bitmap_decode\*.cpp
  $(CPP) $(CPPFLAGS) $** /Fe:$(BITMAP_DECODE) /W2

new_graphics\bg1.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 40020 $@
new_graphics\bg2.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 40f36 $@
new_graphics\bg3.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 41c82 $@
new_graphics\bg5.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 43406 $@
new_graphics\bg8.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 44650 $@
new_graphics\bg9.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 457d4 $@
new_graphics\bg10.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 464c1 $@
new_graphics\bg11.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 46f68 $@
new_graphics\bg13.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 5ac8d $@
new_graphics\bg14.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 2c010 $@
new_graphics\bg16.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 5eb6f $@
new_graphics\bg29.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 27b24 $@
new_graphics\bg30.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 524ea $@
new_graphics\bg31.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 4c010 $@
new_graphics\world1.bin: $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 747b8 $@
new_graphics\world2.bin: $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 58570 $@


# tile conversion from PNG
new_graphics\font1.psgcompr: new_graphics\font1.$(LANGUAGE).png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\font2.psgcompr: new_graphics\font2.$(LANGUAGE).png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\font3.psgcompr: $*.png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\font1a.psgcompr: new_graphics\font1a.$(LANGUAGE).png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\font2a.psgcompr: new_graphics\font2a.$(LANGUAGE).png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\name-entry-cursor.psgcompr: $*.png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@

new_graphics\title.top.psgcompr new_graphics\title.top.tilemap.pscompr new_graphics\title-pal.bin: new_graphics\titlescreen.top.png
  new_graphics\bmp2tile.exe $** -tileoffset 0 -savetiles new_graphics\title.top.psgcompr -savetilemap new_graphics\title.top.tilemap.pscompr -palsms -savepalette new_graphics\title-pal.bin
new_graphics\title.bottom.psgcompr new_graphics\title.bottom.tilemap.pscompr: new_graphics\titlescreen.$(LANGUAGE).png
  new_graphics\bmp2tile.exe $** -tileoffset 256 -savetiles new_graphics\title.bottom.psgcompr -savetilemap new_graphics\title.bottom.tilemap.pscompr

new_graphics\alisa.tiles.bin: new_graphics\alisa.png
  new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@

new_graphics\bg1.psgcompr   : new_graphics\bg1.bin    ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg2.psgcompr   : new_graphics\bg2.bin    ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg3.psgcompr   : new_graphics\bg3.bin    ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg5.psgcompr   : new_graphics\bg5.bin    ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg8.psgcompr   : new_graphics\bg8.bin    ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg9.psgcompr   : new_graphics\bg9.bin    ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg10.psgcompr  : new_graphics\bg10.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg11.psgcompr  : new_graphics\bg11.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg13.psgcompr  : new_graphics\bg13.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg14.psgcompr  : new_graphics\bg14.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg16.psgcompr  : new_graphics\bg16.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg29.psgcompr  : new_graphics\bg29.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg30.psgcompr  : new_graphics\bg30.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\bg31.psgcompr  : new_graphics\bg31.bin   ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\world1.psgcompr: new_graphics\world1.bin ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@
new_graphics\world2.psgcompr: new_graphics\world2.bin ; new_graphics\bmp2tile.exe $** -noremovedupes -savetiles $@

# menu_creater

menu_creater\menu_creater.exe: menu_creater\*.cpp mini-yaml/yaml/Yaml.cpp
  $(CPP) $(CPPFLAGS) $** /Fe:menu_creater\menu_creater.exe

menu_creater\menus.asm menu_creater\menu-patches.asm : menus.yaml menu_creater\menu_creater.exe
  menu_creater\menu_creater.exe menus.yaml $(LANGUAGE) menu_creater\menus.asm menu_creater\menu-patches.asm

# script_inserter

script_inserter\script_inserter.exe: script_inserter\*.cpp mini-yaml/yaml/Yaml.cpp
  $(CPP) $(CPPFLAGS) $** /Fe:script_inserter\script_inserter.exe

script_with_words.tbl: script.$(LANGUAGE).tbl substring_formatter\words.tbl
  copy /y /b script.$(LANGUAGE).tbl + substring_formatter\words.tbl script_with_words.tbl

script_inserter\script.asm script_inserter\script-patches.asm script_inserter\tree.asm: script_with_words.tbl script_inserter\script_inserter.exe script.yaml
  script_inserter\script_inserter.exe script.yaml $(LANGUAGE) script_with_words.tbl script_inserter\script.asm script_inserter\script-patches.asm script_inserter\tree.asm

# All files needed for the final ROM
BINS = new_graphics\bg1.psgcompr  new_graphics\bg2.psgcompr  new_graphics\bg3.psgcompr  new_graphics\bg5.psgcompr \
       new_graphics\bg8.psgcompr  new_graphics\bg9.psgcompr  new_graphics\bg10.psgcompr new_graphics\bg11.psgcompr \
       new_graphics\bg13.psgcompr new_graphics\bg14.psgcompr new_graphics\bg16.psgcompr new_graphics\bg29.psgcompr \
       new_graphics\bg30.psgcompr new_graphics\bg31.psgcompr \
       new_graphics\world1.psgcompr new_graphics\world2.psgcompr \
       new_graphics\font1.psgcompr new_graphics\font2.psgcompr new_graphics\font3.psgcompr \
       new_graphics\font1a.psgcompr new_graphics\font2a.psgcompr \
       new_graphics\name-entry-cursor.psgcompr \
       new_graphics\title.top.psgcompr new_graphics\title.top.tilemap.pscompr new_graphics\title-pal.bin \
       new_graphics\title.bottom.psgcompr new_graphics\title.bottom.tilemap.pscompr \
       new_graphics\alisa.tiles.bin

# ROM building
ps1jert.sms.o: $(PSJ) menu_creater\menus.asm menu_creater\menu-patches.asm substring_formatter\words.asm script_inserter\tree.asm tilemap.$(LANGUAGE).tbl script.$(LANGUAGE).tbl credits.tbl $(BINS) ps1jert.sms.asm
  $(WLAZ80) -D LANGUAGE=$(LANGUAGE) -o "ps1jert.sms.o" "ps1jert.sms.asm"

ps1jert.sms: ps1jert.sms.o
  $(WLALINK) -d -r -v -S linkfile "ps1jert.sms"
  @echo Successful: translated file is ps1jert.sms

CLEANFILES = $(BINS) \
       menu_creater\*.asm \
       script_inserter\*.asm \
       script_with_words.tbl \
       substring_formatter\words.tbl substring_formatter\words.asm \
       word_count\stats.txt word_count\words.txt \
       word_count\word_count.exe \
       substring_formatter\substring_formatter.exe \
       bitmap_decode\bitmap_decode.exe \
       menu_creater\menu_creater.exe \
       script_inserter\script_inserter.exe

ps1jert.$(LANGUAGE).ips: $(PSJ) ps1jert.sms
  $(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).ips

ps1jert.$(LANGUAGE).bps: $(PSJ) ps1jert.sms
  $(FLIPS) --create $(PSJ) ps1jert.sms ps1jert.$(LANGUAGE).bps

clean:
  del $(CLEANFILES)
