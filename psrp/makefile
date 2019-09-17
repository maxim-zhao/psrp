#
# Phantasy Star retranslation makefile
#

# The emulator for testing
EMU = "..\..\..\c\meka\meka\mekaw.exe"

WLAZ80 = "..\..\..\c\wla-dx\binaries\wla-z80.exe"
WLALINK = "..\..\..\c\wla-dx\binaries\wlalink.exe"

# Assume default CPP = cl
CPPFLAGS = /O2 /EHsc /W2 /Zi /MP

# The original PSJ ROM
PSJ = ps1-j.sms

DUMMY: ps1jert.sms

PLAY: ps1jert.sms
	$(EMU) ps1jert.sms

# word_count
# Analyses the script to determine which words can be substituted for best "compression"
word_count\word_count.exe : word_count\*.cpp
  $(CPP) $(CPPFLAGS) word_count\*.cpp /Fe:word_count\word_count.exe

word_count\words.txt : word_count\script1.txt word_count\script2.txt word_count\word_count.exe
  word_count\word_count.exe word_count\words.txt word_count\script1.txt word_count\script2.txt

# substring_formatter
# Converts the word list from word_count to a dictionary and a TBL file for those words
substring_formatter\substring_formatter.exe : substring_formatter\*.cpp
  $(CPP) $(CPPFLAGS) substring_formatter\*.cpp /Fe:substring_formatter\substring_formatter.exe

substring_formatter\words.tbl substring_formatter\words.asm: substring_formatter\substring_formatter.exe word_count\words.txt
	substring_formatter\substring_formatter.exe 0x80 word_count\words.txt substring_formatter\words.tbl substring_formatter\words.asm

# bitmap_decode
# Decompresses tile data with the "Phantasy Star RLE" compression, for later recompression.
# This is done to free up ROM space.
BITMAP_DECODE = bitmap_decode\bitmap_decode.exe

$(BITMAP_DECODE) : bitmap_decode\*.cpp
  $(CPP) $(CPPFLAGS) bitmap_decode\*.cpp /Fe:$(BITMAP_DECODE)

psg_encoder\bg1.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 40020 $@
psg_encoder\bg2.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 40f36 $@
psg_encoder\bg3.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 41c82 $@
psg_encoder\bg5.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 43406 $@
psg_encoder\bg8.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 44650 $@
psg_encoder\bg9.bin   : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 457d4 $@
psg_encoder\bg10.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 464c1 $@
psg_encoder\bg11.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 46f68 $@
psg_encoder\bg13.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 5ac8d $@
psg_encoder\bg14.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 2c010 $@
psg_encoder\bg16.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 5eb6f $@
psg_encoder\bg29.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 27b24 $@
psg_encoder\bg30.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 524ea $@
psg_encoder\bg31.bin  : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 4c010 $@
#psg_encoder\title.bin : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 7e8bd $@ # Replaced with a custom image
psg_encoder\world1.bin: $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 747b8 $@
psg_encoder\world2.bin: $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 58570 $@


# tile conversion from PNG
# This is for "original" graphics.
new_graphics\font1.bin: new_graphics\font1.png
	new_graphics\bmp2tile.exe $** -4bit -noremovedupes -savetilesbin $@ -exit

new_graphics\font2.bin: new_graphics\font2.png
	new_graphics\bmp2tile.exe $** -4bit -noremovedupes -savetilesbin $@ -exit

new_graphics\font3.bin: new_graphics\font3.png
	new_graphics\bmp2tile.exe $** -4bit -noremovedupes -savetilesbin $@ -exit

# TODO newer BMP2Tile can compress better and directly to the targeted compression format.
new_graphics\title.bin new_graphics\title-nt.bin new_graphics\title-pal.bin: new_graphics\titlescreen.png
	new_graphics\bmp2tile.exe $** -4bit -savetilesbin new_graphics\title.bin -savetilemappscompr new_graphics\title-nt.bin -palsms -savepalettebin new_graphics\title-pal.bin -exit

# psg_encoder
# Encodes tile data to the "PS Gaiden" format - see above.
PSG_ENCODE = psg_encoder\psg_encoder.exe

$(PSG_ENCODE) : psg_encoder\*.cpp
  $(CPP) $(CPPFLAGS) psg_encoder\*.cpp /Fe:$(PSG_ENCODE)

