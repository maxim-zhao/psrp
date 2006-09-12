"Release/menu_creater" opening.txt tech1_table.tbl > log.txt
copy pass1.bin "..\rom_insert\opening.bin"

"Release/menu_creater" menus.txt tech1_table.tbl > log.txt
copy pass1.bin "..\rom_insert\menus.bin"
copy "menu_list.txt" "..\rom_insert\menu_list.txt"

del pass1.bin