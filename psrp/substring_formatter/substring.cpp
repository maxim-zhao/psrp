/*
Phantasy Star: Substring Table Creater
*/

#include <cstdio>

#include <deque>
#include <string>
#include <fstream>
#include <iomanip>
#include <iostream>

constexpr auto start_code = 0x5c; // see WordListStart in asm

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

    // read each string and add conversion code
    int code = start_code;
    std::deque<std::string> list;
    for (std::string s; std::getline(words, s);)
    {
        if (code > 0xff)
        {
            std::cerr << "Word list too large!\n";
            return -1;
        }

        // dictionary word
        dict << "  String \"" << s << "\"\n";

        // print <string>
        table << std::setbase(16) << code << "=" << s << "\n";

        // queue up
        list.emplace_back(s);

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
