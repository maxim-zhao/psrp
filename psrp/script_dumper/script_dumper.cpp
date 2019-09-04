/*
Phantasy Star: Script Dumper
*/

#include <cstdio>

extern int Dump_Raw( char *file, char *file_out );
extern int Convert_Script( char *rom_name, char *symbol_name, char *table_name, char *out_name );


int main( int argc, char **argv )
{
	// Assert proper usage
	if( argc != 3 ) {
		printf( "Usage: script_dumper <rom file> <table file>\n" );
		return -1;
	}

	// phase 1: Raw decoder
	if( Dump_Raw( argv[1], "pass1.bin" ) )
		return -1;

	// phase 2: Script conversion
	Convert_Script( argv[1], "pass1.bin", argv[2], "script" );

	return 0;
}