/*
Phantasy Star: Substring Table Creater
*/

#include <stdio.h>

#include <deque>
#include <string>

using namespace::std;

#define START_CODE 0x60
#define END_CODE 0x60 + 0x60

#define SWITCH_CODE 0xFFFF
#define START_CODE2 0xFFFF

int main( int argc, char **argv)
{
	FILE *fp, *out, *dict;
	char line[8192];
	int code = START_CODE;
	deque<string> list;
	int code_amount;

	if( argc < 2 ) {
		printf( "Usage: substring_formatter.exe <# codes>\n" );
		return 0;
	}

	sscanf( argv[1], "%X", &code_amount );

	// open files
	fp = fopen( "words.txt", "r" );
	out = fopen( "words_final.txt", "w" );
	dict = fopen( "dict.txt", "w" );

	// read each string and add conversion code
	while( fgets( line, sizeof( line ), fp ) ) {

		// remove '\n'
		if( line[ strlen( line ) - 1 ] == 0x0a ) line[ strlen( line ) - 1 ] = 0;

		// dictionary word
		fprintf( dict, "%s\n", line );

		// print <string>
		fprintf( out, "%02X=%s\n", code, line );

		// queue up
		list.push_back( line );

		// bump substring assignment range
		code++;

		// formatting
		if( code % 16 == 0 ) {
			fprintf( out, "\n" );

			// print <string> / <space><string>
			for( int lcv = code - 16; lcv < code; lcv++ ) {
				//fprintf( out, "D0%02X= %s\n", lcv, list[0].c_str() );
				list.pop_front();
			}

			fprintf( out, "\n" );
		}

		if( code == SWITCH_CODE ) code = START_CODE2;
		//if( code == END_CODE ) break;
		if( code == START_CODE + code_amount ) break;
	}

	// dictionary EOF
	fprintf( dict, "#\n" );

	fclose( fp );
	fclose( out );
	fclose( dict );

	return 0;
}