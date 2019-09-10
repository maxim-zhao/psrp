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
word_count\word_count.exe : word_count\*.cpp
  $(CPP) $(CPPFLAGS) word_count\*.cpp /Fe:word_count\word_count.exe

script_inserter\script1.txt script_inserter\script2.txt word_count\words.txt : word_count\script1.txt word_count\script2.txt word_count\word_count.exe
	cd word_count
	copy script1.txt + script2.txt script.txt
	word_count.exe < script.txt > stats.txt
	copy script1.txt "..\script_inserter"
	copy script2.txt "..\script_inserter"
	del script.txt
	cd ..

# substring_formatter
substring_formatter\substring_formatter.exe : substring_formatter\*.cpp
  $(CPP) $(CPPFLAGS) substring_formatter\*.cpp /Fe:substring_formatter\substring_formatter.exe

substring_formatter\words.tbl substring_formatter\words.asm: substring_formatter\substring_formatter.exe word_count\words.txt
	substring_formatter\substring_formatter.exe 0x80 word_count\words.txt substring_formatter\words.tbl substring_formatter\words.asm

# bitmap_decode
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
#psg_encoder\title.bin : $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 7e8bd $@
psg_encoder\world1.bin: $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 747b8 $@
psg_encoder\world2.bin: $(PSJ) $(BITMAP_DECODE) ;$(BITMAP_DECODE) $(PSJ) 58570 $@


# tile conversion from PNG
psg_encoder\font1.bin: new_graphics\font1.png
	new_graphics\bmp2tile.exe $** -4bit -noremovedupes -savetilesbin $@ -exit

psg_encoder\font2.bin: new_graphics\font2.png
	new_graphics\bmp2tile.exe $** -4bit -noremovedupes -savetilesbin $@ -exit

psg_encoder\font3.bin: new_graphics\font3.png
	new_graphics\bmp2tile.exe $** -4bit -noremovedupes -savetilesbin $@ -exit

psg_encoder\title.bin rom_insert\title-nt.bin rom_insert\title-pal.bin: new_graphics\titlescreen.png
	new_graphics\bmp2tile.exe $** -4bit -savetilesbin psg_encoder\title.bin -savetilemappscompr rom_insert\title-nt.bin -palsms -savepalettebin rom_insert\title-pal.bin -exit

# psg_encoder
PSG_ENCODE = psg_encoder\psg_encoder.exe

$(PSG_ENCODE) : psg_encoder\*.cpp
  $(CPP) $(CPPFLAGS) psg_encoder\*.cpp /Fe:$(PSG_ENCODE)

rom_insert\bg1_e.bin   : $(PSG_ENCODE) psg_encoder\bg1.bin   ;$** $@
rom_insert\bg2_e.bin   : $(PSG_ENCODE) psg_encoder\bg2.bin   ;$** $@
rom_insert\bg3_e.bin   : $(PSG_ENCODE) psg_encoder\bg3.bin   ;$** $@
rom_insert\bg5_e.bin   : $(PSG_ENCODE) psg_encoder\bg5.bin   ;$** $@
rom_insert\bg8_e.bin   : $(PSG_ENCODE) psg_encoder\bg8.bin   ;$** $@
rom_insert\bg9_e.bin   : $(PSG_ENCODE) psg_encoder\bg9.bin   ;$** $@
rom_insert\bg10_e.bin  : $(PSG_ENCODE) psg_encoder\bg10.bin  ;$** $@
rom_insert\bg11_e.bin  : $(PSG_ENCODE) psg_encoder\bg11.bin  ;$** $@
rom_insert\bg13_e.bin  : $(PSG_ENCODE) psg_encoder\bg13.bin  ;$** $@
rom_insert\bg14_e.bin  : $(PSG_ENCODE) psg_encoder\bg14.bin  ;$** $@
rom_insert\bg16_e.bin  : $(PSG_ENCODE) psg_encoder\bg16.bin  ;$** $@
rom_insert\bg29_e.bin  : $(PSG_ENCODE) psg_encoder\bg29.bin  ;$** $@
rom_insert\bg30_e.bin  : $(PSG_ENCODE) psg_encoder\bg30.bin  ;$** $@
rom_insert\bg31_e.bin  : $(PSG_ENCODE) psg_encoder\bg31.bin  ;$** $@
rom_insert\title_e.bin : $(PSG_ENCODE) psg_encoder\title.bin ;$** $@
rom_insert\world1_e.bin: $(PSG_ENCODE) psg_encoder\world1.bin;$** $@
rom_insert\world2_e.bin: $(PSG_ENCODE) psg_encoder\world2.bin;$** $@
rom_insert\font1_e.bin : $(PSG_ENCODE) psg_encoder\font1.bin ;$** $@
rom_insert\font2_e.bin : $(PSG_ENCODE) psg_encoder\font2.bin ;$** $@
rom_insert\font3_e.bin : $(PSG_ENCODE) psg_encoder\font3.bin ;$** $@

