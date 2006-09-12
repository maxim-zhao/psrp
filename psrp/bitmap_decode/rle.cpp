/*
Phantasy Star: RLE Compression
*/

#include <stdio.h>

unsigned char buffer[0x4000];
short buf_ptr;

///////////////////////////////////////////////////////

void RLE_Decode( FILE *fp, FILE *out, int offset )
{
	short loops;

	// init
	buf_ptr = 0;
	loops = 0;

	fseek( fp, offset, SEEK_SET );

	// start going through each color plane
	while( loops < 4 ) {
		buf_ptr = loops;

		while( 1 ) {
			int data;
			int run;
			
			// read encoding method bits
			data = fgetc( fp );

			// terminate
			if( !data ) break;

			// determine run length
			run = data & 0x7f;

			// Raw byte copy
			if( data & 0x80 ) {
				while( run-- ) {
					buffer[ buf_ptr ] = fgetc( fp );
					buf_ptr += 4;
				}
			}

			// RLE
			else {
				int rle = fgetc( fp );
				while( run-- ) {
					buffer[ buf_ptr ] = rle;
					buf_ptr += 4;
				}
			}
		} // end decode

		loops++;
	} // stop full decoder

	// close shop
	buf_ptr -= ( 4 - 1 );
	fwrite( buffer, 1, buf_ptr, out );
}