#
# Phantasy Star retranslation makefile
#

# The emulator for testing
EMU = "D:\My Documents\SMS\meka\mekaw.exe"

# Assembler (TASM)
ASM = tasm.exe -80 -b

# The original PSJ ROM
PSJ = ps1-j.sms

DUMMY: ps1jert.sms

PLAY: ps1jert.sms
	$(EMU) ps1jert.sms

# word_count
script_inserter\script1.txt script_inserter\script2.txt substring_formatter\words.txt : word_count\script1.txt word_count\script2.txt
	cd word_count
	copy script1.txt + script2.txt script.txt
	"Release\word_count" < script.txt > stats.txt
	copy script1.txt "..\script_inserter"
	copy script2.txt "..\script_inserter"
	copy words.txt "..\substring_formatter"
	del script.txt
	cd ..

# substring_formatter
script_inserter\words_final.txt list_creater\dict.txt : substring_formatter\words.txt
	cd substring_formatter
	"Release\substring_formatter" 0x80 > log.txt
	copy words_final.txt "..\script_inserter"
	copy dict.txt "..\list_creater"
	cd ..

# list_creater
rom_insert\lists.bin : list_creater\lists.txt list_creater\dict.txt list_creater\tech1_table.tbl
	cd list_creater
	"Release\list_creater" lists.txt tech1_table.tbl > log.txt
	move pass1.bin "..\rom_insert\lists.bin"
	cd ..

rom_insert\words.bin : list_creater\lists.txt list_creater\dict.txt list_creater\tech1_table.tbl
	cd list_creater
	"Release\list_creater" dict.txt tech1_table.tbl > log2.txt
	move pass1.bin "..\rom_insert\words.bin"
	cd ..

# asm
asm\t*.asm: asm\vars.asm

{asm}.asm{rom_insert}.obj:
	cd asm
	$(ASM) $(?F)
	copy $(@F) ..\rom_insert
	cd ..

# bitmap_decode
BITMAP_DECODE = bitmap_decode\Release\bitmap_decode.exe
psg_encoder\bg1.bin   : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 40020 $@
psg_encoder\bg2.bin   : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 40f36 $@
psg_encoder\bg3.bin   : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 41c82 $@
psg_encoder\bg5.bin   : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 43406 $@
psg_encoder\bg8.bin   : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 44650 $@
psg_encoder\bg9.bin   : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 457d4 $@
psg_encoder\bg10.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 464c1 $@
psg_encoder\bg11.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 46f68 $@
psg_encoder\bg13.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 5ac8d $@
psg_encoder\bg14.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 2c010 $@
psg_encoder\bg16.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 5eb6f $@
psg_encoder\bg29.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 27b24 $@
psg_encoder\bg30.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 524ea $@
psg_encoder\bg31.bin  : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 4c010 $@
#psg_encoder\title.bin : $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 7e8bd $@
psg_encoder\world1.bin: $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 747b8 $@
psg_encoder\world2.bin: $(PSJ) ;$(BITMAP_DECODE) $(PSJ) 58570 $@


# tile conversion from PNG
psg_encoder\font1.bin: new_graphics\font1.png
	new_graphics\bmp2tile.exe $? -4bit -noremovedupes -savetilesbin $@ -exit

psg_encoder\font2.bin: new_graphics\font2.png
	new_graphics\bmp2tile.exe $? -4bit -noremovedupes -savetilesbin $@ -exit

psg_encoder\font3.bin: new_graphics\font3.png
	new_graphics\bmp2tile.exe $? -4bit -noremovedupes -savetilesbin $@ -exit

psg_encoder\title.bin rom_insert\title-nt.bin rom_insert\title-pal.bin: new_graphics\titlescreen.png
	new_graphics\bmp2tile.exe $? -4bit -savetilesbin psg_encoder\title.bin -savetilemappscompr rom_insert\title-nt.bin -palsms -savepalettebin rom_insert\title-pal.bin -exit

