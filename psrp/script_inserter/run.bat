copy tech1_table.tbl+words_final.txt table_temp.tbl
copy table_temp.tbl

"Release/script_inserter" script table_temp.tbl > log.txt

copy script1.bin "../rom_insert"
copy script2.bin "../rom_insert"
copy tree_vector.bin "../rom_insert"
copy script_trees.bin "../rom_insert"
copy script_list.txt "../rom_insert"

del pass1.bin
del table_temp.tbl