#include <stdio.h>

int main( int argc, char **argv )
{
	unsigned char buffer[0x4000];
	unsigned char flag;
	int limit;
	int match;
	int size;
	int start;
	int cursor;
	int total;
	FILE *fp;

	// usage
	if( argc <= 3 ) {
		printf( "Usage: find_rom_space <file> <flag> <threshold>\n" );
		printf( "%08X %s %s %s", argc, argv[0], argv[1], argv[2] );
		return 0;
	}

	// check file validity
	fp = fopen( argv[1], "rb" );
	if( !fp ) {
		printf( "Error: could not open file '%s' for reading\n", argv[1] );
		return 0;
	}

	// load parameters
	sscanf( argv[2], "%02X", &flag );
	sscanf( argv[3], "%08X", &limit );

	match = 0;
	start = -1;
	cursor = 0;
	total = 0;

	// report header
	printf( "Memory report for '%s', flag = %s, limit = %s\n", argv[1], argv[2], argv[3] );
	printf( "-----------------------------------------------\n" );

	// examine file
	while( size = fread( buffer, 1, 0x4000, fp ) ) {
		int lcv;

		lcv = 0;

		// scan for contiguous memory blocks
		while( lcv < size ) {
			if( buffer[ lcv++ ] == flag ) {
				// hit: tally
				match++;

				// start file position
				if( start == -1 ) start = cursor;
			} else {
				// miss: reset
				if( match >= limit ) {
					printf( "%08X @ $%08X-%08X\n", match, start, start + match - 1 );
					total += match;
				}

				match = 0;
				start = -1;
			}

			// file position
			cursor++;
		}
	} // end read file

	// post-information
	printf( "Total: %X\n", total );

	// close shop
	fclose( fp );

	return 0;
}