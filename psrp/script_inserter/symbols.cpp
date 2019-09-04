/*
Phantasy Star: Symbol Converter (Script)
*/

#ifdef _DEBUG
	#pragma warning( disable: 4786 )	// 255 character debug limit
#endif

#include <cwchar>
#include <cstdio>
#include <string.h>

#include <string>
#include <vector>

using std::string;
using std::vector;

#define LIST_EOF 0xFF		// end-of-file marker
#define EOS 0x56

//////////////

#define EOS1 0x58				// wait
#define EOS2 0x57				// delay
#define EOS3 0x56				// end-of-string

//////////////

FILE *list, *table, *pass1;

char line[1024];
int line_num;

vector<string> new_symbol_table[256];
vector<string> old_symbol_table[256];

int symbol_longest[256];

//////////////////////////////////////////////////////

void Load_Tables( int direction )
{
	int header = 0;

	// Check UTF-8 header
	fread( &header, 1, 3, table );
	if( header != 0xbfbbef ) {
		// rewind
		fseek( table, 0, SEEK_SET );
	}

	// Init
	memset( symbol_longest, 0, sizeof( symbol_longest ) );

	// Read in table conversions
	while( fgets( line, sizeof( line ), table ) ) {
		string new_symbol, old_symbol;

		// remove newline
		if( line[ strlen( line ) - 1 ] == 0x0a )
			line[ strlen( line ) - 1 ] = 0;

		// skip comments or eos
		if( line[0] == ';' || line[0] == 0 )
			continue;
		
		// build new symbol
    int lcv;
		for( lcv = 0; lcv < strlen( line ); lcv++ ) {
			
			// look for symbol terminate
			if( line[ lcv ] == '=' ) {
				lcv++;
				break;
			}

			// add half-byte code
			new_symbol += line[ lcv ];
		}

		// build old symbol
		old_symbol = line + lcv;

		// assert valid translation
		if( old_symbol != "" ) {

			// add header nybble if needed
			if( new_symbol.size() & 1 )
				new_symbol = '0' + new_symbol;

			if( !direction ) {
				int index;

				index = old_symbol[0] & 0xff;

				// string not found identification
				if( symbol_longest[ index ] < old_symbol.length() )
					symbol_longest[ index ] = old_symbol.length();

				// use indexed table for speed boost
				old_symbol_table[ index ].push_back( old_symbol );
				new_symbol_table[ index ].push_back( new_symbol );
			} else {
				int index;

				index = 0;
				sscanf( new_symbol.c_str(), "%02X", &index );

				// use indexed table for speed boost
				old_symbol_table[ index ].push_back( old_symbol );
				new_symbol_table[ index ].push_back( new_symbol );
			}
		}
	} // end while
}


#define old_symbol old_symbol_table[ start ][ entry ]
#define new_symbol new_symbol_table[ start ][ entry ]

int table_number;
int table_offset;
int table_length;

int script_width;
int script_height;

int script_center;
int script_wrap;
int script_border;
int script_end;
int script_line;

int script_quote;
int script_autoquote;
int script_autowait;
int script_hints;
int script_intro;

int script_internal_hint;

int line_len;

