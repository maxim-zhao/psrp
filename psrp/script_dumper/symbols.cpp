/*
Phantasy Star: Symbol Converter
*/

#ifdef _DEBUG
	#pragma warning( disable: 4786 )	// 255 character debug limit
#endif

#include <wchar.h>
#include <stdio.h>
#include <string.h>

#include <string>
#include <vector>

using std::string;
using std::vector;

#define LIST_EOF 0xFF		// end-of-file marker

#define EOS1 0x58				// wait
#define EOS2 0x57				// delay
#define EOS3 0x56				// end-of-string

FILE *list, *table, *pass1;

char line[256];
int line_num;

vector<string> new_symbol_table[256];
vector<string> old_symbol_table[256];

int symbol_largest[256];

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
	memset( symbol_largest, 0, sizeof( symbol_largest ) );

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
		for( int lcv = 0; lcv < strlen( line ); lcv++ ) {
			
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

			if( !direction ) {

				// string not found identification
				if( symbol_largest[ old_symbol[0] ] < old_symbol.length() )
					symbol_largest[ old_symbol[0] ] = old_symbol.length();

				// use indexed table for speed boost
				old_symbol_table[ old_symbol[0] ].push_back( old_symbol );
				new_symbol_table[ old_symbol[0] ].push_back( new_symbol );
			} else {
				int index;

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

void Convert_Text()
{
	string read_symbol;
	int start;

	// Init table entries
	table_number = 1;
	table_offset = 0;
	table_length = 0;
	printf( "Table location data  [WARNING: Offsets are rough locations]\n" );

	// Read in dictionary entries
	while( fgets( line, sizeof( line ), list ) ) {

		// internal counter
		line_num++;

		// remove newline
		if( line[ strlen( line ) - 1 ] == 0x0a )
			line[ strlen( line ) - 1 ] = 0;

		// skip comments or eos
		if( line[0] == ';' || line[0] == 0 )
			continue;

		// check for new table altogether
		if( line[0] == '#' && strlen( line ) == 1 ) {

			// log statistics
			printf( "(line %d) Table %02X: End $%04X, Length $%04X\n",
				line_num, table_number, table_offset, table_length );

			// re-init
			table_number++;
			table_length = 0;
			continue;
		}

		// prefix byte: length
		fputc( strlen( line ), pass1 );
		table_offset++;
		table_length++;

		// do the conversion
		for( int lcv = 0; lcv < strlen( line ); lcv++ ) {

			// grab next character
			if( read_symbol == "" ) start = line[ lcv ];
			read_symbol += line[ lcv ];

			// check if the entry exists
			for( int entry = 0; entry < old_symbol_table[ start ].size(); entry++ ) {
				if( read_symbol == old_symbol )	break;
			}

			// successful -> start logging changes
			if( entry != old_symbol_table[ start ].size() ) {

				// add header nybble if needed
				if( new_symbol.size() & 1 )
					new_symbol = '0' + new_symbol;

				// print out new code
				for( int lcv2 = 0; lcv2 < new_symbol.length(); lcv2 += 2 ) {
					int code;

					// calculate new hex code
					sscanf( new_symbol.c_str() + lcv2, "%02X", &code );

					// write out data
					fputc( code, pass1 );
				}

				// update file position
				table_offset += read_symbol.length();
				table_length += read_symbol.length();

				// erase data
				read_symbol.erase( read_symbol.begin(), read_symbol.end() );
			} // end success

			// assert symbol is possibly in the dictionary
			else if( read_symbol.length() + 1 > symbol_largest[ start ] ) {

				// log error
				printf( "Error: Symbol not found in table on line %d - %s\n", line_num, read_symbol.c_str() );

				// erase data
				read_symbol.erase( read_symbol.begin(), read_symbol.end() );
			}
		}
	} // end while

	// assert symbol is possibly in the dictionary
	if( read_symbol.length() + 1 > symbol_largest[ start ] ) {

		// log error
		printf( "Error: Symbol not found in table on line %d - %s\n", line_num, read_symbol.c_str() );
	}

	// place EOF marker
	fputc( LIST_EOF, pass1 );

	// log statistics
	printf( "(line %d) Table %02X: End $%04X, Length $%04X\n",
		line_num, table_number, table_offset, table_length );
	printf( "\n" );
}

#undef old_symbol
#undef new_symbol


int Convert_Symbols( char *list_name, char *table_name, char *out_name )
{
	// Open files
	list = fopen( list_name, "r" );
	table = fopen( table_name, "r" );
	pass1 = fopen( out_name, "wb" );

	// Check for file errors
	if( !list ) {
		printf( "Error: Could not open file \"%s\"\n", list_name );
		return -1;
	}
	if( !table ) {
		printf( "Error: Could not open file \"%s\"\n", table_name );
		return -1;
	}
	if( !pass1 ) {
		printf( "Error: Could not create file \"%s\"\n", out_name );
		return -1;
	}

	Load_Tables( 0 );
	Convert_Text();

	// Done processing
	fclose( list );
	fclose( table );
	fclose( pass1 );

	return 0;
}

/////////////////////////////////////////////////////

FILE *rom;
extern unsigned char rom_page[0x4000];

#define old_symbol old_symbol_table[ start ][ entry ]
#define new_symbol new_symbol_table[ start ][ entry ]


void Lookup( int ptr, FILE *out )
{
	int entry;
	int length;
	string read_symbol;
	int start;

	// skip number of dictionary entries
	entry = fgetc( list );

	if( ftell(list) >= 0x1865 )
		entry = entry;

	while( entry-- ) {
		// text length + length byte
		ptr += rom_page[ ptr ];
		ptr++;
	}

	// skip length byte
	length = rom_page[ ptr ];
	ptr++;

	// toss out each regular character
	while( length-- ) {
		int symbol;
		int entry;
		char hex[3];
		
		symbol = rom_page[ ptr++ ];
		//fwrite( old_symbol.c_str(), 1, old_symbol.length(), out );

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