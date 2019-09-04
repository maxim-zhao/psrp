/*
Phantasy Star: Menu Creater
*/

#include <cstdio>

extern int Convert_Symbols( char *list_name, char *table_name, char *out_name);

int main( int argc, char **argv )
{
	// Assert proper usage
	if( argc != 3 ) {
		printf( "Usage: list_creater <list file> <table file>\n" );
		return -1;
	}

	// phase 1: text conversion
	if( Convert_Symbols( argv[1], argv[2], "pass1.bin" ) ) return -1;

	return 0;
}