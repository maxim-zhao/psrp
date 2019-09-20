/*
Phantasy Star: Symbol Converter (Script)
*/


#include <cstdio>
#include <cstring>

#include <string>
#include <vector>
#include <stdexcept>
#include <fstream>
#include <codecvt>
#include <map>
#include <regex>

namespace
{
	std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> convert;
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

	bool findLongestMatch(const std::wstring& s, std::wstring::size_type index, int& match, int& length) const
	{
		// We want to find the longest entry in our dictionary which matches.
		// We do this by trying one character at a time until we fail.
		length = 0;
		match = -1;
		const auto maxLength = std::min(_maxLength, s.length() - index);
		for (std::string::size_type trialLength = 1; trialLength <= maxLength; ++trialLength)
		{
			auto candidate = s.substr(index, trialLength);
			auto it = _table.find(candidate);
			if (it == _table.end())
			{
				// We are done
				return match != -1;
			}
			// Else remember it
			length = trialLength;
			match = it->second;
		}
		return false;
	}
};

std::vector<std::string> new_symbol_table[256];
std::vector<std::wstring> old_symbol_table[256];

int symbol_longest[256];

//////////////////////////////////////////////////////

void Load_Tables(int direction, const std::string& filename)
{
	FILE* table = fopen(filename.c_str(), "r");

	if (!table) throw std::runtime_error("Unable to open table file \"" + filename + "\"");

	int header = 0;

	// Check UTF-8 header
	fread(&header, 1, 3, table);
	if (header != 0xbfbbef)
	{
		// rewind
		fseek(table, 0, SEEK_SET);
	}

	// Init
	memset(symbol_longest, 0, sizeof(symbol_longest));

	// Read in table conversions
	char line[1024];
	while (fgets(line, sizeof(line), table))
	{
		std::string hex;
		std::wstring text;

		// remove newline
		if (line[strlen(line) - 1] == 0x0a)
			line[strlen(line) - 1] = 0;

		// skip comments or eos
		if (line[0] == ';' || line[0] == 0)
			continue;

		// build new symbol
		int lcv;
		for (lcv = 0; lcv < strlen(line); lcv++)
		{
			// look for symbol terminate
			if (line[lcv] == '=')
			{
				lcv++;
				break;
			}

			// add half-byte code
			hex += line[lcv];
		}

		// build old symbol
		text = convert.from_bytes(line + lcv);

		// assert valid translation
		if (!text.empty())
		{
			// add header nybble if needed
			if (hex.size() & 1)
				hex = '0' + hex;

			if (direction == 0)
			{
				int index;

				index = text[0] & 0xff;

				// string not found identification
				if (symbol_longest[index] < text.length())
					symbol_longest[index] = text.length();

				// use indexed table for speed boost
				old_symbol_table[index].push_back(text);
				new_symbol_table[index].push_back(hex);
			}
		}
	} // end while

	fclose(table);
}


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

void CheckSuffixLength(int min, int max, std::ostream& pass1, const wchar_t* pText)
{
	int post_hint = GetWordLength(pText);
	if (!script_hints)
	{
		if (line_len + post_hint + min > script_width) post_hint = 0;
		if (line_len + post_hint + max <= script_width) post_hint = 0;
	}
	if (post_hint)
	{
		pass1.put(0x59);
		pass1.put(post_hint);
	}
	script_hints = true;
}


void ProcessCode(const wchar_t* & pText, std::ostream& pass1, int line_num)
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
		if (matches[1].str() == L"width" && matches[3].matched)
		{
			script_width = std::stoi(matches[3].str(), nullptr, 16);
		}
		else if (matches[1].str() == L"height" && matches[3].matched)
		{
			script_height = std::stoi(matches[3].str(), nullptr, 16);
		}
		else if (matches[1].str() == L"internal hint" && matches[3].matched)
		{
			script_internal_hint = std::stoi(matches[3].str(), nullptr, 16);
			script_hints = true;
		}
		else if (matches[1].str() == L"player")
		{
			CheckSuffixLength(1, 6, pass1, pText);
			pass1.put(0x4f);
		}
		else if (matches[1].str() == L"monster")
		{
			CheckSuffixLength(1, script_width, pass1, pText);
			pass1.put(0x50);
		}
		else if (matches[1].str() == L"item")
		{
			CheckSuffixLength(1, script_width, pass1, pText);
			pass1.put(0x51);
		}
		else if (matches[1].str() == L"number")
		{
			CheckSuffixLength(1, 5, pass1, pText);
			pass1.put(0x52);
		}
		else if (matches[1].str() == L"line")
		{
			// add newline
			pass1.put(0x54);

			line_len = 0;
			script_hints = false;
		}
		else if (matches[1].str() == L"wait more")
		{
			pass1.put(0x55);

			script_hints = false;
			line_len = 0;
		}
		else if (matches[1].str() == L"end")
		{
			pass1.put(0x56);

			// de-init
			script_end = true;
			script_hints = false;
			line_len = 0;
		}
		else if (matches[1].str() == L"delay")
		{
			pass1.put(0x57);
			pass1.put(0x56);

			// de-init
			script_end = true;
			script_hints = false;
			line_len = 0;
		}
		else if (matches[1].str() == L"wait")
		{
			pass1.put(0x58);
			pass1.put(0x56);

			// de-init
			script_end = true;
			script_hints = false;
			line_len = 0;
		}
		else if (matches[1].str() == L"use article" && matches[3].matched)
		{
			const int value = std::stoi(matches[3].str(), nullptr, 16);

			pass1.put(0x5a);
			pass1.put(value);

			script_hints = true;
		}
		else if (matches[1].str() == L"use suffix")
		{
			pass1.put(0x5b);

			script_hints = true;
		}
		else
		{
			printf("Line %d: ignoring tag \"%ls\"\n", line_num, matches[0].str().c_str());
		}
	}
}

