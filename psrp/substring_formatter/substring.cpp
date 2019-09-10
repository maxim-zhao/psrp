/*
Phantasy Star: Substring Table Creater
*/

#include <cstdio>

#include <deque>
#include <string>
#include <fstream>
#include <iomanip>

constexpr auto start_code = 0x60;

constexpr auto switch_code = 0xFFFF;
constexpr auto start_code2 = 0xFFFF;

int main(int argc, char** argv)
{
    if (argc < 2)
    {
        printf("Usage: substring_formatter.exe <# codes>\n");
        return 0;
    }

    const int numWords = std::stoi(argv[1], nullptr, 16);

    // open files
    std::ifstream words("words.txt");
    std::ofstream table("words_final.txt");
    std::ofstream dict("dict.txt");

    // read each string and add conversion code
    int code = start_code;
    std::deque<std::string> list;
    for (std::string s; std::getline(words, s);)
    {
        // dictionary word
        dict << "  String \"" << s << "\"\n";

        // print <string>
        table << std::setbase(16) << code << "=" << s << "\n";

        // queue up
        list.emplace_back(s);

        // bump substring assignment range
        code++;

        if (code == switch_code) code = start_code2;
        if (code == start_code + numWords) break;
    }

    return 0;
}