# psg_encoder
PSG_ENCODE = psg_encoder\Release\psg_encoder.exe
rom_insert\bg1_e.bin   : psg_encoder\bg1.bin   ;$(PSG_ENCODE) $? $@
rom_insert\bg2_e.bin   : psg_encoder\bg2.bin   ;$(PSG_ENCODE) $? $@
rom_insert\bg3_e.bin   : psg_encoder\bg3.bin   ;$(PSG_ENCODE) $? $@
rom_insert\bg5_e.bin   : psg_encoder\bg5.bin   ;$(PSG_ENCODE) $? $@
rom_insert\bg8_e.bin   : psg_encoder\bg8.bin   ;$(PSG_ENCODE) $? $@
rom_insert\bg9_e.bin   : psg_encoder\bg9.bin   ;$(PSG_ENCODE) $? $@
rom_insert\bg10_e.bin  : psg_encoder\bg10.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg11_e.bin  : psg_encoder\bg11.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg13_e.bin  : psg_encoder\bg13.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg14_e.bin  : psg_encoder\bg14.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg16_e.bin  : psg_encoder\bg16.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg29_e.bin  : psg_encoder\bg29.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg30_e.bin  : psg_encoder\bg30.bin  ;$(PSG_ENCODE) $? $@
rom_insert\bg31_e.bin  : psg_encoder\bg31.bin  ;$(PSG_ENCODE) $? $@
rom_insert\title_e.bin : psg_encoder\title.bin ;$(PSG_ENCODE) $? $@
rom_insert\world1_e.bin: psg_encoder\world1.bin;$(PSG_ENCODE) $? $@
rom_insert\world2_e.bin: psg_encoder\world2.bin;$(PSG_ENCODE) $? $@
rom_insert\font1_e.bin : psg_encoder\font1.bin ;$(PSG_ENCODE) $? $@
rom_insert\font2_e.bin : psg_encoder\font2.bin ;$(PSG_ENCODE) $? $@
rom_insert\font3_e.bin : psg_encoder\font3.bin ;$(PSG_ENCODE) $? $@

# menu_creater
rom_insert\opening.bin : menu_creater\opening.txt menu_creater\tech1_table.tbl
	menu_creater\Release\menu_creater.exe menu_creater\opening.txt menu_creater\tech1_table.tbl
	move pass1.bin rom_insert\opening.bin
	del menu_list.txt

rom_insert\menus.bin rom_insert\menu_list.txt : menu_creater\menus.txt menu_creater\tech1_table.tbl
	menu_creater\Release\menu_creater.exe menu_creater\menus.txt menu_creater\tech1_table.tbl > menu_creater\log.txt
	move pass1.bin rom_insert\menus.bin
	move menu_list.txt rom_insert\menu_list.txt

# script_inserter
script_inserter\table_temp.tbl: script_inserter\tech1_table.tbl script_inserter\words_final.txt
	copy script_inserter\tech1_table.tbl + script_inserter\words_final.txt script_inserter\table_temp.tbl

rom_insert\script?.bin rom_insert\tree_vector.bin rom_insert\script_trees.bin rom_insert\script_list.txt : script_inserter\table_temp.tbl
	cd script_inserter
	Release\script_inserter.exe script table_temp.tbl > log.txt
	for %f in (script?.bin) do @move "%f" "..\rom_insert"
	move tree_vector.bin "..\rom_insert"
	move script_trees.bin "..\rom_insert"
	move script_list.txt "..\rom_insert"
	del pass1.bin
	cd ..

# credits
rom_insert\credits.bin: credits\credits.txt
	credits\credits_encode.exe credits\credits.txt rom_insert\credits.bin

# hand-made bins
rom_insert\font-nt.bin     : handmade_bins\font-nt.bin     ;copy $? $@
rom_insert\bg_table1.bin   : handmade_bins\bg_table1.bin   ;copy $? $@
rom_insert\bg_table8.bin   : handmade_bins\bg_table8.bin   ;copy $? $@
rom_insert\bg_vector.bin   : handmade_bins\bg_vector.bin   ;copy $? $@
rom_insert\stats_1.bin     : handmade_bins\stats_1.bin     ;copy $? $@
rom_insert\stats_2.bin     : handmade_bins\stats_2.bin     ;copy $? $@
rom_insert\save_tiles.bin  : handmade_bins\save_tiles.bin  ;copy $? $@
rom_insert\save_text.bin   : handmade_bins\save_text.bin   ;copy $? $@
rom_insert\save_lookup.bin : handmade_bins\save_lookup.bin ;copy $? $@
rom_insert\tiles-tarzimal.bin : handmade_bins\tiles-tarzimal.bin ;copy $? $@

