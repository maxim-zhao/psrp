bmp2tile.exe font1.png -4bit -noremovedupes -savetilesbin font1.bin -exit
bmp2tile.exe font2.png -4bit -noremovedupes -savetilesbin font2.bin -exit
copy *.bin ..\psg_encoder
