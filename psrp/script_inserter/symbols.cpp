/*
Phantasy Star: Symbol Converter (Script)
*/


#include <string>
#include <vector>
#include <stdexcept>
#include <fstream>
#include <codecvt>
#include <map>
#include <regex>
#include <sstream>
#include <iostream>
#include <iomanip>
#include "ScriptItem.h"
// We just include the cpp here to make things simpler... it has some compiler warnings for us to suppress.
#pragma warning(push, 3)
#pragma warning(disable: 4244)
#include "../mini-yaml/yaml/Yaml.hpp"
#include "../mini-yaml/yaml/Yaml.cpp"
 #pragma warning(pop)

namespace
{
    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;

    enum
    {
        SymbolPlayer = 0x4f,
        SymbolMonster = 0x50,
        SymbolItem = 0x51,
        SymbolNumber = 0x52,
        // no 0x53
        SymbolNewLine = 0x54,
        SymbolWaitMore = 0x55,
        SymbolEnd = 0x56,
        SymbolDelay = 0x57,
        SymbolWait = 0x58,
        SymbolPostHint = 0x59,
        SymbolArticle = 0x5a,
        SymbolSuffix = 0x5b,
    };
}

class File
{
    std::ifstream _f;
    int _lineNumber;
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

    bool getLine(std::wstring& ws)
    {
        std::string s;
        const bool result = getLine(s);
        if (result)
        {
            ws = convert.from_bytes(s);
        }
        return result;
    }

    int lineNumber() const { return _lineNumber; }
};

class Table
{
    std::map<std::wstring, int> _table;
    std::map<int, std::wstring> _reverseTable;
    std::string::size_type _maxLength;

public:
    explicit Table(const std::string& fileName): _maxLength(0)
    {
        File f(fileName);

        std::wregex r(L"([0-9a-zA-Z]+)=(.+)");
        std::wsmatch matches;

        for (std::wstring s; f.getLine(s);)
        {
            if (s.empty() || s[0] == L';')
            {
                // skip comments and blanks
                continue;
            }
            if (!std::regex_search(s, matches, r))
            {
                continue;
            }
            int value = std::stoi(matches[1], nullptr, 16);
            if (matches[1].length() == 4)
            {
                // swap bytes
                value = (value & 0xff) << 8 | (value >> 8);
            }
            // Stick into our tables
            _table[matches[2]] = value;
            _reverseTable[value] = matches[2];
            _maxLength = std::max(_maxLength, matches[2].str().length());
        }
    }

    int find(const std::wstring& value) const
    {
        const auto it = _table.find(value);
        if (it == _table.end())
        {
            return -1;
        }
        return it->second;
    }

    bool findLongestMatch(const std::wstring& s, int& match, int& length) const
    {
        // We want to find the longest entry in our dictionary which matches.
        // We do this by trying one character at a time until we fail.
        length = 0;
        match = -1;
        const auto maxLength = std::min(_maxLength, s.length());
        std::wstring candidate;
        for (std::string::size_type trialLength = 1; trialLength <= maxLength; ++trialLength)
        {
            candidate += s[trialLength - 1];
            auto it = _table.find(candidate);
            if (it == _table.end())
            {
                continue;
            }
            // Else remember it
            length = static_cast<int>(trialLength);
            match = it->second;
        }
        return match != -1;
    }
  
    std::wstring elementForSymbol(int symbol) const
    {
        auto it = _reverseTable.find(symbol);
        if (it == _reverseTable.end())
        {
            return L"";
        }
        return it->second;
    }
};

int script_width; // Text box width, used for wrapping
int script_height; // Text box height, not used

bool script_end; // Set to true when reaching a line-ending command

bool script_hints; // Set to true when a "hint" is active (?)

int script_internal_hint; // "hint" value

int line_len; // Line length, used for wrapping

int GetWordLength(const wchar_t* pText)
{
    int width = 0;

    // scan for next non-text moment
    while (*pText != 0 && *pText != ' ' && *pText != '<')
    {
        // UTF-8 headers
        if (*pText == 0xe3) pText += 2;
        if (*pText == 0xe2) pText += 2;
        pText++;
        width++;
    }

    return width;
}

