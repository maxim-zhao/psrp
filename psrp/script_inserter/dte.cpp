/*
Phantasy Star: Dual-Tile Encoder
*/

#include <stdio.h>


#define LIMIT 0xdc	// alphabet size
#define EOS 0xDB		// end-of-string

//#define DEBUG			// debugging

#define START 0x93	// starting font #
#define END 0xc8		// ending font #


static int symbol_count[ LIMIT ][256];
static int symbol_dte[ LIMIT ][256];

//////////////////////////////////////////////////////

int DTE_Process( char *file_name, char *out_name )
{
	FILE *fp, *out;
	int total = 0;
	int old_sym, new_sym;

	// open files
	fp = fopen( file_name, "rb" );
	out = fopen( out_name, "wb" );

	// check integrity
	if( !fp ) {
		printf( "Error: Could not open file \"%s\"\n", file_name );
		return -1;
	}
	if( !out ) {
		printf( "Error: Could not create file \"%s\"\n", out_name );
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
	for( int dte_symbol = START; dte_symbol < END; dte_symbol++ ) {
		int count = 0;

		for( int tree = 0; tree < LIMIT; tree++ ) {
			for( int symbol = 0; symbol < 256; symbol++ ) {

				if( symbol_count[ tree ][ symbol ] > count &&
					  tree != EOS && symbol != EOS ) {
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

	return 0;
}