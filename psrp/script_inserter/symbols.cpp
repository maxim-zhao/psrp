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

	int lineNumber() const { return _lineNumber; }
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

	// TODO: implement "find longest match at start of string"
	// Needs to return the match and also the length?
};

#define EOS 0x56

std::vector<std::string> new_symbol_table[256];
std::vector<std::string> old_symbol_table[256];

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
		std::string new_symbol, old_symbol;

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
			new_symbol += line[lcv];
		}

		// build old symbol
		old_symbol = line + lcv;

		// assert valid translation
		if (old_symbol != "")
		{
			// add header nybble if needed
			if (new_symbol.size() & 1)
				new_symbol = '0' + new_symbol;

			if (!direction)
			{
				int index;

				index = old_symbol[0] & 0xff;

				// string not found identification
				if (symbol_longest[index] < old_symbol.length())
					symbol_longest[index] = old_symbol.length();

				// use indexed table for speed boost
				old_symbol_table[index].push_back(old_symbol);
				new_symbol_table[index].push_back(new_symbol);
			}
			else
			{
				int index;

				index = 0;
				sscanf(new_symbol.c_str(), "%02X", &index);

				// use indexed table for speed boost
				old_symbol_table[index].push_back(old_symbol);
				new_symbol_table[index].push_back(new_symbol);
			}
		}
	} // end while

	fclose(table);
}


#define old_symbol old_symbol_table[ start ][ entry ]
#define new_symbol new_symbol_table[ start ][ entry ]

int script_width; // Text box width, used for wrapping
int script_height; // Text box height, not used

bool script_end; // Set to true when reaching a line-ending command

bool script_hints; // Set to true when a "hint" is active (?)

int script_internal_hint; // "hint" value

int line_len; // Line length, used for wrapping

void Scan_Text(const char*& pText, int& width)
{
	width = 0;

	// scan for next non-text moment
	while (*pText != 0 && *pText != ' ' && *pText != '<')
	{
		// UTF-8 headers
		if (*pText == (char)0xe3) pText += 2;
		if (*pText == (char)0xe2) pText += 2;
		pText++;
		width++;
	}
}


#define POST_HINT( MIN, MAX ) \
	pLast = pText; \
	while( *( pLast++ ) != '>' ) continue; \
	Scan_Text( pLast, post_hint ); \
	\
	if( !script_hints ) { \
		if( line_len + post_hint + MIN > script_width ) post_hint = 0; \
		if( line_len + post_hint + MAX <= script_width ) post_hint = 0; \
	} \
	\
	if( post_hint ) { \
		pass1.put( 0x59); \
		pass1.put( post_hint); \
	} \
	script_hints = true;


void Process_Code(const char* & pText, std::ostream& pass1, int line_num)
{
	std::string read_symbol;
	int index = -1;
	const char* pLast;
	int post_hint;

#define CODE_TABLE 26

	std::string code_table[ CODE_TABLE ] = {
		"width ", "wrap", "/wrap", "center",
		"/center", "control ", "line ", "border ",
		"insert ", "begin quote", "end quote", "begin intro",
		"end intro", "internal hint ", "height ",

		"player", "monster", "item", "number",
		"line", "wait more", "end", "delay",
		"wait",
		"use article ", "use suffix",
	};

	// open brace '<'
	pText++;
	pLast = pText;

	///////////////////////////////////////////////////////

	// look for script code context
	while (*pText != '>' && *pText != NULL)
	{
		// add characters
		read_symbol += *(pText++);

		// exhaust all possible matches
		for (int entry = 0; entry < CODE_TABLE; entry++)
		{
			// skip non-matches
			if (read_symbol.length() != code_table[entry].length()) continue;
			if (read_symbol != code_table[entry]) continue;

			// found a match
			index = entry;
			pLast = pText;
		}
	} // end while loop

	if (index != -1)
	{
		// de-init
		read_symbol = "";
		pText = pLast;

		// execute code
		switch (index)
		{
			// internal width check
		case 0:
			sscanf(pText, "%02X", &script_width);
			pText += 2;
			break;

			// internal text wrapping
		case 1:
			// no internal text centering
		case 4:
			// always on, swallow code
			break;
			
			// internal script hint (for suffix spillage prevention)
		case 13:
			{
				sscanf(pText, "%02X", &script_internal_hint);
				pText += 2;

				script_hints = true;
			}
			break;

			// internal height check
		case 14:
			sscanf(pText, "%02X", &script_height);
			pText += 2;
			break;

			/////////////////////////////////////////////////

			// current player
		case 15: POST_HINT(1, 6);
			pass1.put(0x4f);
			break;

			// current monster
		case 16: POST_HINT(1, script_width);
			pass1.put(0x50);
			break;

			// current item
		case 17: POST_HINT(1, script_width);
			pass1.put(0x51);
			break;

			// current number
		case 18: POST_HINT(1, 5);
			pass1.put(0x52);
			break;

			// add plain newline
		case 19:
			{
				// add newline
				pass1.put(0x54);

				line_len = 0;
				script_hints = false;
			}
			break;

			// wait for more input
		case 20:
			{
				pass1.put(0x55);

				script_hints = false;
				line_len = 0;
			}
			break;

			// end of text
		case 21:
			{
				pass1.put(0x56);

				// de-init
				script_end = true;
				script_hints = false;
				line_len = 0;
			}
			break;

			// delay 'x' seconds
		case 22:
			{
				pass1.put(0x57);
				pass1.put(0x56);

				// de-init
				script_end = true;
				script_hints = false;
				line_len = 0;
			}
			break;

			// wait for input
		case 23:
			{
				pass1.put(0x58);
				pass1.put(0x56);

				// de-init
				script_end = true;
				script_hints = false;
				line_len = 0;
			}
			break;

			// (custom) use indefinite article
		case 24:
			{
				int value;

				sscanf(pText, "%02X", &value);
				pText += 2;

				pass1.put(0x5a);
				pass1.put(value);

				script_hints = true;
			}
			break;

			// (custom) use suffix
		case 25:
			{
				pass1.put(0x5b);

				script_hints = true;
			}
			break;
		default:
			printf("(line %d) ERROR: Script code removed '%s'\n",
			       line_num, read_symbol.c_str());
			break;
		}; // end switch
	}
	else
	{
		// log error
		printf("(line %d) ERROR: Script code not found '%s'\n",
		       line_num, read_symbol.c_str());
	}

	// skip code '>' character
	pText++;
}