# menu_creater

menu_creater\menu_creater.exe: menu_creater\*.cpp
  $(CPP) $(CPPFLAGS) menu_creater\*.cpp /Fe:menu_creater\menu_creater.exe

rom_insert\opening.asm : menu_creater\opening.txt menu_creater\tech1_table.tbl menu_creater\menu_creater.exe
	menu_creater\menu_creater.exe menu_creater\opening.txt menu_creater\tech1_table.tbl rom_insert\opening.asm

rom_insert\menus.bin rom_insert\menu_list.asm : menu_creater\menus.txt menu_creater\tech1_table.tbl menu_creater\menu_creater.exe
	menu_creater\menu_creater.exe menu_creater\menus.txt menu_creater\tech1_table.tbl rom_insert\menu_list.asm

# script_inserter

script_inserter\script_inserter.exe: script_inserter\*.cpp
  $(CPP) $(CPPFLAGS) script_inserter\*.cpp /Fe:script_inserter\script_inserter.exe

script_inserter\table_temp.tbl: script_inserter\tech1_table.tbl substring_formatter\words.tbl
	copy script_inserter\tech1_table.tbl + substring_formatter\words.tbl script_inserter\table_temp.tbl

script_inserter\script1.bin script_inserter\tree_vector.bin script_inserter\script_trees.bin script_inserter\script_list.txt : script_inserter\table_temp.tbl script_inserter\script_inserter.exe
	cd script_inserter
	script_inserter.exe script table_temp.tbl > log.txt
	del pass1.bin
	cd ..

# credits
credits\credits_encode.exe: credits\*.cpp
  $(CPP) $(CPPFLAGS) credits\*.cpp /Fe:credits\credits_encode.exe

rom_insert\credits.bin: credits\credits.txt credits\credits_encode.exe
	credits\credits_encode.exe credits\credits.txt rom_insert\credits.bin

# All files needed for the final ROM
BINS = rom_insert\bg1_e.bin  rom_insert\bg2_e.bin  rom_insert\bg3_e.bin  rom_insert\bg5_e.bin \
       rom_insert\bg8_e.bin  rom_insert\bg9_e.bin  rom_insert\bg10_e.bin rom_insert\bg11_e.bin \
       rom_insert\bg13_e.bin rom_insert\bg14_e.bin rom_insert\bg16_e.bin rom_insert\bg29_e.bin \
       rom_insert\bg30_e.bin rom_insert\bg31_e.bin \
       rom_insert\world1_e.bin rom_insert\world2_e.bin \
       rom_insert\font1_e.bin rom_insert\font2_e.bin rom_insert\font3_e.bin \
       rom_insert\title_e.bin rom_insert\title-nt.bin rom_insert\title-pal.bin \
       script_inserter\script_trees.bin \
       script_inserter\tree_vector.bin \
       rom_insert\credits.bin

# rom_insert
ps1jert.sms: $(PSJ) rom_insert\menu_list.asm rom_insert\opening.asm $(BINS) ps1jert.sms.asm
  $(WLAZ80) -o "ps1jert.sms.o" "ps1jert.sms.asm"
  $(WLALINK) -d -r -v -S -A linkfile "ps1jert.sms"

	@echo Successful: translated file is ps1jert.sms

CLEANFILES = \
	     psg_encoder\bg*.bin psg_encoder\title.bin psg_encoder\world*.bin psg_encoder\font1.bin psg_encoder\font2.bin psg_encoder\font3.bin\
	     rom_insert\*_e.bin rom_insert\log.txt rom_insert\menu_list.asm \
	     rom_insert\menus.bin rom_insert\opening.asm script_inserter\script1.bin \
	     script_inserter\script_list.txt script_inserter\script_trees.bin script_inserter\tree_vector.bin \
	     rom_insert\title-nt.bin rom_insert\title-pal.bin\
	     script_inserter\log.txt script_inserter\script*.txt script_inserter\table_temp.tbl \
	     substring_formatter\words.tbl substring_formatter\words.asm \
	     word_count\stats.txt word_count\words.txt \
       word_count\word_count.exe \
       substring_formatter\substring.exe \
       bitmap_decode\bitmap_decode.exe \
       psg_encoder\psg_encoder.exe \
       menu_creater\menu_creater.exe \
       script_inserter\script_inserter.exe \
       credits\credits_encode.exe

clean:
	del $(CLEANFILES)
	del $(BINS)