void CheckSuffixLength(int min, int max, std::vector<uint8_t>& outBuffer, const wchar_t* pText)
{
    int postHint = GetWordLength(pText);
    if (!script_hints)
    {
        if (line_len + postHint + min > script_width) postHint = 0;
        if (line_len + postHint + max <= script_width) postHint = 0;
    }
    if (postHint)
    {
        outBuffer.push_back(SymbolPostHint);
        outBuffer.push_back(static_cast<uint8_t>(postHint));
    }
    script_hints = true;
}


void ProcessCode(const wchar_t* & pText, std::vector<uint8_t>& outBuffer)
{
    // We read in the symbol
    // Let's try and match it with a regex...
    const std::wregex r(L"<([^>]+?)( ([A-Za-z0-9]{2}))?>");
    const std::wstring s(pText);
    std::wsmatch matches;
    if (std::regex_search(s, matches, r))
    {
        // Move pointer past it
        pText += matches[0].length();
        if (matches[1].str() == L"internal hint" && matches[3].matched)
        {
            script_internal_hint = std::stoi(matches[3].str(), nullptr, 16);
            script_hints = true;
        }
        else if (matches[1].str() == L"player")
        {
            CheckSuffixLength(1, 6, outBuffer, pText);
            outBuffer.push_back(SymbolPlayer);
        }
        else if (matches[1].str() == L"monster")
        {
            CheckSuffixLength(1, script_width, outBuffer, pText);
            outBuffer.push_back(SymbolMonster);
        }
        else if (matches[1].str() == L"item")
        {
            CheckSuffixLength(1, script_width, outBuffer, pText);
            outBuffer.push_back(SymbolItem);
        }
        else if (matches[1].str() == L"number")
        {
            CheckSuffixLength(1, 5, outBuffer, pText);
            outBuffer.push_back(SymbolNumber);
        }
        else if (matches[1].str() == L"line")
        {
            // add newline
            outBuffer.push_back(SymbolNewLine);

            line_len = 0;
            script_hints = false;
        }
        else if (matches[1].str() == L"wait more")
        {
            outBuffer.push_back(SymbolWaitMore);

            script_hints = false;
            line_len = 0;
        }
        else if (matches[1].str() == L"end")
        {
            outBuffer.push_back(SymbolEnd);

            // de-init
            script_end = true;
            script_hints = false;
            line_len = 0;
        }
        else if (matches[1].str() == L"delay")
        {
            outBuffer.push_back(SymbolDelay);
            outBuffer.push_back(SymbolEnd);

            // de-init
            script_end = true;
            script_hints = false;
            line_len = 0;
        }
        else if (matches[1].str() == L"wait")
        {
            outBuffer.push_back(SymbolWait);
            outBuffer.push_back(SymbolEnd);

            // de-init
            script_end = true;
            script_hints = false;
            line_len = 0;
        }
        else if (matches[1].str() == L"article")
        {
            outBuffer.push_back(SymbolArticle);
            outBuffer.push_back(1); // lowercase
            script_hints = true;
        }
        else if (matches[1].str() == L"Article")
        {
            outBuffer.push_back(SymbolArticle);
            outBuffer.push_back(2); // uppercase
            script_hints = true;
        }
        else if (matches[1].str() == L"use article" && matches[3].matched)
        {
            outBuffer.push_back(SymbolArticle);
            auto i = std::stoi(matches[3].str(), nullptr, 16);
            outBuffer.push_back((uint8_t)i); // extra articles
            script_hints = true;
        }
        else if (matches[1].str() == L"s")
        {
            outBuffer.push_back(SymbolSuffix);

            script_hints = true;
        }
        else
        {
            std::ostringstream ss;
            ss << "Ignoring tag \"" << convert.to_bytes(matches[0].str()) << "\"";
            throw std::runtime_error(ss.str());
        }
    }
    else
    {
        std::ostringstream ss;
        ss << "Invalid tag \"" << convert.to_bytes(pText) << "\"\n";
        throw std::runtime_error(ss.str());
    }
}

