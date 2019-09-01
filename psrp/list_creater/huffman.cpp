/*
Phantasy Star: Huffman Compressor
*/

#include <stdio.h>
#include <deque>
#include <string>

using std::deque;
using std::string;


//#define SEMI_ADAPTIVE		// multiple Huffman trees
//#define DEBUG					// print interim output
//#define DEBUG_SCRIPT		// print interim script output

#define EOS 0xDB				// end-of-string

// number of Huffman trees to create
#ifdef SEMI_ADAPTIVE
	#define LIMIT 0xDC
#else
	#define LIMIT 1
#endif


typedef struct {
	int size;			// # items total
	int item;			// node's symbol

	int ptr;			// location in node list
	int root;			// parent node
	int left;			// pointer to left subtree
	int right;		// pointer to right subtree
	int branch;		// side of branch taken from root
} node_t;

typedef deque<node_t> tree_t;


int symbol_count[ LIMIT ][256];
tree_t trees[ LIMIT ];
node_t nodes[ LIMIT ][256*2];

deque<int> tree_shape[ LIMIT ];
deque<int> tree_symbol[ LIMIT ];

//////////////////////////////////////////////////////

void Create_Node( node_t &node, int size, int item, int ptr, int root, int left, int right )
{
	node.size = size;
	node.item = item;

	node.ptr = ptr;
	node.root = root;
	node.left = left;
	node.right = right;
	node.branch = -1;
}


void Insert_Node( tree_t &tree, node_t &node )
{
	tree_t::iterator ptr;

	ptr = tree.end();

	// insert smallest items at back
	for( int lcv = tree.size() - 1; lcv >= 0; lcv--, ptr-- ) {
		if( node.size <= tree[ lcv ].size ) break;
	}

	tree.insert( ptr, node );
}


#ifdef DEBUG
int travel_level;
#endif

// Note: Reference variables to cut down on stack space
//       during pre-order traversal
void Travel_Node( int &tree, int &ptr )
{
	node_t &node = nodes[ tree ][ ptr ];

	if( node.left == -1 ) {
		// root
		tree_shape[ tree ].push_back( 1 );
		tree_symbol[ tree ].push_front( node.item );

#ifdef DEBUG
		printf( " 1 [%02X %03X %01X]", node.item, node.size, travel_level );
#endif
	} else {

#ifdef DEBUG
		printf( " 0" );
		travel_level++;
#endif

		// non-root
		tree_shape[ tree ].push_back( 0 );
		Travel_Node( tree, node.left );
		Travel_Node( tree, node.right );

#ifdef DEBUG
		travel_level--;
#endif
	}
}


