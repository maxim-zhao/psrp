/*
Generic file inserter
*/

#include <stdio.h>
#include <string.h>

FILE *list, *image;
char line[256];
int file_num = 0;

int main( int argc, char **argv )
{
	int disable = 0;

	// Assert proper usage
	if( argc != 3 ) {
		printf( "Usage: rom_insert <image name> <list name>\n" );
		return 0;
	}

	// Open files
	image = fopen( argv[1], "r+b" );
	list = fopen( argv[2], "r" );

	// Check for file errors
	if( !image ) {
		printf( "Error: Could not open file \"%s\"\n", argv[1] );
		return 0;
	}
	if( !list ) {
		printf( "Error: Could not open file \"%s\"\n", argv[2] );
		return 0;
	}

	// Batch process updates
	while( fgets( line, sizeof( line ), list ) ) {
		int argc, offset;
		char update[256];
		FILE *fp;

		// remove newline
		if( line[ strlen( line ) - 1 ] == 0x0a )
			line[ strlen( line ) - 1 ] = 0;

		// comment
		if( line[0] == ';' ) continue;

		// soft-disable
		if( line[0] == '#' ) {
			disable = !disable;
		}
		if( disable ) continue;
		
		// grab information
		argc = sscanf( line, "%X %s", &offset, &update );
		
		// check sufficient parameters
		if( argc >= 2 ) {

			// check for *-byte hex insertions
			if( strlen( update ) >= 4 ) {
				if( update[0] == 'h' && update[1] == 'e' &&
						update[2] == 'x' && update[3] == '_' ) {
					int lcv;

					fseek( image, offset, SEEK_SET );

					// insert *-byte hex
					for( lcv = 4; lcv < 100; lcv += 2 ) {
						int hex_num;
						int args;
						
						// check for byte
						args = sscanf( update + lcv, "%02X", &hex_num );
						if( args ) fputc( hex_num, image );
						else break;
					}
					continue;
				}
			}

			fp = fopen( update, "rb" );

			// check for file error
			if( !fp ) {
				printf( "Error: Could not open file %s\n", update );
			}
			else {
				char data[1024];
				int read;

				// set write cursor
				fseek( image, offset, SEEK_SET );

				// transfer bytes
				while( read = fread( (void *) data, 1, sizeof( data ), fp ) ) {
					fwrite( (void *) data, 1, read, image );
				}

				// done with file
				fclose( fp );
			}
		}
	} // end while

	// Done processing
	fclose( image );
	fclose( list );

	return 0;
}