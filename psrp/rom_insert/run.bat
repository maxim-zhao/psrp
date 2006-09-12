copy "copy of psjapa.sms" psjapa.sms

"Release/rom_insert" psjapa.sms list.txt > log.txt
"Release/rom_insert" psjapa.sms script_list.txt > log.txt
"Release/rom_insert" psjapa.sms menu_list.txt > log.txt

copy psjapa.sms "sms plus\sms_sdl-0.9.4a-r7.1-win32\psjapa.sms"