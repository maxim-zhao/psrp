/*
Phantasy Star: Symbol Converter
*/

#include <cstdio>

#include <string>
#include <vector>
#include <fstream>
#include <iomanip>
#include <locale>
#include <codecvt>
#include <map>

namespace
{
    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;
}

class File
{
    std::ifstream _f;
    unsigned int _lineNumber;
public:
    explicit File(const std::string& name): _f(name), _lineNumber(0)
    {
        // Check for a BOM
        int bom = 0;
        _f.read(reinterpret_cast<char *>(&bom), 3);
        if (bom != 0xbfbbef)
        {
            // Not found -> rewind
            _f.seekg(0);
        }
    }
    bool getLine(std::string& s)
    {
        for (;;)
        {
            getline(_f, s);
            if (_f.fail())
            {
                return false;
            }
            ++_lineNumber;
            // Remove comments
            const auto pos = s.find(';');
            if (pos != std::string::npos)
            {
                s.erase(pos);
            }
            // Discard empty lines
            if (s.empty())
            {
                continue;
            }
            return true;
        }
    }
    unsigned int lineNumber() { return _lineNumber; }
};

class Table
{
    std::map<wchar_t, int> _table;

public:
    Table(const std::string& fileName)
    {
        File f(fileName);

        for (std::string s; f.getLine(s);)
        {
            // Remove comments
            const auto pos = s.find(';');
            if (pos != std::string::npos)
            {
                s.erase(pos);
            }
            // Discard empty lines
            if (s.empty())
            {
                continue;
            }
            // Find the "="
            const auto equalsPos = s.find('=');
            if (equalsPos == std::string::npos)
            {
                printf("Warning: unexpected table line \"%s\"\n", s.c_str());
                continue;
            }
            // Parse the bits
            const auto& l = s.substr(0, equalsPos);
            const auto& r = s.substr(equalsPos + 1);
            // l is little-endian hex...
            int value = std::stoi(l, nullptr, 16);
            if (l.length() == 4)
            {
                // swap bytes
                value = (value & 0xff) << 8 | (value >> 8);
            }
            // r is possibly UTF-8...
            std::wstring dest = convert.from_bytes(r.c_str());
            _table[dest[0]] = value;
        }
    }

    int find(wchar_t value)
    {
        const auto it = _table.find(value);
        if (it == _table.end())
        {
            return -1;
        }
        return it->second;
    }
};

FILE *pass1;

void Process_Text(File& f, Table& t)
{
    // Init table entries
    int tableNumber = 1;
    int tableOffset = 0;
    int tableLength = 0;
    printf("\n");
    printf("Table location data\n");

    std::ofstream definitions("definitions.asm");
    std::vector<std::string> names
    {
        "CLASS",
        "ITEMS",
        "NAMES",
        "ENEMY",
        "_END"
    };

    // Read in dictionary entries
    for (std::string s; f.getLine(s);)
    {
        // check for new table altogether
        if (s.length() == 1 && s[0] == '#')
        {
            // log statistics
            printf("(line %d) Table %02X: Start $%04X, Length $%04X",
                   f.lineNumber(), tableNumber, tableOffset - tableLength, tableLength);

            definitions << ".define " << names[tableNumber] << "_OFFSET $" << std::setbase(16) << tableOffset - tableLength << "\n";
            definitions << ".define " << names[tableNumber] << "_SIZE $" << std::setbase(16) << tableLength << "\n";

            printf("\n");

            // re-init
            tableNumber++;
            tableLength = 0;
            continue;
        }

        std::vector<uint8_t> buffer;

        // do the conversion
        for (auto&& c : s)
        {
            // grab symbol
            const auto value = t.find(c);
            if (value == -1)
            {
                continue;
            }

            // Emit to buffer
            buffer.push_back((uint8_t)value);
        }

        // commit changes: length + text
        fputc(buffer.size(), pass1);
        fwrite(&buffer[0], 1, buffer.size(), pass1);

        tableOffset += buffer.size() + 1;
        tableLength += buffer.size() + 1;
    }

    // custom stop marker
    printf("\n");
    fputc(0xdf, pass1); // Magic number
}

int Convert_Symbols(const char* list_name, const char* table_name, const char* out_name)
{
    // Open files
    pass1 = fopen(out_name, "wb");

    // Check for file errors
    if (!pass1)
    {
        printf("Error: Could not create file \"%s\"\n", out_name);
        return -1;
    }

    //Load_Tables(0);
    Table t(table_name);
    File f(list_name);
    Process_Text(f, t);

    // Done processing
    fclose(pass1);

    return 0;
}

