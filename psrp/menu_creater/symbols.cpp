/*
Phantasy Star: Symbol Converter
*/

#ifdef _DEBUG
#pragma warning( disable: 4786 )	// 255 character debug limit
#endif

#include <cstdio>

#include <string>
#include <utility>
#include <vector>
#include <sstream>
#include <map>
#include <locale>
#include <codecvt>
#include <algorithm>
#include <fstream>

namespace
{
    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;
}

class File
{
    std::ifstream _f;
public:
    explicit File(const std::string& name): _f(name)
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
};

class Table
{
    std::map<char16_t, int> _table;

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

    int find(char16_t value)
    {
        const auto it = _table.find(value);
        if (it == _table.end())
        {
            return 0;
        }
        return it->second;
    }
};

class Menu
{
    std::vector<std::wstring> _lines;
    std::vector<int> _ptrs;
    std::vector<int> _dims;
    std::string _name;
    unsigned int _width;
    unsigned int _height;
    bool _emitData;

public:
    explicit Menu(std::string name): _name(std::move(name)), _width(0), _height(0), _emitData(true)
    {
    }

    void addLine(const std::string& line)
    {
        // Check if it's a name=value
        if (line.substr(0, 5) == "ptrs=")
        {
            // Split value
            std::stringstream ss(line.substr(5));
            std::string item;
            while (std::getline(ss, item, ','))
            {
                _ptrs.push_back(std::stoi(item, nullptr, 16));
            }
        }
        else if (line.substr(0, 5) == "dims=")
        {
            // Split value
            std::stringstream ss(line.substr(5));
            std::string item;
            while (std::getline(ss, item, ','))
            {
                _dims.push_back(std::stoi(item, nullptr, 16));
            }
        }
        else if (line.substr(0, 6) == "width=")
        {
            _width = std::max(_width, (unsigned int)std::stoi(line.substr(6)));
        }
        else if (line.substr(0, 7) == "height=")
        {
            _height = std::max(_height, (unsigned int)std::stoi(line.substr(7)));
        }
        else if (line == "dimensions only")
        {
            _emitData = false;
        }
        else
        {
            const auto&& line16 = convert.from_bytes(line.c_str());
            _lines.push_back(line16);
            _width = std::max(_width, line16.length());
            _height = std::max(_height, _lines.size());
        }
    }

    void writePatches(FILE* f)
    {
        for (auto&& line : _lines)
        {
            if (line.length() != _width)
            {
                printf("Warning: uneven line lengths in menu %s\n", _name.c_str());
                break;
            }
        }

        fprintf(f, "; %s patches\n", _name.c_str());

        for (auto&& ptr: _ptrs)
        {
            fprintf(f, "  PatchW $%x %s\n", ptr, _name.c_str());
        }

        for (auto&& ptr: _dims)
        {
            fprintf(f, "  PatchB $%x %d\n", ptr, _width * 2);
            fprintf(f, "  PatchB $%x %d\n", ptr+1, _height);
        }
    }

    void writeData(FILE* f, Table& table)
    {
        if (!_emitData)
        {
            // No data
            return;
        }

        // Emit the data at the current (unknown) address
        fprintf(f, "%s:", _name.c_str());

        for (auto&& line : _lines)
        {
            fprintf(f, "\n.dw");
            for (auto&& c : line)
            {
                const auto& value = table.find(c);
                if (value == 0)
                {
                    // skip unknown chars
                    continue;
                }
                fprintf(f, " $%04x", value); // menu value
            }

            fprintf(f, " ; %s", convert.to_bytes(line).c_str());
        }

        fprintf(f, "\n\n"); // Add some space
    }
};

void ProcessText(const std::string& listName, const std::string& tableFile, const std::string& outName)
{
    FILE* out = fopen(outName.c_str(), "w");

    Table table(tableFile);

    // Read the menu data
    std::vector<Menu*> menus;
    Menu* pCurrentItem = nullptr;

    File f(listName);

    for (std::string s; f.getLine(s);)
    {
        if (s.at(0) == '[')
        {
            // finish current item
            if (pCurrentItem != nullptr)
            {
                menus.push_back(pCurrentItem);
            }
            pCurrentItem = new Menu(s.substr(1, s.length() - 2));
            continue;
        }
        // else add to current
        pCurrentItem->addLine(s);
    }
    // Add last item
    if (pCurrentItem != nullptr)
    {
        menus.push_back(pCurrentItem);
    }

    // Emit
    for (auto&& menu: menus)
    {
        menu->writeData(out, table);
    }
    fprintf(out, ".ends\n");
    for (auto&& menu: menus)
    {
        menu->writePatches(out);
    }

    fclose(out);
}

void ConvertSymbols(const char* listName, const char* tableName, const char* outName)
{
    ProcessText(listName, tableName, outName);
}
