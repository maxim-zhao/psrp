/*
Phantasy Star: RLE Compression
*/

#include <stdio.h>

#include <vector>
#include <deque>

#define DEBUG_RLE

using namespace std;

typedef struct
{
	int pos;
	int ptr;
	int len;
	int type;
} find;

unsigned char buffer[0x4000];
short buf_ptr;

///////////////////////////////////////////////////////

int ptr = 0;
int size = 0;

int min_match = 1+1;
int max_match = 0x7f;			// 7-bits


void Find_RLE( int buf_ptr, int &length, int &pos )
{
	int longest_length = 1;
	int longest_ptr = buf_ptr;

	// find longest RLE string
	for( int lcv = buf_ptr; lcv + 4 < size; lcv += 4 ) {
		if( buffer[ lcv ] != buffer[ lcv+4 ] ) break;
		longest_length++;

		if( longest_length == max_match ) break;
	}

	// output findings
	length = longest_length;
	pos = longest_ptr;
}


void RLE_Encode( FILE *in, FILE *out )
{
	int loops;
	vector< find > table;

	// init
	buf_ptr = 0;
	loops = 0;

	// read whole bitmap
	size = fread( buffer, 1, 0x4000, in );
	fclose( in );

	// buf_ptr going through each color plane
	while( loops < 4 ) {
		find rec;
		int raw_count;

		buf_ptr = loops;
		raw_count = 0;
		table.clear ();

///////////////////////////////////////////////////////////////

		// Step 1: Find RLE strings

		while( buf_ptr < size ) {
			int length, pos;

			if( loops == 1 )
				loops = 1;

			// Go find the longest substring match
			Find_RLE( buf_ptr, length, pos );

			// Raw + 2 RLE's + Raw = wastes 1 byte
			if( length == min_match ) {
				Find_RLE( buf_ptr + 8, length, pos );

				if( length == 1 && raw_count ) {
					// No substrings found; try again
					buf_ptr += 4;
					raw_count++;
					continue;
				}

				Find_RLE( buf_ptr, length, pos );
			}

			if( length >= min_match ) {

				// Add raw record
				while( raw_count ) {
					rec.pos = -1;
					rec.len = raw_count > max_match ? max_match : raw_count;
					rec.type = 1;

					table.push_back( rec );
					
					raw_count -= max_match;
					if( raw_count < 0 ) raw_count = 0;
				}

				// Found substring match; record and re-do
				rec.pos = buf_ptr;
				rec.len = length;
				rec.type = 2;

				table.push_back( rec );

				// Fast update
				buf_ptr += 4 * length;
			}
			else {
				// No substrings found; try again
				buf_ptr += 4;
				raw_count++;
			}
		} // end scan

		// Add raw record
		while( raw_count ) {
			rec.pos = -1;
			rec.len = raw_count > max_match ? max_match : raw_count;
			rec.type = 1;

			table.push_back( rec );
					
			raw_count -= max_match;
			if( raw_count < 0 ) raw_count = 0;
		}

		// insert dummy entry
		rec.pos = -1;
		rec.type = 0;
		table.push_back( rec );

///////////////////////////////////////////////////////////////

		// Step 2: Prepare encoding methods
		
		int rec_ptr = 0;

		buf_ptr = loops;

		while( 1 ) {
			rec = table[ rec_ptr ];

#ifdef DEBUG_RLE
			printf( "%04X, %d\n", ftell( out ), rec.type );
#endif

			// exit condition
			if( rec.type == 0 ) break;

			if( rec.type == 2 ) {

				// RLE
				fputc( rec.len, out );
				fputc( buffer[ buf_ptr ], out );

				buf_ptr += rec.len * 4;
			}
			else {

				// Raw
				fputc( rec.len | 0x80, out );
				while( rec.len-- ) {
					fputc( buffer[ buf_ptr ], out );
					buf_ptr += 4;
				}
			}

			rec_ptr++;
		} // end encode

///////////////////////////////////////////////////////////////

		// terminate byte
		fputc( 0x00, out );
		loops++;
	} // stop full encoder

	// close shop
	fclose( out );
}