void Find_Entry(const wchar_t*& pText, int& index, int line_num)
{
	std::wstring lookup;
	int start;

	// not found
	index = -1;
	start = *pText & 0xff;

	// look into the future
	for (int lcv = 0; lcv < symbol_longest[start] && pText[lcv] != 0; lcv++)
	{
		// add character
		lookup += pText[lcv];

		// exhaust all possible matches
		for (int entry = 0; entry < old_symbol_table[start].size(); entry++)
		{
			// skip non-matches
			if (lookup.length() != old_symbol_table[ start ][ entry ].length()) continue;
			if (lookup != old_symbol_table[ start ][ entry ]) continue;

			// found a match
			index = entry;
		}
	} // end look

	// bump pointer forward
	if (index != -1)
	{
		int entry = index;
		pText += old_symbol_table[ start ][ entry ].length();
	}

		// log error
	else
	{
		if (symbol_longest[start])
		{
			printf("(line %d) ERROR: Symbol not found '%ls'\n",
			       line_num, lookup.c_str());
			pText += lookup.length();
		}
		else
		{
			// no length
			printf("(line %d) ERROR: Symbol not found '%lc'\n",
			       line_num, start);
			pText++;
		}
	}
}


void Process_Text(const std::string& name, std::ostream& pass1, const Table& table)
{
	File f(name);

	// Init
	script_width = 0;
	script_hints = false;
	script_internal_hint = 0;
	script_end = false;

	// Read in string entries
	for (std::wstring s; f.getLine(s);)
	{
		const wchar_t* pText;
		std::vector<uint8_t> out_buffer;

		// init
		pText = s.c_str();
		line_len = 0;

		// skip headers
		if (s[0] == L'[')
		{
			continue;
		}

		// internal counter
		script_end = false;

		// do the conversion
		while (*pText)
		{
			const wchar_t start = *pText; // Character found
			const int key = start & 0xff; // Truncated to 8 bits
			int entry; // Binary value to emit

			const wchar_t* pStart = pText;

			// Check for a scripting code
			if (start == L'<')
			{
				// flush data
				std::copy(out_buffer.begin(), out_buffer.end(), std::ostream_iterator<uint8_t>(pass1));
				out_buffer.clear();

				ProcessCode(pText, pass1, f.lineNumber());
				if (script_end)
				{
					break;
				}
				continue;
			}

			// check if we have a dictionary entry
			//if (table.findLongestMatch())
			
			Find_Entry(pText, entry, f.lineNumber());
			if (entry == -1)
			{
				continue;
			}

			// attempt auto-formatting
			// check for whitespace
			if (start == ' ')
			{
				// flush data
				std::copy(out_buffer.begin(), out_buffer.end(), std::ostream_iterator<uint8_t>(pass1));
				out_buffer.clear();

				// scan for next non-text moment
				const int width = GetWordLength(pStart + 1);

				// see if next word does not fit in this same line
				if (line_len + 1 + width > script_width && !script_hints)
				{
					// add newline
					pass1.put(0x54);

					// reset x-pos
					line_len = 0;

					// bypass only whitespace
					pText = pStart + 1;

					continue;
				}
				else
				{
					// real-time line formatting needed
					if (script_hints && width > 0)
					{
						pass1.put(0x59);
						pass1.put(width + script_internal_hint);

						// manual hint flag reset
						script_internal_hint = 0;
					}
				}
			} // end whitespace

			// successful -> start logging changes
			for (int lcv2 = 0; lcv2 < new_symbol_table[ key ][ entry ].length(); lcv2 += 2)
			{
				int code;

				// calculate new hex code
				sscanf(new_symbol_table[ key ][ entry ].c_str() + lcv2, "%02X", &code);

				// buffer out data
				out_buffer.push_back(code);
			}

			// line length checking
			line_len += old_symbol_table[ key ][ entry ].length();
			if (old_symbol_table[ key ][ entry ][0] == (char)0xe3) line_len -= 2;
			if (old_symbol_table[ key ][ entry ][0] == (char)0xe2) line_len -= 2;
		}
	} // end while read line
}


void Convert_Symbols(const char* list_name, const char* table_name, const char* out_name)
{
	Load_Tables(0, table_name);

	Table table(table_name);

	std::ofstream pass1(out_name, std::ios::binary);

	for (int i = 1; i <= 2; i++)
	{
		std::string name = list_name + std::to_string(i) + ".txt";

		// open each text bank
		Process_Text(name, pass1, table);
	}
}