void Find_Entry(const char*& pText, int& index, int line_num)
{
	std::string lookup;
	int start;

	// not found
	index = -1;
	start = (*pText) & 0xff;

	// look into the future
	for (int lcv = 0; lcv < symbol_longest[start] && pText[lcv] != 0; lcv++)
	{
		// add character
		lookup += pText[lcv];

		// exhaust all possible matches
		for (int entry = 0; entry < old_symbol_table[start].size(); entry++)
		{
			// skip non-matches
			if (lookup.length() != old_symbol.length()) continue;
			if (lookup != old_symbol) continue;

			// found a match
			index = entry;
		}
	} // end look

	// bump pointer forward
	if (index != -1)
	{
		int entry = index;
		pText += old_symbol.length();
	}

		// log error
	else
	{
		if (symbol_longest[start])
		{
			printf("(line %d) ERROR: Symbol not found '%s'\n",
			       line_num, lookup.c_str());
			pText += lookup.length();
		}
		else
		{
			// no length
			printf("(line %d) ERROR: Symbol not found '%c'\n",
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
	for (std::string s; f.getLine(s);)
	{
		const char* pText;
		std::vector<uint8_t> out_buffer;

		// init
		pText = s.c_str();
		line_len = 0;

		// skip headers
		if (s[0] == '[')
		{
			continue;
		}

		// internal counter
		script_end = false;

		// do the conversion
		while (*pText)
		{
			int entry;
			int start;
			const char* pOld;

			// grab symbol
			start = *pText & 0xff;
			pOld = pText;

			// determine if scripting code needed
			if (start == '<')
			{
				// flush data
				if (!out_buffer.empty())
				{
					pass1.write((const char*)&out_buffer[0], out_buffer.size());

					// reset
					out_buffer.clear();
				}

				Process_Code(pText, pass1, f.lineNumber());
				if (script_end) 
				{
					break;
				}
				continue;
			}

			// check if we have a dictionary entry
			Find_Entry(pText, entry, f.lineNumber());
			if (entry == -1) 
			{
				continue;
			}

			// attempt auto-formatting
			// check for whitespace
			if (start == ' ')
			{
				int width;
				const char* pTmp = pOld + 1;

				// flush data
				if (!out_buffer.empty())
				{
					pass1.write((const char*)&out_buffer[0], out_buffer.size());

					// reset
					out_buffer.clear();
				}

				// scan for next non-text moment
				Scan_Text(pTmp, width);

				// see if next word does not fit in this same line
				if (line_len + 1 + width > script_width && !script_hints)
				{
					// add newline
					pass1.put(0x54);

					// reset x-pos
					line_len = 0;

					// bypass only whitespace
					pText = pOld + 1;

					continue;
				}
				else
				{
					// real-time line formatting needed
					if (script_hints && width)
					{
						pass1.put(0x59);
						pass1.put(width + script_internal_hint);

						// manual hint flag reset
						script_internal_hint = 0;
					}
				}
			} // end whitespace

			// successful -> start logging changes
			for (int lcv2 = 0; lcv2 < new_symbol.length(); lcv2 += 2)
			{
				int code;

				// calculate new hex code
				sscanf(new_symbol.c_str() + lcv2, "%02X", &code);

				// buffer out data
				out_buffer.push_back(code);
			}

			// line length checking
			line_len += old_symbol.length();
			if (old_symbol[0] == (char)0xe3) line_len -= 2;
			if (old_symbol[0] == (char)0xe2) line_len -= 2;
		}
	} // end while read line
}

#undef old_symbol
#undef new_symbol


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