void Huffman_Generate( char *file, char *file_out )
{
	FILE *fp, *out;
	int symbol;
	int old_tree;

	fp = fopen( file, "rb" );
	out = fopen( file_out, "wb" );
	if( !fp ) {
		printf( "Error: Could not open file \"%s\"\n", file );
		return;
	}
	if( !out ) {
		printf( "Error: Could not write to file \"%s\"\n", file_out );
		return;
	}

/*------------------------------------------*/

	// Starting tree number
#ifdef SEMI_ADAPTIVE
	old_tree = EOS;
#else
	old_tree = LIMIT - 1;
#endif

	// Build symbol statistics first
	while( ( symbol = fgetc( fp ) ) != EOF ) {

		// Tally items
		symbol_count[ old_tree ][ symbol ]++;

#ifdef SEMI_ADAPTIVE
		// Use new symbol as fresh index
		old_tree = symbol;
#endif
	}

/*------------------------------------------*/

	// grab place markers
	int start_ptr = 0x7ff85;

	for( int tree = 0; tree < LIMIT; tree++ ) {
		int node_ptr;
		int tree_ptr;

		int buffer;
		int bits;

		// start creating leaf nodes
		for( int symbol = 0; symbol < 256; symbol++ ) {
			int size;

			if( size = symbol_count[ tree ][ symbol ] ) {
				node_t &node = nodes[ tree ][ symbol ];

				// add basic node
				Create_Node( node, size, symbol, symbol, -1, -1, -1 );
				Insert_Node( trees[ tree ], node );
			}
		}

		// build huffman tree
		node_ptr = 256;
		while( trees[ tree ].size() > 1 ) {

			node_t item1, item2;

			// take two smallest items
			item1 = trees[ tree ].back();
			trees[ tree ].pop_back();

			item2 = trees[ tree ].back();
			trees[ tree ].pop_back();

			// grab target memory location
			node_t &node = nodes[ tree ][ node_ptr ];
			node_t &left = nodes[ tree ][ item1.ptr ];
			node_t &right = nodes[ tree ][ item2.ptr ];

			// link nodes for encoding speed
			left.root = node_ptr;
			right.root = node_ptr;

			left.branch = 0;
			right.branch = 1;

			// merge
			Create_Node( node, left.size + right.size, -1,
									 node_ptr, -1, left.ptr, right.ptr );
			Insert_Node( trees[ tree ], node );

			node_ptr++;
		}

		// format tree to storable form
		if( trees[ tree ].size() ) {
			node_ptr = trees[ tree ][0].ptr;
			tree_ptr = tree;
			Travel_Node( tree_ptr, node_ptr );
		}

		// save data to file: symbols
    int lcv;
		for( lcv = 0; lcv < tree_symbol[ tree ].size(); lcv++ ) {
			fputc( tree_symbol[ tree ][ lcv ], out );

			// bump pointer
			start_ptr++;
		}

		// save data to file: shape
		bits = 0;
		buffer = 0;
		for( lcv = 0; lcv < tree_shape[ tree ].size(); lcv++ ) {
			buffer <<= 1;
			buffer |= tree_shape[ tree ][ lcv ];
			bits++;

			// flush to file
			if( bits == 8 ) {
				fputc( buffer, out );
				bits = 0;
				buffer = 0;
			}
		}

		// Flush remaining data to file
		if( bits ) {
			while( bits < 8 ) {
				buffer <<= 1;
				bits++;
			}
			fputc( buffer, out );
		}

		// no tree pointer check
		if( !trees[ tree ].size() ) start_ptr = 0xffff;

#ifdef DEBUG
		// log output
		printf( "(%02X) Symbols = $%03X, %06X\n", tree,
			tree_symbol[ tree ].size(), start );
#endif
	}

	// final area
	//printf( "Actual tree starts at : %06X\n", start_ptr );
	printf( "Tree offset is at: %06X  [t1a.asm = TREE_PTR]\n", start_ptr - 0x7ff85);

	fclose( fp );
	fclose( out );
}


void Huffman_Encode( char *file, char *file_out )
{
	FILE *fp, *out;
	int symbol;
	int old_tree;

	int buffer;
	int bits;

	fp = fopen( file, "rb" );
	out = fopen( file_out, "wb" );

	if( !fp ) {
		printf( "Error: Could not open file \"%s\"\n", file );
		return;
	}
	if( !out ) {
		printf( "Error: Could not write to file \"%s\"\n", file_out );
		return;
	}

	// Starting tree number
#ifdef SEMI_ADAPTIVE
	old_tree = EOS;
#else
	old_tree = 0;
#endif

	buffer = 0;
	bits = 0;

	// Construct each Huffman code
	while( ( symbol = fgetc( fp ) ) != EOF ) {
		deque<int> codeword;
		node_t node = nodes[ old_tree ][ symbol ];

		// Work upwards through tree
		while( node.root != -1 ) {
			codeword.push_front( node.branch );
			node = nodes[ old_tree ][ node.root ];
		}

		// Write out created codeword
		while( codeword.size() ) {
			buffer <<= 1;
			buffer |= codeword[0];
			bits++;
			codeword.pop_front();

			// Flush data to file
			if( bits == 8 ) {
				fputc( buffer, out );
				bits = 0;
				buffer = 0;
			}
		}

#ifdef SEMI_ADAPTIVE
		// Use new symbol as fresh index
		old_tree = symbol;
#endif
	}

	// Flush remaining data to file
	if( bits ) {
		while( bits < 8 ) {
			buffer <<= 1;
			bits++;
		}
		fputc( buffer, out );
	}

	fclose( out );
	fclose( fp );
}


