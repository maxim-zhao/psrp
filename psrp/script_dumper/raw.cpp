//
// Phantasy Star: Raw compression
//

#include <stdio.h>

#define EOS1	0x56			// end-of-string
#define EOS2	0x57			// delay
#define EOS3	0x58			// wait, eos

unsigned char rom_page[0x4000];

/////////////////////////////////////////////////
/////////////////////////////////////////////////

int Dump_Raw( char *file, char *file_out )
{
	FILE *in, *out;
	int lcv;

	// check file integrity
	in = fopen( file, "rb" );
	if( !in ) {
		printf( "Error: Could not read from file \"%s\"\n", file );
		return -1;
	}

	out = fopen( file_out, "wb" );
	if( !out ) {
		printf( "Error: Could not write to file \"%s\"\n", file_out );
		return -1;
	}

	///////////////////////////////////////////

	// Dump each text bank
	for( int bank = 0; bank < 1; bank++ ) {
		int start, end, size;
		unsigned short pointers[0x400];

		// Load text bank parameters
		switch( bank ) {
		case 0:
			start = 0x80b2;
			end = 0x835c;
			break;
		}
		size = ( end - start ) / 2;

		// Grab pointer table
		fseek( in, start, SEEK_SET );
		fread( pointers, 1, size * 2, in );
		pointers[ size ] = 0xab1f;

		// Log data
		printf( "Text bank %d\n", bank );
		fwrite( &size, 1, 4, out );

		// Dump each string
		for( lcv = 0; lcv < size; lcv++ ) {
			char byte;
			char buffer[0x400];
			int ptr;

			// Log data
			printf( "[%04X] = %03X\n", ftell( in ), ( lcv+1 ) * 2 );
			ptr = 0;

			// Keep emitting until limit reached
			do {
				byte = fgetc( in );
				buffer[ ptr++ ] = byte;
			} while( ftell( in ) < pointers[ lcv+1 ] );

			// Emit data
			fwrite( &ptr, 1, 4, out );
			fwrite( buffer, 1, ptr, out );
		}

		printf( "\n-----------------\n\n" );
	}

	// Log data
	printf( "Text bank 1\n" );
	lcv = 0;

	while( ftell( in ) < 0xbd93 ) {
		char byte;

		// Log data
		printf( "[%04X] = %03X\n", ftell( in ), ( lcv++ ) * 2 );

		// Keep emitting until stop code reached
		do {
			byte = fgetc( in );
			fputc( byte, out );
		} while( byte != EOS1 && byte != EOS2 && byte != EOS3 );
	}

	///////////////////////////////////////////

	fclose( in );
	fclose( out );

	return 0;
}
