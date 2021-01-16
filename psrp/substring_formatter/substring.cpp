/*
Phantasy Star: Substring Table Creater
*/

#include <cstdio>

#include <string>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <locale>
#include <codecvt>
#include <algorithm>

constexpr auto start_code = 0x6c; // see WordListStart in asm

int main(int argc, char** argv)
{
    if (argc < 5)
    {
        printf("Usage: substring_formatter.exe <# codes> <word list> <output table file> <output asm>\n");
        return 0;
    }

    const int numWords = std::stoi(argv[1]);
    
    // open files
    std::ifstream words(argv[2]);
    std::ofstream table(argv[3]);
    std::ofstream dict(argv[4]);

    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;

    // read each string and add conversion code
    int code = start_code;
    for (std::string s; std::getline(words, s);)
    {
        if (code > 0xff)
        {
            std::cerr << "Word list too large!\n";
            return -1;
        }
        
        // Emit to TBL file (as UTF-8)
        table << std::setbase(16) << code << "=" << s << "\n";

        // Emit as source - WLA DX can't do UTF-8 :( so we convert ’ to '
        std::wstring line = convert.from_bytes(s.c_str());
        std::replace(line.begin(), line.end(), L'\x2019', L'\'');
        dict << "  String \"" << convert.to_bytes(line) << "\"\n";

        // bump substring assignment range
        ++code;
        
        if (code == start_code + numWords) 
        {
            break;
        }
    }
    
    std::cout << "Word list contains " << code - start_code << " words\n";

    return 0;
}