void Scan_Text( char *&pText, int &width )
{
	width = 0;

	// scan for next non-text moment
	while( *pText != 0 && *pText != ' '  && *pText != '<') {
		// UTF-8 headers
		if( *pText == (char) 0xe3 ) pText += 2;
		if( *pText == (char) 0xe2 ) pText += 2;
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
		fputc( 0x59, pass1 ); \
		fputc( post_hint, pass1 ); \
	} \
	script_hints = 1;


void Process_Code( char* &pText )
{
	string read_symbol;
	int index = -1;
	char *pLast;
	int post_hint;

#define CODE_TABLE 26

	string code_table[ CODE_TABLE ] = {
		"width ", "wrap", "/wrap", "center",
		"/center", "control ", "line ", "border ",
		"insert ", "begin quote", "end quote", "begin intro",
		"end intro", "internal hint ", "height ",

		"player", "monster", "item", "number",
		"line", "wait more", "end", "delay",
		"wait",
		"use article ",	"use suffix",
	};

	// open brace '<'
	pText++;
	pLast = pText;

	///////////////////////////////////////////////////////

	// look for script code context
	while( *pText != '>' && *pText != NULL ) {

		// add characters
		read_symbol += *( pText++ );

		// exhaust all possible matches
		for( int entry = 0; entry < CODE_TABLE; entry++ ) {

			// skip non-matches
			if( read_symbol.length() != code_table[ entry ].length() ) continue;
			if( read_symbol != code_table[ entry ] ) continue;

			// found a match
			index = entry;
			pLast = pText;
		}
	} // end while loop

	if( index != -1 ) {

		// de-init
		read_symbol = "";
		pText = pLast;
	
		// execute code
		switch( index ) {

		// internal width check
		case 0:
			sscanf( pText, "%02X", &script_width );
			pText += 2;
			break;

		// internal text wrapping
		case 1: script_wrap = 1; break;

		// no internal text wrapping
		case 2: script_wrap = 0; break;

		// internal text centering
		case 3: script_center = 1; break;

		// no internal text centering
		case 4: script_center = 0; break;

		// scroll code
		case 5: {
			int value;

			sscanf( pText, "%02X", &value );
			pText += 2;

			fputc( 0x01, pass1 );
			fputc( value, pass1 );
		} break;

		// # newlines
		case 6: {
			int value;

			sscanf( pText, "%02X", &value );
			pText += 2;
		
			fputc( 0x02, pass1 );
			fputc( value, pass1 );
		} break;

		// internal border marker
		case 7:
			sscanf( pText, "%02X", &script_border );
			pText += 2;
			break;

		// used to unroll substring matches
		case 8: {
				string str;

				// tack on addition
				str = '>';
				while( *pText != '>' ) str += *( pText++ );
				str += ( pText + 1 );
				memcpy( pText, str.c_str(), str.length() );
			}	break;

		// start quote formatting
		case 9: script_autoquote = 1; script_border++; break;

		// end quote formatting
		case 10: script_autoquote = 0; script_border--; break;

		// start intro formatting
		case 11: script_intro = 1; break;

		// end intro formatting
		case 12: script_intro = 0; break;

		// internal script hint (for suffix spillage prevention)
		case 13: {
			sscanf( pText, "%02X", &script_internal_hint );
			pText += 2;

			script_hints = 1;
		}	break;

		// internal width check
		case 14:
			sscanf( pText, "%02X", &script_height );
			pText += 2;
			break;

		/////////////////////////////////////////////////

		// current player
		case 15: POST_HINT( 1, 6 ); fputc( 0x4f, pass1 ); break;

		// current monster
		case 16: POST_HINT( 1, script_width ); fputc( 0x50, pass1 ); break;

		// current item
		case 17: POST_HINT( 1, script_width ); fputc( 0x51, pass1 ); break;

		// current number
		case 18: POST_HINT( 1, 5 ); fputc( 0x52, pass1 ); break;

		// add plain newline
		case 19: {
			script_line++;
			if( script_line % script_height == 0 ) {

				// wait more
				if( script_autowait )	fputc( 0x55, pass1 );

				// use alternate delay
				if( script_intro ) fputc( 0x57, pass1 );
			}

			// clear line counter (handled via engine)
			//if( script_intro && script_line % script_height == 0 ) fputc( 0xce, pass1 );

			// add newline
			fputc( 0x54, pass1 );

			line_len = 0;
			script_hints = 0;
		} break;

		// wait for more input
		case 20: {
			fputc( 0x55, pass1 );

			script_line = 0;
			script_hints = 0;
			line_len = 0;
		} break;

		// end of text
		case 21: {
			fputc( 0x56, pass1 );

			// de-init
			script_end = 1;
			script_line = 0;
			script_hints = 0;
			line_len = 0;
		}	break;

		// delay 'x' seconds
		case 22: {
			fputc( 0x57, pass1 );
			fputc( 0x56, pass1 );

			// de-init
			script_end = 1;
			script_line = 0;
			script_hints = 0;
			line_len = 0;
		} break;

		// wait for input
		case 23: {
			fputc( 0x58, pass1 );
			fputc( 0x56, pass1 );

			// de-init
			script_end = 1;
			script_line = 0;
			script_hints = 0;
			line_len = 0;
		} break;

		// (custom) use indefinite article
		case 24: {
			int value;

			sscanf( pText, "%02X", &value );
			pText += 2;

			fputc( 0x5a, pass1 );
			fputc( value, pass1 );

			script_hints = 1;
		} break;

		// (custom) use suffix
		case 25: {
			fputc( 0x5b, pass1 );

			script_hints = 1;
		} break;

		}; // end switch
	}	else {
		// log error
		printf( "(line %d) ERROR: Script code not found '%s'\n",
						line_num, read_symbol.c_str() );
	}

	// skip code '>' character
	pText++;
}


void Find_Entry( char *&pText, int &index )
{
	string lookup;
	int start;

	// not found
	index = -1;
	start = ( *pText ) & 0xff;

	// look into the future
	for( int lcv = 0; lcv < symbol_longest[ start ] && pText[ lcv ] != 0; lcv++ ) {

		// add character
		lookup += pText[ lcv ];

		// exhaust all possible matches
		for( int entry = 0; entry < old_symbol_table[ start ].size(); entry++ ) {

			// skip non-matches
			if( lookup.length() != old_symbol.length() ) continue;
			if( lookup != old_symbol ) continue;

			// found a match
			index = entry;
		}
	} // end look

	// bump pointer forward
	if( index != -1 ) {
		int entry = index;
		pText += old_symbol.length();
	}
	
	// log error
	else {
		if( symbol_longest[ start ] ) {
			printf( "(line %d) ERROR: Symbol not found '%s'\n",
				line_num, lookup.c_str() );
			pText += lookup.length();
		} else {
			// no length
			printf( "(line %d) ERROR: Symbol not found '%c'\n",
				line_num, start );
			pText++;
		}
	}
}


void Process_Text()
{
	int header = 0;

	// Check UTF-8 header
	fread( &header, 1, 3, list );
	if( header != 0xbfbbef ) {
		// rewind
		fseek( list, 0, SEEK_SET );
	}

	// Init
	script_width = 0;
	script_center = 0;
	script_line = 0;
	script_autowait = 0;
	script_quote = 0;
	script_autoquote = 0;
	script_border = 0;
	script_hints = 0;
	script_intro = 0;
	script_internal_hint = 0;
	script_end = 0;

	// Init table entries
	table_number = 1;
	table_offset = 0;
	table_length = 0;
	//printf( "Table location data  [WARNING: Offsets are rough locations]\n" );

	// Read in string entries
	while( fgets( line, sizeof( line ), list ) ) {
		char *pText;
		string out_buffer;

		// init
		pText = line;
		line_num++;
		line_len = 0;

		// remove header
		if( *pText == '[' ) {
			while( *pText != ']' ) pText++;
			pText++;
		}

		// remove newline
		if( line[ strlen( line ) - 1 ] == 0x0a )
			line[ strlen( line ) - 1 ] = 0;

		// skip comments or eos
		if( *pText == ';' || *pText == 0 )
			continue;

		// check for new table altogether
		if( *pText == '#' && strlen( line ) == 1 ) {

			// log statistics
			//printf( "(line %d) Table %02X: End $%04X, Length $%04X\n",
				//line_num, table_number, table_offset, table_length );

			// re-init
			table_number++;
			table_length = 0;
			continue;
		}

/*
		// prefix byte: length
		fputc( strlen( line ), pass1 );
		table_offset++;
		table_length++;
*/

		// internal counter
		script_end = 0;
		++table_offset;

		// do the conversion
		while( *pText ) {
			int entry;
			int start;
			char *pOld;

			// grab symbol
			start = *pText & 0xff;
			pOld = pText;

			// determine if scripting code needed
			if( start == '<' ) {

				// flush data
				if( out_buffer.length() ) {
					//fputc( script_border + script_center ? ( script_width - out_buffer.length() ) >> 1 : 0, pass1 );
					fwrite( out_buffer.c_str(), 1, out_buffer.length(), pass1 );

					// reset
					out_buffer = "";
				}

				Process_Code( pText );
				if( script_end ) break;
				continue;
			}

			// check if we have a dictionary entry
			Find_Entry( pText, entry );
			if( entry == -1 ) continue;

#if 0
			// expand names inline to allow for full in-game renaming
			// but don't perform during introduction
			if( new_symbol[0] == 'D' &&
					new_symbol[1] == 'A' &&
					!script_intro ) {
				string str;

				// tack on addition
				str = "<lookup name ";
				str += new_symbol[2];
				str += new_symbol[3];
				str += ">";
				//while( *pText != '>' ) str += *( pText++ );
				str += pText;
				memcpy( pText, str.c_str(), str.length() );
				continue;
			}
#endif

			// attempt auto-formatting
			if( script_wrap ) {

				// check for whitespace
				if( start == ' ' ) {
					int width;
					char *pTmp = pOld + 1;

					// flush data
					if( out_buffer.length() ) {
						//fputc( script_border + script_center ? ( script_width - out_buffer.length() ) >> 1 : 0, pass1 );
						fwrite( out_buffer.c_str(), 1, out_buffer.length(), pass1 );

						// reset
						out_buffer = "";
					}

					// scan for next non-text moment
					Scan_Text( pTmp, width );

					// see if next word does not fit in this same line
					if( line_len + 1 + width + script_border * 2 > script_width && 
						 ( !script_autoquote || *( pTmp-1 ) != '\"' ) && !script_hints ) {

						script_line++;
						if( script_line % script_height == 0 ) {

							// use 'wait more'
							if( script_autowait )	fputc( 0x55, pass1 );

							// use alternate delay
							if( script_intro ) fputc( 0x57, pass1 );

							// reset y-pos
							script_line = 0;
						}
						
						// add newline
						fputc( 0x54, pass1 );
						
						// clear line counter for intro only (handled via engine)
						//if( script_intro && script_line % script_height == 0 ) fputc( 0xce, pass1 );

						// reset x-pos
						line_len = 0;

						// bypass only whitespace
						pText = pOld + 1;

						// add padding for quotes
						if( script_autoquote ) {
							fputc( 0x00, pass1 );
							line_len++;
						}
						continue;
					} else {
						// real-time line formatting needed
						if( script_hints && width ) {
							fputc( 0x59, pass1 );
							fputc( width + script_internal_hint, pass1 );

							// manual hint flag reset
							script_internal_hint = 0;
						}
					}
				} // end whitespace
			} // end script wrap

			// successful -> start logging changes
			for( int lcv2 = 0; lcv2 < new_symbol.length(); lcv2 += 2 ) {
				int code;

				// calculate new hex code
				sscanf( new_symbol.c_str() + lcv2, "%02X", &code );

#if 0
				if( old_symbol == "\"" ) {
					// end quote check
					if( script_quote ) {
						script_quote = 0;
						code++;
					} else
						script_quote = 1;
				}
#endif

				// buffer out data
				out_buffer += code;
			}

			// line length checking
			line_len += old_symbol.length();
			if( old_symbol[0] == (char) 0xe3 ) line_len -= 2;
			if( old_symbol[0] == (char) 0xe2 ) line_len -= 2;

			// update file position
			//table_offset += read_symbol.length();
			//table_length += read_symbol.length();
		}

		// clear buffer
		memset( line, 0, sizeof( line ) );
	} // end while read line


	// log statistics
	//printf( "(line %d) Table %02X: End $%04X, Length $%04X\n",
		//line_num, table_number, table_offset, table_length );
	//printf( "\n" );
}

#undef old_symbol
#undef new_symbol


int Convert_Symbols( char *list_name, char *table_name, char *out_name )
{
	// Open files
	table = fopen( table_name, "r" );
	pass1 = fopen( out_name, "wb" );

	// Check for file errors
	if( !table ) {
		printf( "Error: Could not open file \"%s\"\n", table_name );
		return -1;
	}
	if( !pass1 ) {
		printf( "Error: Could not create file \"%s\"\n", out_name );
		return -1;
	}

	Load_Tables( 0 );

	for( int lcv = 1; lcv <= 2; lcv++ ) {
		string name = list_name;
		name += ( lcv + '0' );
		name += ".txt\0";

		// open each text bank
		list = fopen( name.c_str(), "r" );
		if( !list ) {
			printf( "Error: Could not open file \"%s\"\n", name.c_str() );
			return -1;
		}

		Process_Text();
	}

	// Done processing
	fclose( list );
	fclose( table );
	fclose( pass1 );

	return 0;
}

/////////////////////////////////////////////////////

FILE *rom;
extern unsigned char rom_page[0x4000];

#define old_symbol old_symbol_table[ symbol ][ 0 ]
#define new_symbol new_symbol_table[ symbol ][ 0 ]


void Lookup( int ptr, FILE *out )
{
	int entry;
	int length;

	// skip number of dictionary entries
	entry = fgetc( list );
	while( entry-- ) {
		// text length + length byte
		ptr += rom_page[ ptr ];
		ptr++;
	}

	// skip length byte
	length = rom_page[ ptr ];
	ptr++;

	// special demarkation
	fputc( '<', out );
	
	// toss out each regular character
	while( length-- ) {
		int symbol;
		
		symbol = rom_page[ ptr++ ];
		fwrite( old_symbol.c_str(), 1, old_symbol.length(), out );
	}

	// special demarkation
	fputc( '>', out );
}


void Dump_Text( char *out_name )
{
	FILE *out;
	int symbol = 0;
	int table_size;

	// Init table entries
	table_number = 1;
	table_offset = 0;
	table_length = 0;

	// Read in each script entry
	while( symbol != EOF ) {
		bool log = 0;
		string read_symbol;
		int start;
		int len;

		// Write to next script file
		if( table_offset == 0 ) {
			char file_name[256];

			// Create a new file
			sprintf( file_name, "%s%d.txt", out_name, table_number );
			out = fopen( file_name, "w" );
			if( !out ) {
				printf( "Error: Could not write to file \"%s\"\n", file_name );
				return;
			}

			// pointer table size
			if( table_number == 1 ) fread( &table_size, 1, 4, list );

			// Add UTF-8 header
			fputc( 0xef, out );
			fputc( 0xbb, out );
			fputc( 0xbf, out );
		}

		// Pointer table handling
		if( table_number == 1 ) fread( &len, 1, 4, list );

		do {
			// Go through each character in this string
			symbol = fgetc( list );
			if( symbol == EOF ) break;

			// Log status
			if( !log ) {
				if( table_number == 1 ) fprintf( out, "[%03X]\n", ( table_offset+1 ) * 2 );
				else fprintf( out, "[%03X]\n", table_offset * 2 );
				log = 1;
			}

			// regular text
			if( symbol < 0x4f ) {
				int entry;
				char hex[3];

				// grab next character
				sprintf( hex, "%02X", symbol );
				hex[2] = '\0';

				if( read_symbol == "" ) start = symbol;
				read_symbol += hex;

				// check if the entry exists
				for( entry = 0; entry < new_symbol_table[ start ].size(); entry++ ) {
					if( read_symbol == new_symbol )	break;
				}

				// successful -> start logging changes
				if( entry != new_symbol_table[ start ].size() ) {

					// print out new code
					fprintf( out, "%s", old_symbol.c_str() );
				} // end success
				else {
					printf( "ERROR: Symbol not found in table\n" );
				}

				// erase data
				read_symbol.erase( read_symbol.begin(), read_symbol.end() );
			}

			// control codes
			else {
				switch( symbol ) {
				case 0x4f: fprintf( out, "<player>" ); break;
				case 0x50: fprintf( out, "<monster>" ); break;
				case 0x51: fprintf( out, "<item>" ); break;
				case 0x52: fprintf( out, "<number>" ); break;
				case 0x54: fprintf( out, "<line>\n" ); break;
				case 0x55: fprintf( out, "<wait more>\n" ); break;
				case 0x56: fprintf( out, "<end>" ); break;
				case 0x57: fprintf( out, "<delay>" ); break;
				case 0x58: fprintf( out, "<wait>" ); break;
				default:
					printf( "ERROR: Unknown code %02X @ %06X\n", symbol, ftell( list ) );
					fprintf( out, "<%02X>", symbol );
					break;
				}
			}
		}	while(
				( table_number == 1 && --len ) ||
				( table_number > 1 && symbol != EOS1 && symbol != EOS2 && symbol != EOS3 ) );

		if( symbol == EOF ) break;

		// update records
		table_offset++;
		if( table_offset == table_size && table_number == 1 ) {
			table_offset = 0;
			table_number++;
		}

		// line-wrap
		fprintf( out, "\n\n" );
	}

	fclose( out );
}


void Dump_Lists( char *out_name )
{
	FILE *out;
	int ptr = 0x2b8f;

	out = fopen( out_name, "w" );
	if( !out ) {
		printf( "Error: Could not write to file \"%s\"\n", out_name );
		return;
	}

	// Add UTF-8 header
	fputc( 0xef, out );
	fputc( 0xbb, out );
	fputc( 0xbf, out );

	// Read in each script entry
	while( ptr < 0x3108 ) {
		int length;
		int start;
		string read_symbol;

		// Go through each character in this string
		length = rom_page[ ptr++ ];

		while( length-- ) {
			int symbol = rom_page[ ptr++ ];
			int entry;
			char hex[3];

			// grab next character
			sprintf( hex, "%02X", symbol );
			hex[2] = '\0';

			if( read_symbol == "" ) start = symbol;
			read_symbol += hex;

			// check if the entry exists
			for( entry = 0; entry < new_symbol_table[ start ].size(); entry++ ) {
				if( read_symbol == new_symbol )	break;
			}

			// successful -> start logging changes
			if( entry != new_symbol_table[ start ].size() ) {

				// print out new code
				fprintf( out, "%s", old_symbol.c_str() );

				// erase data
				read_symbol.erase( read_symbol.begin(), read_symbol.end() );
			} // end success
		}

		// line-wrap
		fprintf( out, "\n" );
	}

	fclose( out );
}

#undef old_symbol
#undef new_symbol


int Convert_Script( char *rom_name, char *symbol_name, char *table_name, char *out_name )
{
	// Open files
	list = fopen( symbol_name, "rb" );
	table = fopen( table_name, "r" );

	// Check for file errors
	if( !list ) {
		printf( "Error: Could not open file \"%s\"\n", symbol_name );
		return -1;
	}
	if( !table ) {
		printf( "Error: Could not open file \"%s\"\n", table_name );
		return -1;
	}

#if 0
	// Read in dictionaries
	rom = fopen( rom_name, "rb" );
	if( !list ) {
		printf( "Error: Could not open file \"%s\"\n", rom_name );
		return -1;
	}
	fseek( rom, 0x0000, SEEK_SET );
	fread( rom_page, 1, 0x4000, rom );
	fclose( rom );
#endif

	// Make text readable
	Load_Tables( 1 );
	Dump_Text( out_name );
	//Dump_Lists( "lists.txt" );

	// Done processing
	fclose( list );
	fclose( table );

	return 0;
}