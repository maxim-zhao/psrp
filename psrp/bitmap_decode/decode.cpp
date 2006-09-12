/*
Phantasy Star: Bitmap Decoder
*/

#include <stdio.h>

extern void RLE_Decode( FILE *fp, FILE *out, int offset );
//void Bitmap_ToGG( FILE *out );

int main( int argc, char **argv )
{
	FILE *rom, *out;
	int offset;

	if( argc < 4 ) {
		printf( "Usage: bitmap_decode <rom file> <offset> <output file>\n" );
		return -1;
	}

	// check for file errors
	rom = fopen( argv[1], "rb" );
	out = fopen( argv[3], "wb" );
	if( !rom ) {
		printf( "Error: Could not open file '%s' for reading\n", argv[1] );
		return -1;
	}
	if( !out ) {
		printf( "Error: Could not open file '%s' for writing\n", argv[3] );
		return -1;
	}

	sscanf( argv[2], "%X", &offset );

	// uncrunch data
	RLE_Decode( rom, out, offset );
	//Bitmap_ToGG( out );

	fclose( rom );
	fclose( out );

	return 0;
}