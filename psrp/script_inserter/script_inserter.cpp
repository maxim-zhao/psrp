/*
Phantasy Star: Script Inserter
*/

#include <cstdio>


extern int Convert_Symbols( char *list_name, char *table_name, char *out_name );
extern int DTE_Process( char *file_name, char *out_name );
extern void Huffman_Compress( char *file_in, char *file_out, char *tree_out );


int main( int argc, char **argv )
{
	// Assert proper usage
	if( argc != 3 ) {
		printf( "Usage: script_inserter <script name> <table file>\n" );
		return -1;
	}

	// phase 1: Script conversion
	Convert_Symbols( argv[1], argv[2], "pass1.bin" );

	// phase 2: Huffman encoding
	Huffman_Compress( "pass1.bin", "script", "script_trees.bin" );

	return 0;
}