void Process_Text(const std::string& name, const std::string& language, const Table& table, std::vector<ScriptItem>& script)
{
    // Load the file
    Yaml::Node root;
    Yaml::Parse(root, name.c_str());

    // Init
    script_width = 0;
    script_hints = false;
    script_internal_hint = 0;
    script_end = false;
    
    int entryNumber = 0;
    
    std::regex hexRegex("[0-9a-fA-F]{4}\\w*");

    // Read in string entries
    for (unsigned int nodeIndex = 0; nodeIndex < root.Size(); ++nodeIndex)
    {
        // Get the script node
        auto& node = root[nodeIndex];

        // If it has dimensions, use them from now on
        script_width = node["width"].As<int>(script_width);
        script_height = node["width"].As<int>(script_height);

        // Extract patch offsets and/or label name(s)
        std::vector<int> patchOffsets;
        std::string label;
        std::stringstream wrapper(node["offsets"].As<std::string>());
        std::string item;
        while (std::getline(wrapper, item, ','))
        {
            if (regex_match(item, hexRegex))
            {
                patchOffsets.push_back(std::stoi(item, nullptr, 16));
            }
            else
            {
                if (item.empty() || item == "\n")
                {
                    continue;
                }
                // It's a label
                label = item;
            }
        }

        // Get the text and convert from UTF-8
        std::wstring s = convert.from_bytes(node[language].As<std::string>().c_str());

        // replace ' with ’
        std::replace(s.begin(), s.end(), L'\'', L'\x2019');

        // init
        const wchar_t* pText = s.c_str();
        line_len = 0;
        std::vector<uint8_t> outBuffer;

        // internal counter
        script_end = false;

        // do the conversion
        while (*pText != L'\0')
        {
            // Skip line breaks
            if (*pText == L'\n')
            {
                ++pText;
                continue;
            }
            const wchar_t start = *pText; // Character found
            int entry; // Binary value to emit

            const wchar_t* pStart = pText;

            // Check for a scripting code
            if (start == L'<')
            {
                ProcessCode(pText, outBuffer);

                if (script_end)
                {
                    // Ignore rest of string
                    break;
                }
                continue;
            }

            // check if we have a dictionary entry
            int matchLength;
            if (!table.findLongestMatch(pText, entry, matchLength))
            {
                // Fail on unmappable chars
                std::ostringstream ss;
                ss << "Unmapped character '" << convert.to_bytes(*pText) << "'";
                throw std::runtime_error(ss.str());
            }
            pText += matchLength;
            
            // attempt auto-formatting
            // check for whitespace
            if (start == ' ')
            {
                // scan for next non-text moment
                const int width = GetWordLength(pStart + 1);

                // see if next word does not fit in this same line
                if (line_len + 1 + width > script_width && !script_hints)
                {
                    // add newline
                    outBuffer.push_back(SymbolNewLine);

                    // reset x-pos
                    line_len = 0;

                    // bypass only whitespace
                    pText = pStart + 1;

                    continue;
                }
                if (script_hints && width > 0)
                {
                    // real-time line formatting needed
                    outBuffer.push_back(SymbolPostHint);
                    outBuffer.push_back(static_cast<uint8_t>(width + script_internal_hint));

                    // manual hint flag reset
                    script_internal_hint = 0;
                }
            } // end whitespace

            // successful -> emit byte
            outBuffer.push_back(static_cast<uint8_t>(entry));

            // line length checking
            line_len += matchLength;
        }

        if (script_end)
        {
            entryNumber++;
            bool discard = false;
            // Discard unused items
            if (label.empty())
            {
                if (patchOffsets.empty())
                {
                    // Skip this one
                    discard = true;
                }
                label = "Script" + std::to_string(entryNumber);
            }
            if (!discard)
            {
                // Store to the script object
                script.emplace_back(convert.to_bytes(s), outBuffer, patchOffsets, label);
            }
            patchOffsets.clear();
        }
    } // end while read line
}


void Convert_Symbols(const std::string& scriptFilename, const std::string& language, const std::string& tableFilename, std::vector<ScriptItem>& script)
{
    const Table table(tableFilename);

    Process_Text(scriptFilename, language, table, script);

    // Measure script
    int count = 0;
    std::vector<int> symbolCounts(256);
    for (auto && entry : script)
    {
        count += static_cast<int>(entry.data.size());
        for (auto && b : entry.data)
        {
            ++symbolCounts[b];
        }
    }
    std::cout << "Dictionary encoding gives " << count << " bytes for " << script.size() << " script entries\n";
  
    for (int i = 0; i < 256; ++i)
    {
        if (symbolCounts[i] == 0)
        {
            std::cout << "Symbol $" << std::setw(2) << std::hex << i << " is unused (";
            const auto& text = table.elementForSymbol(i);
            if (text.empty())
            {
                std::cout << "not in table file";
            }
            else
            {
                std::cout << '"' << convert.to_bytes(text) << '"';
            }
            std::cout << ")\n";
        }
    }
  
}