void Huffman_Script( char *file, char *file_out )
{
	FILE *fp, *out;
	int symbol;
	int old_tree;
	string code;

	int buffer;
	int bits;

	int table_number;
	int table_entry;
	int table_last;

	// init
	table_number = 1;
	table_entry = 0;
	table_last = 0;

	// Open up files
	fp = fopen( file, "rb" );

	if( !fp ) {
		printf( "Error: Could not open file \"%s\"\n", file );
		return;
	}

	// Header
	printf( "Text entry locations:\n" );

	do {
		char file_name[256];

		// Create a new file
		if( table_entry == 0 ) {
			sprintf( file_name, "%s%d.bin", file_out, table_number );
			out = fopen( file_name, "wb" );
			if( !out ) {
				printf( "Error: Could not write to file \"%s\"\n", file_name );
				return;
			}
		}

		// Starting tree number
		old_tree = EOS;
		buffer = 0;
		bits = 0;
		code = "";

#ifdef DEBUG_SCRIPT
		printf( "[%01X %02X]\n", table_number, table_entry );
#endif

		// Record area
		if( table_entry == 0 ) {
			if( table_number <= 3 )
				printf( "%01X: %04X\n", table_number, table_last + 0x43de );
			else
				printf( "%01X: %04X\n", table_number, table_last + 0x401e );
		}

		// Construct each Huffman code
		do {
			deque<int> codeword;
			node_t node;
			
			// grab symbol to encode
			symbol = fgetc( fp );
			if( symbol == EOF ) break;

			// find in tree
			node = nodes[ old_tree ][ symbol ];

			// Work upwards through tree
			while( node.root != -1 ) {
				codeword.push_front( node.branch );
				node = nodes[ old_tree ][ node.root ];
			}

			// Write out created codeword
			while( codeword.size() ) {
				buffer <<= 1;
				buffer |= codeword[0];
				bits++;

#ifdef DEBUG_SCRIPT
				printf( "%01d", codeword[0] );
#endif

				codeword.pop_front();

				// Flush data to buffer
				if( bits == 8 ) {
					code += buffer;
					bits = 0;
					buffer = 0;
				}
			}

#ifdef DEBUG_SCRIPT
			printf( "~\n" );
#endif

	#ifdef SEMI_ADAPTIVE
			// Use new symbol as fresh index
			old_tree = symbol;
	#endif
		} while( symbol != EOS );

#ifdef DEBUG_SCRIPT
		printf( "\n" );
#endif

		if( symbol == EOF ) break;

		// Flush remaining data to buffer
		if( bits ) {
			while( bits < 8 ) {
				buffer <<= 1;
				bits++;
			}
			code += buffer;
		}

		// Now write to file
		fputc( code.length(), out );
		fwrite( code.c_str(), 1, code.length(), out );

		// Rack up locations
		table_entry++;
		if( table_entry == 256 ) {
			table_entry = 0;
			table_number++;
	
			// adjustments
			table_last += ftell( out );
			if( table_number == 4 ) table_last = 0;
			fclose( out );
		}
	} while( symbol != EOF );

	fclose( out );
	fclose( fp );
}


void Huffman_Compress( char *file_in, char *file_out, char *tree_out )
{
	Huffman_Generate( file_in, tree_out );
	Huffman_Encode( file_in, file_out );
}

//////////////////////////////////////////////////////

unsigned char rom_page[0x4000];

