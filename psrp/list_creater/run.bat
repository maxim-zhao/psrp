"Release/list_creater" lists.txt tech1_table.tbl > log.txt
copy pass1.bin "..\rom_insert\lists.bin"

"Release/list_creater" dict.txt tech1_table.tbl > log2.txt
copy pass1.bin "..\rom_insert\words.bin"

del pass1.bin