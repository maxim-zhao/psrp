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
#include <iomanip>

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
    std::map<wchar_t, int> _table;

public:
    explicit Table(const std::string& fileName)
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
            // We assume we only want the first char
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

class Menu
{
    std::vector<std::wstring> _lines;
    std::vector<int> _ptrs;
    std::vector<int> _dims;
    std::string _name;
    std::size_t _width;
    std::size_t _height;
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
            _width = std::max(_width, (std::size_t)std::stoi(line.substr(6)));
        }
        else if (line.substr(0, 7) == "height=")
        {
            _height = std::max(_height, (std::size_t)std::stoi(line.substr(7)));
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

    void writePatches(std::ofstream& f)
    {
        for (auto&& line : _lines)
        {
            if (line.length() != _width)
            {
                printf("Warning: uneven line lengths in menu %s\n", _name.c_str());
                break;
            }
        }

        f << "; " << _name << " patches\n" << std::hex;

        for (auto&& ptr: _ptrs)
        {
            f << "  PatchW $" << ptr << ' ' << _name << '\n';
        }

        for (auto&& ptr: _dims)
        {
            f << "  PatchB $" << std::hex << ptr     << ' ' << std::dec << _width * 2 << '\n'
              << "  PatchB $" << std::hex << ptr + 1 << ' ' << std::dec << _height    << '\n';
        }
    }

    void writeData(std::ofstream& f, Table& table)
    {
        if (!_emitData)
        {
            // No data
            return;
        }

        // Emit the data at the current (unknown) address
        f << _name << ":";

        for (auto&& line : _lines)
        {
            f << "\n.dw";
            for (auto&& c : line)
            {
                const auto& value = table.find(c);
                if (value == -1)
                {
                    // skip unknown chars
                    continue;
                }
                f << " $" << std::hex << std::setw(4) << std::setfill('0') << value; // menu value
            }

            f << " ; " << convert.to_bytes(line);
        }
        f << '\n';
    }
};

void ConvertSymbols(const std::string& listName, const std::string& tableName, const std::string& outName, const std::string& patchesName)
{
    Table table(tableName);

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
    std::ofstream out(outName);
    for (auto&& menu: menus)
    {
        menu->writeData(out, table);
    }

    std::ofstream patches(patchesName);
    for (auto&& menu: menus)
    {
        menu->writePatches(patches);
    }
}
