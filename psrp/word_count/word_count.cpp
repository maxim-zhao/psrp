#include <string>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>
#include <algorithm>
#include <locale>
#include <codecvt>
#include "../mini-yaml/yaml/Yaml.hpp"

int main(int argc, const char** argv)
{
    if (argc != 4)
    {
        printf("Usage: %s <output file> <script file> <language>\n", argv[0]);
        return -1;
    }

    // Load the file
    Yaml::Node root;
    try
    {
        Yaml::Parse(root, argv[2]);
    }
    catch (const Yaml::Exception& e)
    {
        printf("Exception: %s\n", e.what());
        return -1;
    }

    std::map<std::wstring, std::size_t> wordCounts;
    std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;
    std::string language(argv[3]);

    // For each entry
    for (unsigned int entryIndex = 0; entryIndex < root.Size(); ++entryIndex)
    {
        // Get the entry
        auto& entry = root[entryIndex];

        // Take a copy of the text
        auto s = entry[language].As<std::string>();
        if (s.empty())
        {
            // Formatting entries have no text
            if (entry["width"].IsScalar())
            {
                continue;
            }
            std::cerr << "Warning: entry has no text for offsets: " << entry["offsets"].As<std::string>() << "\n";
        }
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
    // The benefit of substituting a word is a bit complicated.
    // The substituted text storage is in a separate bank to the main script so moving low-frequency long words there
    // can be worthwhile. The space taken by a word is very much dependent on the letter frequency that we later Huffman compress,
    // so common letter sequences are cheaper than unusual ones; the Huffman trees are also stored outside the script bank.
    // Thus we can maximize the script space by selecting the words which are used the most, and are long when Huffman encoded.
    // As we don't know the Huffman length, we use the word length as a proxy.
    // Some tweaking of the weight function seems to find this gives the smallest size for the script block, which is the most space-pressured.
    std::vector<std::pair<std::wstring, std::size_t>> weightedList;
    for (auto&& kvp : wordCounts)
    {
        if (kvp.first.length() == 1)
        {
            continue;
        }
        weightedList.emplace_back(kvp.first, (kvp.second - 1) * (kvp.first.length() - 0));
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
