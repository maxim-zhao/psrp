/*
Phantasy Star: Bitmap Decoder
*/

#include <stdio.h>

extern void PSG_Decode( FILE *fp, FILE *out, int tiles, int offset );
//void Bitmap_ToGG( FILE *out );

int main( int argc, char **argv )
{
	FILE *rom, *out;
	int offset, tiles;

	if( argc < 5 ) {
		printf( "Usage: psg_decode <rom file> <offset> <# tiles> <output file>\n" );
		return -1;
	}

	// check for file errors
	rom = fopen( argv[1], "rb" );
	out = fopen( argv[4], "wb" );
	if( !rom ) {
		printf( "Error: Could not open file '%s' for reading\n", argv[1] );
		return -1;
	}
	if( !out ) {
		printf( "Error: Could not open file '%s' for writing\n", argv[4] );
		return -1;
	}

	sscanf( argv[2], "%X", &offset );
	sscanf( argv[3], "%X", &tiles );

	// uncrunch data
	PSG_Decode( rom, out, tiles, offset );
	//Bitmap_ToGG( out );

	fclose( rom );
	fclose( out );

	return 0;
}