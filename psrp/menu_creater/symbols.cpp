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

#define LIST_EOF 0xDF		// end-of-file marker

FILE *list, *table, *pass1;

char line[8192];
int line_num;

vector<string> new_symbol_table[256];
vector<string> old_symbol_table[256];

int symbol_longest[256];

//////////////////////////////////////////////////////

int pointer_index = 0;
int pointers[] = {
	0x3807, 0x0000, 0x380d, 0x3801, 0x0000, 0x3813, 0x0000, 0x381f, 
	0x38cd, 0x38c7, 0x0000, 0x38e7, 0x3359, 0x3353, 
	0x0000, 0x358d, 0x3238, 0x0000, 0x323e, 0x3232, 0x0000, 0x3244, 
	0x0000, 0x3250, 0x7fee, 0x325c, 0x0000, 0x3321, 0x7fee, 
	0x3268, 0x329b, 0x32a1, 0x309c, 0x0000, 0x30f3, 
	0x0000, 0x32c1, 0x0000, 0x37d0, 0x309f, 0x0000, 0x30f6, 0x0000, 0x32c4, 
	0x0000, 0x37d3, 0x7fee, 0x3048, 0x0000, 0x3103, 0x0000, 0x3226, 
	0x304e, 0x0000, 0x30a5, 0x0000, 0x310a, 0x3084, 0x0000, 0x30db, 
	0x305b, 0x0000, 0x30b2, 0x0000, 0x3118, 0x3084, 0x0000, 0x30db, 
	0x3068, 0x0000, 0x30bf, 0x0000, 0x3126, 0x3084, 0x0000, 0x30db, 
	0x3075, 0x0000, 0x30cc, 0x0000, 0x3134, 0x3084, 0x0000, 0x30db, 
	0x37ca, 0x378e, 0x0000, 0x37ab, 0x0000, 0x37e4, 0x0000, 0x37f5, 
	0x38a1, 0x389b, 0x0000, 0x38bb, 0x3883, 0x387d, 
	0x0000, 0x388f, 0x302b, 0x301b, 0x0000, 0x303c, 0x7fee, 
	0x7fee, 0x7fee, 0x7fee, 0x7fee, 0x7fee, 
	0x35b0, 0x359b, 0x0000, 0x35ea, 0x7fee, 0x7fee, 
	0x7fee, 0x7fee, 0x7fee, 0x7fee, 0x7fee, 
	0x7fee, 0x7fee, 0x7fee, 0x356c, 0x356f, 
	0x7fee, 0x355a, 0x0000, 0x3566, 0x3908, 0x390b, 
	0x3926, 0x0000, 0x3938, 0x0000, 0x394a, 0x0000, 0x395c, 0x0000, 0x396e, 
	0x3929, 0x0000, 0x393b, 0x0000, 0x394d, 0x0000, 0x395f, 0x0000, 0x3971, 
	0x397a, 0x397d, 0x7fee, 0x3902, 0x0000, 0x39e5, 
	0x7fee, 0x382c, 0x0000, 0x3871, 0x7fee, 0x3642, 
	0x0000, 0x377b, 0x326e, 0x0000, 0x3648, 0x0000, 0x3832, 0x0000, 0x3b23, 
	0x3274, 0x0000, 0x364e, 0x0000, 0x3838, 0x0000, 0x3b29, 0x328c, 
	0x0000, 0x3681, 0x0000, 0x3860, 0x0000, 0x3b32, 0x328f, 0x0000, 0x3684, 
	0x0000, 0x3863, 0x0000, 0x3b35, 0x365c, 0x365f, 0x7fee, 
	0x3b1b, 0x0000, 0x3b44, 0x7fee, 0x39f1, 0x0000, 0x3aca, 
	0x39f7, 0x39fd, 0x3a37, 0x3a3a, 0x7fee, 
	0x3b52, 0x0000, 0x3b79, 0x3b5d, 0x7fee, 0x35cf, 
	0x7fee, 0xffff,
};

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

			// add header nybble if needed
			if( new_symbol.size() & 1 )
				new_symbol = '0' + new_symbol;

			if( !direction ) {

				// string not found identification
				if( symbol_longest[ old_symbol[0] ] < old_symbol.length() )
					symbol_longest[ old_symbol[0] ] = old_symbol.length();

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

void Find_Entry( char *&pText, int &index )
{
	string lookup;
	int start;

	// not found
	index = -1;
	start = *pText;

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
	int menu_width, menu_height, menu_phase, menu_border;
	FILE *menu_out;

	// Init table entries
	table_number = 1;
	table_offset = 0;
	table_length = 0;

	menu_width = 0;
	menu_height = 0;
	menu_phase = 0;
	menu_border = 0;

	menu_out = fopen( "menu_list.txt", "w" );

	printf( "Table location data\n" );

	// Read in dictionary entries
	while( fgets( line, sizeof( line ), list ) ) {
		char *pText;
		int line_len;
		string out_buffer;

		// internal counter
		line_num++;
		line_len = 0;
		pText = line;

		// remove newline
		if( line[ strlen( line ) - 1 ] == 0x0a )
			line[ strlen( line ) - 1 ] = 0;

		// skip comments or eos
		if( *pText == ';' || *pText == 0 )
			continue;

		// special case: bottom border only
		if( menu_border == 3 ) {
			menu_phase = 2;

			// bottom-left corner NT
			fputc( 0xf1, pass1 );
			fputc( 0x15, pass1 );

			table_offset += 2;
			table_length += 2;

			// print bottom border NT
			for( int lcv = 0; lcv < menu_width - 4; lcv += 2 ) {
				fputc( 0xf2, pass1 );
				fputc( 0x15, pass1 );

				table_offset += 2;
				table_length += 2;
			}

			// bottom-right corner NT
			fputc( 0xf1, pass1 );
			fputc( 0x17, pass1 );
	
			table_offset += 2;
			table_length += 2;

			menu_height--;
		}

		// check for new table altogether
		if( *pText == '#' && strlen( line ) == 1 ) {

			if( pointers[ pointer_index ] == 0xffff ) return;

			// log statistics
			printf( "(line %d) Table %02X: Start $%04X, Last length $%04X",
				line_num, table_number, 0xac81 + table_offset, table_length );
			printf( "\n" );

			// window rewiring
			do {
				if( pointers[ pointer_index ] == 0x0000 ) pointer_index++;
				fprintf( menu_out, "%x hex_%02x%02x.bin\n",
					pointers[ pointer_index ], ( 0xac81 + table_offset ) & 0xff,
					( ( 0xac81 + table_offset ) >> 8 ) & 0xff );
				pointer_index++;
			} while( pointers[ pointer_index ] == 0x0000 );

			// re-init
			menu_width = 0;
			menu_height = 0;
			menu_phase = 0;
			menu_border = 0;

			table_number++;
			table_length = 0;
			continue;
		}

		// read window parameters
		if( !menu_phase ) {
			sscanf( pText, "%x %x %x", &menu_height, &menu_width, &menu_border );

			// window rewiring
			do {
				if( pointers[ pointer_index ] == 0x0000 ) pointer_index++;
				fprintf( menu_out, "%x hex_%02x%02x.bin\n",
					pointers[ pointer_index ], menu_width & 0xff, menu_height & 0xff );
				pointer_index++;
			} while( pointers[ pointer_index ] == 0x0000 );

			menu_phase = 1;

			// draw top border here
			if( menu_border == 0x00 || menu_border == 0x03 ||
					menu_border == 0x04 || menu_border == 0x05 ) continue;

			// top-left corner NT
			fputc( 0xf1, pass1 );
			fputc( 0x11, pass1 );

			table_offset += 2;
			table_length += 2;

			// print top border NT
			for( int lcv = 0; lcv < menu_width - 4; lcv += 2 ) {
				fputc( 0xf2, pass1 );
				fputc( 0x11, pass1 );

				table_offset += 2;
				table_length += 2;
			}

			// top-right corner NT
			fputc( 0xf1, pass1 );
			fputc( 0x13, pass1 );
	
			table_offset += 2;
			table_length += 2;

			menu_height--;
			continue;
		}

		// dimensions only
		if( menu_border == 4 ) continue;

		// do the conversion
		while( *pText ) {
			int entry;
			int start;

			// grab symbol
			start = *pText;

			// check if we have a dictionary entry
			Find_Entry( pText, entry );
			if( entry == -1 ) continue;

			// successful -> start logging changes
			for( int lcv2 = 0; lcv2 < new_symbol.length(); lcv2 += 2 ) {
				int code;

				// calculate new hex code
				sscanf( new_symbol.c_str() + lcv2, "%02X", &code );

				// buffer out data
				out_buffer += code;
			}

			// line length checking
			line_len += old_symbol.length();

			// update file position
			//table_offset += old_symbol.length();
			//table_length += old_symbol.length();

			table_offset += 2;
			table_length += 2;
		}

		if( menu_border != 0x05 ) {
			// left border NT
			fputc( 0xf3, pass1 );
			fputc( 0x11, pass1 );

			table_offset += 2;
			table_length += 2;
		}

		// commit changes: length + text
		//fputc( line_len, pass1 );
		fwrite( out_buffer.c_str(), 1, out_buffer.length(), pass1 );

		if( menu_border != 0x05 ) {
			// right border NT
			fputc( 0xf3, pass1 );
			fputc( 0x13, pass1 );

			table_offset += 2;
			table_length += 2;
		}

		// close window
		menu_height--;
		if( menu_height == 1 ) {

			menu_phase = 2;
			if( menu_border == 0x00 || menu_border == 0x02 ||
					menu_border == 0x04 || menu_border == 0x05 ) continue;

			// bottom-left corner NT
			fputc( 0xf1, pass1 );
			fputc( 0x15, pass1 );

			table_offset += 2;
			table_length += 2;

			// print bottom border NT
			for( int lcv = 0; lcv < menu_width - 4; lcv += 2 ) {
				fputc( 0xf2, pass1 );
				fputc( 0x15, pass1 );

				table_offset += 2;
				table_length += 2;
			}

			// bottom-right corner NT
			fputc( 0xf1, pass1 );
			fputc( 0x17, pass1 );
	
			table_offset += 2;
			table_length += 2;

			menu_height--;
			continue;
		}
	} // end while

		// custom stop marker
	printf( "\n" );

	fclose( menu_out );
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
	Process_Text();

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


#define EOS 0xDB

void Dump_Text( char *out_name )
{
	FILE *out;
	int symbol = 0;

	// Init table entries
	table_number = 1;
	table_offset = 0;
	table_length = 0;

	// Read in each script entry
	while( symbol != EOF ) {
		int voice_mark = 0;
		bool log = 0;

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

			// Add UTF-8 header
			fputc( 0xef, out );
			fputc( 0xbb, out );
			fputc( 0xbf, out );
		}

		do {

			// Go through each character in this string
			symbol = fgetc( list );
			if( symbol == EOF ) break;

			// Log status
			if( !log ) {
				fprintf( out, "[%02X]", table_offset );
				log = 1;
			}

			// voice marks
			if( symbol >= 0x7a && symbol <= 0x7d ) {
				voice_mark = symbol;
			}

			else if( symbol < 0xc8 ) {

				// normal symbols
				fwrite( old_symbol.c_str(), 1 , old_symbol.length(), out );

				// add markings now
				if( voice_mark ) {
					symbol = voice_mark;
					voice_mark = 0;
	
					fwrite( old_symbol.c_str(), 1 , old_symbol.length(), out );
				}
			} 

			// control codes
			else {
				switch( symbol ) {
				case 0xc9: fprintf( out, "<line>" ); break;
				case 0xcc: fprintf( out, "<number>" ); break;
				case 0xcd: fprintf( out, "<name>" ); break;
				case 0xd1: fprintf( out, "<item>" ); break;
				case 0xd2: fprintf( out, "<spell>" ); break;
				case 0xd4: fprintf( out, "<blink pause>" ); break;
				case 0xd6: fprintf( out, "<0.5-sec delay>" ); break;
				case 0xd7: fprintf( out, "<pause>" ); break;
				case 0xd8: fprintf( out, "<1.5-sec delay>" ); break;
				case 0xda: Lookup( 0x7edd0 - 0x7c000, out );	break;
				case 0xdb: fprintf( out, "<end>" ); break;
				default:
					printf( "ERROR: Unknown code %02X @ %06X\n", symbol, ftell( list ) );
					fprintf( out, "<%02X>", symbol );
					break;
				}
			}
		}	while( symbol != EOS );

		if( symbol == EOF ) break;

		// update records
		table_offset++;
		if( table_offset == 256 ) {
			table_offset = 0;
			table_number++;
			fclose( out );
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

	// Read in dictionaries
	rom = fopen( rom_name, "rb" );
	if( !list ) {
		printf( "Error: Could not open file \"%s\"\n", rom_name );
		return -1;
	}
	fseek( rom, 0x7c000, SEEK_SET );
	fread( rom_page, 1, 0x4000, rom );
	fclose( rom );

	// Make text readable
	Load_Tables( 1 );
	Dump_Text( out_name );

	// Done processing
	fclose( list );
	fclose( table );

	return 0;
}