psg_encoder\bg1.psgcompr   : $(PSG_ENCODE) psg_encoder\bg1.bin   ;$** $@
psg_encoder\bg2.psgcompr   : $(PSG_ENCODE) psg_encoder\bg2.bin   ;$** $@
psg_encoder\bg3.psgcompr   : $(PSG_ENCODE) psg_encoder\bg3.bin   ;$** $@
psg_encoder\bg5.psgcompr   : $(PSG_ENCODE) psg_encoder\bg5.bin   ;$** $@
psg_encoder\bg8.psgcompr   : $(PSG_ENCODE) psg_encoder\bg8.bin   ;$** $@
psg_encoder\bg9.psgcompr   : $(PSG_ENCODE) psg_encoder\bg9.bin   ;$** $@
psg_encoder\bg10.psgcompr  : $(PSG_ENCODE) psg_encoder\bg10.bin  ;$** $@
psg_encoder\bg11.psgcompr  : $(PSG_ENCODE) psg_encoder\bg11.bin  ;$** $@
psg_encoder\bg13.psgcompr  : $(PSG_ENCODE) psg_encoder\bg13.bin  ;$** $@
psg_encoder\bg14.psgcompr  : $(PSG_ENCODE) psg_encoder\bg14.bin  ;$** $@
psg_encoder\bg16.psgcompr  : $(PSG_ENCODE) psg_encoder\bg16.bin  ;$** $@
psg_encoder\bg29.psgcompr  : $(PSG_ENCODE) psg_encoder\bg29.bin  ;$** $@
psg_encoder\bg30.psgcompr  : $(PSG_ENCODE) psg_encoder\bg30.bin  ;$** $@
psg_encoder\bg31.psgcompr  : $(PSG_ENCODE) psg_encoder\bg31.bin  ;$** $@
psg_encoder\title.psgcompr : $(PSG_ENCODE) new_graphics\title.bin ;$** $@
psg_encoder\world1.psgcompr: $(PSG_ENCODE) psg_encoder\world1.bin;$** $@
psg_encoder\world2.psgcompr: $(PSG_ENCODE) psg_encoder\world2.bin;$** $@
psg_encoder\font1.psgcompr : $(PSG_ENCODE) new_graphics\font1.bin ;$** $@
psg_encoder\font2.psgcompr : $(PSG_ENCODE) new_graphics\font2.bin ;$** $@
psg_encoder\font3.psgcompr : $(PSG_ENCODE) new_graphics\font3.bin ;$** $@

# menu_creater

menu_creater\menu_creater.exe: menu_creater\*.cpp
  $(CPP) $(CPPFLAGS) menu_creater\*.cpp /Fe:menu_creater\menu_creater.exe

menu_creater\opening.asm : menu_creater\opening.txt menu_creater\tech1_table.tbl menu_creater\menu_creater.exe
	menu_creater\menu_creater.exe menu_creater\opening.txt menu_creater\tech1_table.tbl menu_creater\opening.asm

menu_creater\menus.asm : menu_creater\menus.txt menu_creater\tech1_table.tbl menu_creater\menu_creater.exe
	menu_creater\menu_creater.exe menu_creater\menus.txt menu_creater\tech1_table.tbl menu_creater\menus.asm

# script_inserter

script_inserter\script_inserter.exe: script_inserter\*.cpp
  $(CPP) $(CPPFLAGS) script_inserter\*.cpp /Fe:script_inserter\script_inserter.exe

script_inserter\table_temp.tbl: script_inserter\tech1_table.tbl substring_formatter\words.tbl
	copy script_inserter\tech1_table.tbl + substring_formatter\words.tbl script_inserter\table_temp.tbl

script_inserter\script1.bin script_inserter\tree_vector.bin script_inserter\script_trees.bin script_inserter\script_list.txt: script_inserter\table_temp.tbl script_inserter\script_inserter.exe word_count\script1.txt word_count\script2.txt
	cd script_inserter
  copy /y ..\word_count\script?.txt .
	script_inserter.exe script table_temp.tbl > log.txt
	del pass1.bin
	cd ..

# credits
credits\credits_encode.exe: credits\*.cpp
  $(CPP) $(CPPFLAGS) credits\*.cpp /Fe:credits\credits_encode.exe

credits\credits.bin: credits\credits.txt credits\credits_encode.exe
	credits\credits_encode.exe credits\credits.txt credits\credits.bin

# All files needed for the final ROM
BINS = psg_encoder\bg1.psgcompr  psg_encoder\bg2.psgcompr  psg_encoder\bg3.psgcompr  psg_encoder\bg5.psgcompr \
       psg_encoder\bg8.psgcompr  psg_encoder\bg9.psgcompr  psg_encoder\bg10.psgcompr psg_encoder\bg11.psgcompr \
       psg_encoder\bg13.psgcompr psg_encoder\bg14.psgcompr psg_encoder\bg16.psgcompr psg_encoder\bg29.psgcompr \
       psg_encoder\bg30.psgcompr psg_encoder\bg31.psgcompr \
       psg_encoder\world1.psgcompr psg_encoder\world2.psgcompr \
       psg_encoder\font1.psgcompr psg_encoder\font2.psgcompr psg_encoder\font3.psgcompr \
       psg_encoder\title.psgcompr new_graphics\title.bin new_graphics\title-nt.bin new_graphics\title-pal.bin \
       script_inserter\script_trees.bin \
       script_inserter\tree_vector.bin \
       credits\credits.bin

# ROM building
ps1jert.sms: $(PSJ) menu_creater\menus.asm menu_creater\opening.asm substring_formatter\words.asm $(BINS) ps1jert.sms.asm
  $(WLAZ80) -o "ps1jert.sms.o" "ps1jert.sms.asm"
  $(WLALINK) -d -r -v -S -A linkfile "ps1jert.sms"

	@echo Successful: translated file is ps1jert.sms
  fc /b ps1jert.sms ps1jert.102.sms | more

CLEANFILES = $(BINS) \
	     menu_creater\*.asm \
       script_inserter\script1.bin \
	     script_inserter\script_list.txt \
       script_inserter\script_trees.bin \
       script_inserter\tree_vector.bin \
	     script_inserter\log.txt \
       script_inserter\script*.txt \
       script_inserter\table_temp.tbl \
	     substring_formatter\words.tbl substring_formatter\words.asm \
	     word_count\stats.txt word_count\words.txt \
       word_count\word_count.exe \
       substring_formatter\substringformatter.exe \
       bitmap_decode\bitmap_decode.exe \
       psg_encoder\psg_encoder.exe \
       menu_creater\menu_creater.exe \
       script_inserter\script_inserter.exe \
       credits\credits_encode.exe

clean:
	del $(CLEANFILES)
