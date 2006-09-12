/*
Phantasy Star: List Creater
*/

#include <stdio.h>

#define DTE

extern int Convert_Symbols( char *list_name, char *table_name, char *out_name);
extern int DTE_Process( char *file_name, char *out_name );
extern void Huffman_Compress( char *file_in, char *file_out, char *tree_out );

//////////////////////////////////////////////////////////////

int Split_Files()
{
	FILE *fp, *out1, *out2, *out3, *out4, *out5;

	// open files
	fp = fopen( "lists.bin", "rb" );
	out1 = fopen( "final1.bin", "wb" );
	out2 = fopen( "final2.bin", "wb" );
	out3 = fopen( "final3.bin", "wb" );
	out4 = fopen( "final4.bin", "wb" );
	out5 = fopen( "final5.bin", "wb" );

	// check integrity
	if( !fp ) {
		printf( "Error: Could not open file \"%s\"\n", "lists.bin" );
		return -1;
	}
	if( !out1 ) {
		printf( "Error: Could not create file \"%s\"\n", "final1.bin" );
		return -1;
	}
	if( !out2 ) {
		printf( "Error: Could not create file \"%s\"\n", "final2.bin" );
		return -1;
	}
	if( !out3 ) {
		printf( "Error: Could not create file \"%s\"\n", "final3.bin" );
		return -1;
	}
	if( !out4 ) {
		printf( "Error: Could not create file \"%s\"\n", "final4.bin" );
		return -1;
	}
	if( !out5 ) {
		printf( "Error: Could not create file \"%s\"\n", "final5.bin" );
		return -1;
	}

/*------------------------------------------*/

	char buffer[0x1000];
	int size;

	fread( buffer, 1, 0x1000, fp );

	// check for overflow
	if( ftell( fp ) > 0x5F6 ) {
		int left;

		printf( "WARNING: Lists.bin split into 5 files\n" );

//-----------------------------------------------------------

		// split to file1
		fwrite( buffer, 1, 0x5F5, out1 );
		size = 0x5f5;

		// interim eof
		fputc( 0xDF, out1 );

//-----------------------------------------------------------

		// split to file2
		left = ftell( fp ) - size;
		if( left > 0 ) {
			fwrite( buffer + size, 1, left > 0x13f ? 0x13f : left - 1, out2 );
			size += 0x13f;
		}

		// interim eof
		fputc( 0xDF, out2 );

//-----------------------------------------------------------

		// split to file3
		left = ftell( fp ) - size;
		if( left > 0 ) {
			fwrite( buffer + size, 1, left > 0xa7 ? 0xa7 : left - 1, out3 );
			size += 0xa7;
		}

		// interim eof
		fputc( 0xDF, out3 );

//-----------------------------------------------------------

		// split to file4
		left = ftell( fp ) - size;
		if( left > 0 ) {
			fwrite( buffer + size, 1, left > 0x7d ? 0x7d : left - 1, out4 );
			size += 0x7d;
		}

		// interim eof
		fputc( 0xDF, out4 );

//-----------------------------------------------------------

		// split to file5
		left = ftell( fp ) - size;
		if( left > 0 ) {
			fwrite( buffer + size, 1, left, out5 );
			size += 0x76;
		}

		if( left >= 0x76 ) {
			printf( "\nWARNING: Not enough space. Must create more." );
		}

		// interim eof
		//fputc( 0xDF, out5 );
	}

/*------------------------------------------*/

	fclose( fp );
	fclose( out1 );
	fclose( out2 );
	fclose( out3 );
	fclose( out4 );

	return 0;
}


int main( int argc, char **argv )
{
	// Assert proper usage
	if( argc != 3 ) {
		printf( "Usage: list_creater <list file> <table file>\n" );
		return -1;
	}

	// phase 1: text conversion
	if( Convert_Symbols( argv[1], argv[2], "pass1.bin" ) ) return -1;

#ifdef DTE
	// phase 2: DTE conversion
	//if( DTE_Process( "pass1.bin", "lists.bin" ) ) return -1;

	// phase 3: split output
	//Split_Files();
#else
	// phase 2: Huffman encoding
	Huffman_Compress( "pass1.bin", "final.bin", "tree.bin" );
#endif

	printf( "You need to modify: tools\\asm\\vars.asm, and recompile t1c*.asm" );

	return 0;
}