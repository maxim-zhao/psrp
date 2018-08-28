/*
Phantasy Star: RLE/LZ Encoder
*/

#ifdef _DEBUG
	#pragma warning( disable: 4786 )	// 255 character debug limit
#endif

#include <stdio.h>

#include <map>
#include <map>
using namespace::std;

int tile[ 0x20 ];
unsigned char buffer[ 0x40 ];
short buf_ptr;

///////////////////////////////////////////////////////

void PSG_Encode( FILE *fp, FILE *out )
{
	int tiles;

	// pre-judge size
	fseek( fp, 0, SEEK_END );
	tiles = ftell( fp ) / 0x20;

	// header bytes
	/// num tiles (word)
	fwrite( &tiles, 1, 2, out );

	// init
	fseek( fp, 0, SEEK_SET );
	tiles = 0;

	// keep encoding tiles until no more in file
	while( 1 ) {
		int methods;
		int loops;
		int byte;

		// unroll tile to individual color planes
		/// = deinterleave by 4, single tile
		for( int col = 0; col < 8; col++ ) {
			for( int row = 0; row < 4; row++ ) {		
				byte = fgetc( fp );
				if( byte == EOF ) break;

				tile[ col + row * 8 ] = byte;
			}

			// abort
			if( byte == EOF ) break;
		}

		// abort
		if( byte == EOF ) break;

		// init
		buf_ptr = 0;
		methods = 0;

		// start going through each 8-byte block
		for( loops = 0; loops < 4; loops++ ) {
			/// for each bitplane of the tile
			map<int,int> symbols;
			int lcv;
			int run;

			int RLE;
			int RLE_count;

			int LZ_count;
			int LZ_window;
			int LZ_mask;

			// init
			LZ_count = 0;
			LZ_window = 0;
			LZ_mask = 0;

			RLE = -1;
			RLE_count = 0;

// -------------------------------------------------------

			// init
			symbols.clear();

			// count maximum # of RLE runs
			/// count occurrences of each byte in bitplane
			for( lcv = 0; lcv < 8; lcv++ ) {
				symbols[ tile[ loops * 8 + lcv ] ]++;
			}

			// target largest symbol
			/// find most common byte
			for( lcv = 0; lcv < 8; lcv++ ) {
				if( symbols[ tile[ loops * 8 + lcv ] ] > RLE_count ) {
					RLE_count = symbols[ tile[ loops * 8 + lcv ] ];
					RLE = tile[ loops * 8 + lcv ];
				}
			}

// -------------------------------------------------------

			// diff compare with each previous block
			for( run = 0; run < loops; run++ ) {
				/// check this bitplane against previous ones
				/// find how many bytes are the same

				// init
				symbols.clear();

				// count maximum # of LZ runs
				for( lcv = 0; lcv < 8; lcv++ ) {
					if( tile[ loops * 8 + lcv ] == tile[ run * 8 + lcv ] )
						symbols[0]++;
				}

				// target largest symbol
				if( symbols[0] > LZ_count ) {
					LZ_window = run;
					LZ_count = symbols[0];
				}
			} // end run compare


			// diff compare with each previous block (inversion mask)
			for( run = 0; run < loops; run++ ) {
				/// same again with inversion

				// init
				symbols.clear();

				// count maximum # of LZ runs
				for( lcv = 0; lcv < 8; lcv++ ) {
					if( tile[ loops * 8 + lcv ] == ( tile[ run * 8 + lcv ] ^ 0xff ) )
						symbols[0]++;
				}

				// target largest symbol
				if( symbols[0] > LZ_count ) {
					LZ_window = run;
					LZ_count = symbols[0];
					LZ_mask = 0xff;
				}
			} // end run compare

// -------------------------------------------------------

			// extract high-level method
			/// shift current encoding left 2 to add this one
			methods <<= 2;

			// basic algorithms
			if( RLE_count == 8 && RLE == 0x00 ) {
				/// all 0 = %00
				methods |= 0x00;
			}
			else if( RLE_count == 8 && RLE == 0xff ) {
				/// all ff = %01
				methods |= 0x01;
			}
			else if( RLE_count <= 2 && LZ_count <= 2 ) {
				/// raw = %11
				methods |= 0x03;

				// queue up raw bytes
				for( lcv = 0; lcv < 8; lcv++ ) {
					buffer[ buf_ptr++ ] = tile[ loops * 8 + lcv ];
				}
			}

			// extended
			else {
				/// compressed = %10
				methods |= 0x02;

				// select new method
				if( LZ_count == 8 ) {
					/// %000-00-- = whole bitplane duplicate
					/// %---f--nn
					/// f = 1 for inverted
					/// nn = which bitplane to copy from (0-2)
					if( LZ_mask == 0 ) buffer[ buf_ptr++ ] = 0x00 | LZ_window;
					else buffer[ buf_ptr++ ] = 0x10 | LZ_window;
				}
				else if( LZ_count > RLE_count ) {
					/// %001000-- = copy bytes
					/// %010000-- = copy and invert bytes
					/// %------nn
					/// nn = which bitplane to copy from (0-2)
					int pattern;

					if( LZ_mask == 0 ) buffer[ buf_ptr++ ] = 0x20 | LZ_window;
					else buffer[ buf_ptr++ ] = 0x40 | LZ_window;

					pattern = 0;

					// add in pattern data
					for( lcv = 0; lcv < 8; lcv++ ) {
						pattern <<= 1;
						if( tile[ loops * 8 + lcv ] == ( tile[ LZ_window * 8 + lcv ] ^ LZ_mask ) )
							pattern |= 1;
					}
					/// next byte = bitmask
					/// 1 = copy byte
					/// 0 = don't
					buffer[ buf_ptr++ ] = pattern;

					// add in raw data
					/// uncopied bytes
					run = pattern;
					for( lcv = 0; lcv < 8; lcv++ ) {
						if( ( run & 0x80 ) == 0 )
							buffer[ buf_ptr++ ] = tile[ loops * 8 + lcv ];
						run <<= 1;
					}
				}
				else {
					/// %-------- = common byte (patterns mean none of the above can have 3 set bits)
					int pattern;

					pattern = 0;

					// add in pattern data
					for( lcv = 0; lcv < 8; lcv++ ) {
						pattern <<= 1;
						if( tile[ loops * 8 + lcv ] == RLE )
							pattern |= 1;
					}

					/// value = mask
					/// 1 = use common value
					buffer[ buf_ptr++ ] = pattern;
					/// next byte = byte
					buffer[ buf_ptr++ ] = RLE;

					// add in raw data
					run = pattern;
					for( lcv = 0; lcv < 8; lcv++ ) {
						if( ( run & 0x80 ) == 0 )
							buffer[ buf_ptr++ ] = tile[ loops * 8 + lcv ];
						run <<= 1;
					}
				} // ext. method select
			} // original select
		} // stop one tile encoder

		// write out data
		fputc( methods, out );
		fwrite( buffer, 1, buf_ptr, out );
	} // stop full encoder
}