void Huffman_Decode( FILE *rom, FILE *out )
{
	char huf_bits, huf_barrel;
	int huf_length;
	int symbol_ptr;
	int tree;
	
	// get length byte
	huf_length = fgetc( rom );
	if( !huf_length ) {
		printf( "NULL-string detected at %06X\n", ftell( rom ) );
		return;
	}

	// reload
	huf_bits = 8;
	huf_barrel = fgetc( rom );
	huf_length--;

	// starting Huffman tree
#ifdef SEMI_ADAPTIVE
	tree = EOS;
#else
	tree = 0;
#endif

	// keep going until terminate symbol
	do {
		int tree_ptr;
		char tree_bits, tree_barrel;

		// find physical tree data in page
		tree_ptr = rom_page[ 0x1c3f + tree * 2 ];
		tree_ptr += rom_page[ 0x1c40 + tree * 2 ] << 8;
		tree_ptr -= 0x4000;
		symbol_ptr = tree_ptr - 1;

		// init
		tree_bits = 8;
		tree_barrel = rom_page[ tree_ptr++ ];

		// traverse until leaf node reached
		while( ( tree_barrel & 0x80 ) == 0 ) {

			// shift barrel
			tree_barrel <<= 1;
			tree_bits--;

			// reload barrel
			if( !tree_bits ) {
				tree_bits = 8;
				tree_barrel = rom_page[ tree_ptr++ ];
			}

			// travel right
			if( ( huf_barrel & 0x80 ) == 0x80 ) {
				int skip_count = 1;

#ifdef DEBUG_SCRIPT
				printf( "1" );
#endif

				// bypass symbols in the left subtree
				while( skip_count ) {

					if( ( tree_barrel & 0x80 ) == 0 ) {
						// non-leaf
						skip_count++;
					} else {
						// leaf node
						skip_count--;
						symbol_ptr--;
					}

					// shift barrel
					tree_barrel <<= 1;
					tree_bits--;

					// reload
					if( !tree_bits ) {
						tree_bits = 8;
						tree_barrel = rom_page[ tree_ptr++ ];
					}
				} // end skip nodes
			} else {
				// travel left
				// skip 0 nodes, do nothing
#ifdef DEBUG_SCRIPT
				printf( "0" );
#endif
			}

			// shift barrel
			huf_barrel <<= 1;
			huf_bits--;

			// reload
			if( !huf_bits ) {
				
				// safety check
				if( ( tree_barrel & 0x80 ) && rom_page[ symbol_ptr ] == EOS )
					break;

				huf_bits = 8;
				huf_barrel = fgetc( rom );
				huf_length--;

				if( huf_length < 0 ) {
					printf( "ERROR at %06X\n", ftell( rom ) );
					return;
				}
			}
		} // end check leaf node

#ifdef SEMI_ADAPTIVE
		// adapt to next probability fallout
		tree = rom_page[ symbol_ptr ];
#endif

#ifdef DEBUG_SCRIPT
		printf( "~\n" );
#endif

		fputc( rom_page[ symbol_ptr ], out );
	} while( tree != EOS );

#ifdef DEBUG_SCRIPT
	printf( "\n" );
#endif

	// flush zero bits
	while( huf_length-- ) fgetc( rom );
}


int Huffman_Decompress( char *file, char *file_out )
{
	FILE *rom, *out;

	// open file
	rom = fopen( file, "rb" );
	out = fopen( file_out, "wb" );

	if( !rom ) {
		printf( "Error: Could not open file \"%s\"\n", file );
		return -1;
	}
	if( !out ) {
		printf( "Error: Could not write to file \"%s\"\n", file_out );
		return -1;
	}

	// gather all Huffman data
	fseek( rom, 0x28000, SEEK_SET );
	fread( rom_page, 1, sizeof( rom_page ), rom );

	// header text
	printf( "Script blocks:\n" );

	// six known tables of script
	for( int table = 1; table <= 6; table++ ) {
		int start, end;

		// find starting location
		switch( table ) {
		case 1: fseek( rom, 0x2000e, SEEK_SET ); end = 256; break;
		case 2: fseek( rom, 0x20010, SEEK_SET ); end = 256; break;
		case 3: fseek( rom, 0x20012, SEEK_SET ); end = 256; break;
		case 4: fseek( rom, 0x24000, SEEK_SET ); end = 256; break;
		case 5: fseek( rom, 0x24002, SEEK_SET ); end = 256; break;
		case 6: fseek( rom, 0x24004, SEEK_SET ); end = 149; break;
		}
		fread( &start, 1, 2, rom );

		// another offset
		if( table <= 3 ) start += 0x203de;
		else start += 0x2401e;

		// final spot
		fseek( rom, start, SEEK_SET );

		// possible entries
		for( int entry = 0; entry < end; entry++ ) {
			printf( "[%01X %02X] %06X, %06X\n", table, entry,
				ftell( rom ), ftell( out ) );
			Huffman_Decode( rom, out );
		}
		printf( "[%01X] %06X - %06X (%06X)\n", table,
			start, ftell( rom ), ftell( rom ) - start );
	}

	printf( "\n" );
	fclose( out );
	fclose( rom );

	return 0;
}