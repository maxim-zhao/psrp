/*
Phantasy Star: Dual-Tile Encoder
*/

#include <stdio.h>


#define LIMIT 0x100	// alphabet size

//#define DEBUG			// debugging

#define START1 0x60				// starting font #
#define END1 0x60+0x80		// ending font #

// not used

#define START2 0xe0	// starting font #
#define END2 0x100		// ending font #


static int symbol_count[ LIMIT ][256];
static int symbol_dte[ LIMIT ][256];

//////////////////////////////////////////////////////

int DTE_Process( char *file_name, char *out_name )
{
	FILE *fp, *out, *table;
	int total = 0;
	int old_sym, new_sym;

	// open files
	fp = fopen( file_name, "rb" );
	out = fopen( out_name, "wb" );
	table = fopen( "dte_table.bin", "wb" );

	// check integrity
	if( !fp ) {
		printf( "Error: Could not open file \"%s\"\n", file_name );
		return -1;
	}
	if( !out ) {
		printf( "Error: Could not create file \"%s\"\n", out_name );
		return -1;
	}
	if( !table ) {
		printf( "Error: Could not create file \"%s\"\n", "dte_table.bin" );
		return -1;
	}

/*------------------------------------------*/

	// scan input file for all symbol permutations
	old_sym = fgetc( fp );
	while( ( new_sym = fgetc( fp ) ) != EOF ) {

		// tally count
		symbol_count[ old_sym ][ new_sym ]++;

		// scan next combo
		old_sym = new_sym;
	}

/*------------------------------------------*/

	// now find the best DTE matches
	for( int lcv = 0; lcv < 1; lcv++ ) {
		int dte_symbol;
		int end;

		if( lcv == 0 ) {
			dte_symbol = START1;
			end = END1;
		} else {
			dte_symbol = START2;
			end = END2;
		}

		for( ; dte_symbol < end; dte_symbol++ ) {
			int count = 0;

			for( int tree = 0; tree < LIMIT; tree++ ) {
				for( int symbol = 0; symbol < 256; symbol++ ) {

					if( symbol_count[ tree ][ symbol ] > count ) {
						count = symbol_count[ tree ][ symbol ];
						old_sym = tree;
						new_sym = symbol;
					}
				}
			} // end search all trees

	#ifdef DEBUG
			total += symbol_count[ old_sym ][ new_sym ];
			printf( "%02X: %02X -> %02X, %d\n", dte_symbol, old_sym, new_sym, count );
	#endif

			// flag this 2-byte sequence
			symbol_count[ old_sym ][ new_sym ] = -1;
			symbol_dte[ old_sym ][ new_sym ] = dte_symbol;

			// save to file
			fputc( old_sym, table );
			fputc( new_sym, table );
		}
	}

#ifdef DEBUG
	printf( "%d\n", total );
#endif

/*------------------------------------------*/

	fseek( fp, 0, SEEK_SET );

	// go through file again and convert DTEs
	old_sym = fgetc( fp );
	while( ( new_sym = fgetc( fp ) ) != EOF ) {
		
		// check match
		if( symbol_count[ old_sym ][ new_sym ] == -1 ) {
			// write out new pair
			fputc( symbol_dte[ old_sym ][ new_sym ], out );

			// reset sequence
			new_sym = fgetc( fp );
		} else {
			// no match, just raw byte
			fputc( old_sym, out );
		}

		// look at next window
		old_sym = new_sym;
	}

	// flush last byte
	fputc( old_sym, out );

/*------------------------------------------*/

	// done with files
	fclose( fp );
	fclose( out );
	fclose( table );

	return 0;
}