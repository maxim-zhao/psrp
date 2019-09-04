/*
Phantasy Star: RLE/LZ Compression
*/

#include <cstdio>

unsigned char buffer[ 0x4000 ];
short buf_ptr;

///////////////////////////////////////////////////////

void PSG_Decode( FILE *fp, FILE *out, int tiles, int offset )
{
	short loops;
	int methods;

	// init
	fseek( fp, offset, SEEK_SET );

	while( tiles-- ) {

		// init
		buf_ptr = 0;
		loops = 4;

		// access high-level algorithm selection
		methods = fgetc( fp );

		// start going through each block
		while( loops-- ) {
			int bits;

			int RLE;
			int LZ;
			int LZ_mask;
			int pattern;

			// init
			LZ = -1;
			RLE = -1;

			// find path to take
			// - 00 = 8 $00's
			// - 01 = 8 $FF's
			// - 10 = RLE/LZ extended
			// - 11 = 8 raw bytes

			switch( ( methods & 0xc0 ) >> 6 ) {
			case 0: RLE = 0x00; pattern = 0xff; break;
			case 1: RLE = 0xff; pattern = 0xff; break;
			
			case 2: {
				int extend;

				// read extended method selection
				extend = fgetc( fp );

				// mix LZ/RLE detection
				if( extend < 0x03 ) {
					LZ_mask = 0x00;
					pattern = 0xff;
					LZ = ( extend & 3 ) << 3;
				}
				else if( extend < 0x10 ) {
					pattern = extend;
					RLE = fgetc( fp );
				}
				else if( extend < 0x13 ) {
					LZ_mask = 0xff;
					pattern = 0xff;
					LZ = ( extend & 3 ) << 3;
				}
				else if( extend < 0x20 ) {
					pattern = extend;
					RLE = fgetc( fp );
				}
				else if( extend < 0x23 ) {
					LZ_mask = 0x00;
					pattern = fgetc( fp );
					LZ = ( extend & 3 ) << 3;
				}
				else if( extend < 0x40 ) {
					pattern = extend;
					RLE = fgetc( fp );
				}
				else if( extend < 0x43 ) {
					LZ_mask = 0xff;
					pattern = fgetc( fp );
					LZ = ( extend & 3 ) << 3;
				}
				
				// RLE detection
				else {
					pattern = extend;
					RLE = fgetc( fp );
				}
			}
			break;

			case 3: pattern = 0x00; break;
			}

			// cycle through eight runs
			for( bits = 8; bits; bits-- ) {
				
				// raw byte
				if( ( pattern & 0x80 ) == 0 ) {
					buffer[ buf_ptr++ ] = fgetc( fp );
				}
				
				// RLE run
				else if( LZ == -1 ) {
					buffer[ buf_ptr++ ] = RLE;
				}

				// LZ run
				else {
					buffer[ buf_ptr++ ] = buffer[ LZ ] ^ LZ_mask;
				}

				// detect next run method
				pattern <<= 1;

				// auto-inc even if no LZ run
				if( LZ != -1 ) LZ++;
			}

			// update for next iteration
			methods <<= 2;
		} // stop one tile decoder

		// flush now (32 bytes = 4bpp = 1 tile)
		for( int col = 0; col < 8; col++ )
		for( int row = 0; row < 4; row++ )
			fputc( buffer[ col + row * 8 ], out );
	} // stop full decoder
}