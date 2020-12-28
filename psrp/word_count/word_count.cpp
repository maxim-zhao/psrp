#include <string>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>
#include <algorithm>
#include <locale>
#include <codecvt>
// We just include the cpp here to make things simpler...
#pragma warning(push, 3)
#pragma warning(disable: 4244)
#include "../mini-yaml/yaml/Yaml.hpp"
#include "../mini-yaml/yaml/Yaml.cpp"
 #pragma warning(pop)

int main(int argc, const char** argv)
{
    if (argc != 3)
    {
        printf("Usage: %s <output file> <script file>\n", argv[0]);
        return -1;
    }

    // Load the file
    Yaml::Node root;
    Yaml::Parse(root, argv[2]);
    printf("3\n");

    std::map<std::wstring, std::size_t> wordCounts;
    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;

    // For each entry
    for (unsigned int entryIndex = 0; entryIndex < root.Size(); ++entryIndex)
    {
        // Get the entry
        auto& entry = root[entryIndex];
        // Take a copy of the text
        auto s = entry["en"].As<std::string>("");
        printf("Entry %d is \"%s\"\n", entryIndex, s.c_str());
        // Remove <> commands
        for (auto pos = s.find('<'); pos != std::string::npos; pos = s.find('<', pos))
        {
            auto end = s.find('>', pos);
            if (end == std::string::npos)
            {
                break;
            }
            // Erase all but one
            s.erase(pos, end - pos);
            // And replace with a space
            s[pos] = ' ';
        }
        // Convert to wstring
        std::wstring line = convert.from_bytes(s.c_str());
        // replace ' with ’
        std::replace(line.begin(), line.end(), L'\'', L'\x2019');
        // We split on any non-alpha characters, but also accept "'" as a starting letter.
        for (unsigned int i = 0; i < line.length();)
        {
            auto c = line[i];
            // Is this a candidate?
            if (::iswalpha(c) || c == L'\x2019')
            {
                // Good candidate; look for the end
                unsigned int j;
                for (j = i + 1; j != line.length(); ++j)
                {
                    if (!::iswalpha(line[j]))
                    {
                        break;
                    }
                }
                // Pull out the word
                const auto& word = line.substr(i, j - i);
                if (word.empty())
                {
                    continue;
                }
                // Count it
                ++wordCounts[word];
                // Skip it
                i = j;
            }
            else
            {
                ++i;
            }
        }
    }

    printf("Script has %zd unique words\n", wordCounts.size());

    // Then convert to weighted counts
    std::vector<std::pair<std::wstring, std::size_t>> weightedList;
    for (auto&& kvp : wordCounts)
    {
        weightedList.emplace_back(kvp.first, kvp.second * (kvp.first.length() - 1));
    }
  
    // Then sort by weight
    std::sort(
        weightedList.begin(), 
        weightedList.end(), 
        [](const std::pair<std::wstring, std::size_t>& left, const std::pair<std::wstring, std::size_t>& right)
        {
          // We want a "stable" sort so we sort on the string if there is a tie on count.
          if (left.second == right.second)
          {
              return left.first > right.first;
          }
          return left.second > right.second;
        });

    // And emit them
    std::ofstream of(argv[1]);
    for (auto && pair : weightedList)
    {
        of << convert.to_bytes(pair.first) << "\n";
    }

  return 0;
}