# All files needed for the final ROM
BINS = rom_insert\bg1_e.bin  rom_insert\bg2_e.bin  rom_insert\bg3_e.bin  rom_insert\bg5_e.bin \
       rom_insert\bg8_e.bin  rom_insert\bg9_e.bin  rom_insert\bg10_e.bin rom_insert\bg11_e.bin \
       rom_insert\bg13_e.bin rom_insert\bg14_e.bin rom_insert\bg16_e.bin rom_insert\bg29_e.bin \
       rom_insert\bg30_e.bin rom_insert\bg31_e.bin \
       rom_insert\world1_e.bin rom_insert\world2_e.bin \
       rom_insert\font1_e.bin rom_insert\font2_e.bin rom_insert\font3_e.bin rom_insert\font-nt.bin \
       rom_insert\title_e.bin rom_insert\title-nt.bin rom_insert\title-pal.bin \
       rom_insert\bg_table1.bin rom_insert\bg_table8.bin \
       rom_insert\bg_vector.bin \
       rom_insert\script_trees.bin \
       rom_insert\tree_vector.bin \
       rom_insert\words.bin \
       rom_insert\stats_1.bin \
       rom_insert\stats_2.bin \
       rom_insert\lists.bin \
       rom_insert\menus.bin \
       rom_insert\opening.bin \
       rom_insert\t0b.obj rom_insert\t0d.obj \
       rom_insert\t1b.obj \
       rom_insert\t1c.obj rom_insert\t1c_1.obj rom_insert\t1c_2.obj rom_insert\t1c_3.obj \
       rom_insert\t2a.obj rom_insert\t2a_1.obj rom_insert\t2a_2.obj rom_insert\t2a_3.obj rom_insert\t2a_4.obj \
       rom_insert\t2b.obj rom_insert\t2b_1.obj rom_insert\t2b_2.obj rom_insert\t2b_3.obj \
       rom_insert\t4a.obj rom_insert\t4a_1.obj rom_insert\t4a_1.obj rom_insert\t4a_2.obj rom_insert\t4a_3.obj rom_insert\t4a_4.obj \
       rom_insert\t4b.obj rom_insert\t4b_1.obj \
       rom_insert\t5.obj \
       rom_insert\tx1.obj rom_insert\tx2.obj rom_insert\tx3.obj rom_insert\tx4.obj \
       rom_insert\save_tiles.bin rom_insert\save_text.bin rom_insert\save_lookup.bin \
       rom_insert\tiles-tarzimal.bin \
       rom_insert\credits.bin \

# rom_insert
ps1jert.sms: $(PSJ) rom_insert\list.txt rom_insert\script_list.txt rom_insert\menu_list.txt $(BINS)
	copy $(PSJ) rom_insert\ps1jert.sms
	cd rom_insert
	Release\rom_insert.exe ps1jert.sms list.txt
	Release\rom_insert.exe ps1jert.sms script_list.txt
	Release\rom_insert.exe ps1jert.sms menu_list.txt
	move ps1jert.sms ..
	cd ..
	@echo Successful: translated file is ps1jert.sms

CLEANFILES = asm\*.lst asm\*.obj \
	     list_creater\log*.txt list_creater\dict.txt \
	     menu_creater\log.txt \
	     psg_encoder\bg*.bin psg_encoder\title.bin psg_encoder\world*.bin psg_encoder\font1.bin psg_encoder\font2.bin psg_encoder\font3.bin\
	     rom_insert\*_e.bin rom_insert\lists.bin rom_insert\log.txt rom_insert\menu_list.txt \
	     rom_insert\menus.bin rom_insert\opening.bin rom_insert\script1.bin \
	     rom_insert\script_list.txt rom_insert\script_trees.bin rom_insert\*.obj rom_insert\tree_vector.bin \
	     rom_insert\words.bin rom_insert\title-nt.bin rom_insert\title-pal.bin\
	     script_inserter\log.txt script_inserter\script*.txt script_inserter\table_temp.tbl script_inserter\words_final.txt \
	     substring_formatter\dict.txt substring_formatter\log.txt substring_formatter\words.txt substring_formatter\words_final.txt \
	     word_count\stats.txt word_count\words.txt

clean:
	del $(CLEANFILES)
	del $(BINS)
