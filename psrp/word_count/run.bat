REM word_count < word_count.c > log.txt
copy script1.txt + script2.txt script.txt
"Release/word_count" < script.txt > stats.txt

copy script1.txt "../script_inserter"
copy script2.txt "../script_inserter"

copy words.txt "../substring_formatter"

del script.txt