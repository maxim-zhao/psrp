/*
Phantasy Star: Huffman Compressor
*/

#include <cstdio>
#include <deque>
#include <string>
#include <vector>
#include <fstream>
#include <iterator>
#include <sstream>
#include <iomanip>


#define EOS 0x56				// end-of-string

struct node_t
{
	node_t(): size(0), item(0), ptr(0), root(0), left(0), right(0), branch(0)
	{
	}

	node_t(int size, int item, int ptr, int root, int left, int right, int branch)
		: size(size),
		  item(item),
		  ptr(ptr),
		  root(root),
		  left(left),
		  right(right),
		  branch(branch)
	{
	}

	int size; // # items total
	int item; // node's symbol

	int ptr; // location in node list
	int root; // parent node
	int left; // pointer to left subtree
	int right; // pointer to right subtree
	int branch; // side of branch taken from root
};

std::deque<node_t> trees[256]; // One tree for each "preceding letter". Some will be empty.
node_t nodes[256][256 * 2];

std::deque<int> tree_shape[256]; // Tree shape for each tree
std::deque<int> tree_symbol[256]; // Symbols encoded in each tree

int empty_tree_space;
int tree_end;

//////////////////////////////////////////////////////

unsigned short pointers[] = {
	0x4b48, 0x4b4e, 0x4b62, 0x4b7c, 0x4b82,
	0x4b88, 0x4b8e, 0x4b94, 0x4b9a, 0x4bba,
	0x4bc0, 0x4bcd, 0x0000, 0x4c26, 0x0000, 0x4cc2, 0x0000, 0x4d0e,
	0x4bda, 0x0000, 0x4d23, 0x4be0, 0x0000, 0x4c3a, 0x0000, 0x4cd5,
	0x0000, 0x4d18, 0x0000, 0x4d2d, 0x0000, 0x5497, 0x4bf1, 0x4bf7,
	0x4bfd, 0x4c03, 0x4c09, 0x4c0f, 0x4da7,
	0x4dac, 0x4db6, 0x4dbb, 0x4dc1, 0x4dc7,
	0x4dcd, 0x4dd3, 0x4dd9, 0x4ddf, 0x4de5,
	0x4deb, 0x4df1, 0x4df7, 0x4dfd, 0x4e17,
	0x4e1d, 0x4e2b, 0x4ba9, 0x0000, 0x4e06, 0x0000, 0x4e26,
	0x4ba0, 0x4bb4, 0x4c9e, 0x4ca4, 0x4caa,
	0x4c1d, 0x0000, 0x4cb7, 0x4d33, 0x4d44, 0x4d55,
	0x4d6c, 0x4d91, 0x4d3e, 0x0000, 0x4d77, 0x0000, 0x4eca,
	0x4d4f, 0x0000, 0x4d60, 0x4e31, 0x4e37, 0x4e3d,
	0x4e43, 0x4e49, 0x4e4f, 0x4e55, 0x4e5b,
	0x4e61, 0x4e7f, 0x4e8a, 0x4e98, 0x4ea9,
	0x5627, 0x564b, 0x5651, 0x5632, 0x4f19,
	0x4f13, 0x0000, 0x4fc6, 0x53c4, 0x53df, 0x53c9,
	0x4fd4, 0x4fda, 0x4ff9, 0x500b, 0x0000, 0x5034,
	0x0000, 0x533a, 0x0000, 0x54a9, 0x5028, 0x5016, 0x0000, 0x503f,
	0x0000, 0x54b4, 0x504f, 0x507b, 0x4c30, 0x0000, 0x4ccf,
	0x0000, 0x54ca, 0x50a7, 0x50d1, 0x546d, 0x50de,
	0x5071, 0x5096, 0x510d, 0x0000, 0x5428, 0x5453,
	0x545e, 0x5464, 0x5477, 0x5485, 0x549d,
	0x0000, 0x55e0, 0x54c4, 0x54d0, 0x54e4, 0x54ea,
	0x54f0, 0x550c, 0x542f, 0x5436, 0x57ec,
	0x5512, 0x5518, 0x551e, 0x4fff, 0x50eb,
	0x5005, 0x5524, 0x5139, 0x5119, 0x511f,
	0x5125, 0x512e, 0x5113, 0x7fed, 0x513f,
	0x5145, 0x514b, 0x54de, 0x5151, 0x5157,
	0x57bd, 0x515d, 0x5163, 0x5169, 0x516f,
	0x5194, 0x5175, 0x5133, 0x0000, 0x517e, 0x0000, 0x54d9,
	0x0000, 0x54fe, 0x518e, 0x2dab, 0x2db0, 0x2ddc,
	0x5530, 0x54f9, 0x5541, 0x0000, 0x5552, 0x0000, 0x5563,
	0x5547, 0x553b, 0x5558, 0x5569, 0x5574,
	0x557a, 0x5585, 0x5597, 0x55a0, 0x55a5,
	0x519a, 0x51a0, 0x51a6, 0x51ac, 0x51b2,
	0x51b8, 0x51cb, 0x57e0, 0x51c1, 0x51d1,
	0x51d7, 0x51dd, 0x51e3, 0x51e9, 0x51ef,
	0x51f5, 0x5201, 0x5226, 0x521d, 0x520c,
	0x4cec, 0x4cfd, 0x5238, 0x523e, 0x5244,
	0x524a, 0x5250, 0x5256, 0x525c, 0x5262,
	0x5268, 0x526e, 0x5274, 0x527a, 0x5280,
	0x5286, 0x528c, 0x529a, 0x5295, 0x52a0,
	0x52a6, 0x52b2, 0x52b8, 0x52be, 0x52c4,
	0x59c1, 0x52ca, 0x52d6, 0x52e1, 0x52f2,
	0x5300, 0x5306, 0x530f, 0x5314, 0x531a,
	0x5320, 0x5326, 0x532f, 0x5334, 0x5355,
	0x0000, 0x53a5, 0x5345, 0x502e, 0x0000, 0x5055, 0x0000, 0x535b,
	0x5361, 0x5849, 0x0000, 0x58ea, 0x5619, 0x5613,
	0x552a, 0x55b3, 0x55c5, 0x55f5, 0x55fb,
	0x5601, 0x582d, 0x583b, 0x5836, 0x5607,
	0x58ef, 0x560d, 0x57fd, 0x0000, 0x5803, 0x7fed,
	0x5815, 0x592d, 0x5661, 0x5684, 0x566c,
	0x568a, 0x5373, 0x56c7, 0x56d9, 0x5722,
	0x571c, 0x56a6, 0x56b3, 0x56bc, 0x56c1,
	0x5738, 0x5749, 0x5367, 0x576a, 0x5773,
	0x5778, 0x58e1, 0x5933, 0x5856, 0x585c,
	0x4c40, 0x4e67, 0x4e73, 0x508b, 0x50b5,
	0x50c3, 0x50f6, 0x4c54, 0x4c75, 0x4c7a,
	0x4f2f, 0x4f0d, 0x4f5b, 0x4fa2, 0x58fc,
	0x4ed6, 0x56d3, 0x5789, 0x13a4, 0x1497,
	0x1a96, 0x1ac0, 0x0000, 0x1ca4, 0x1ab7, 0x1b27,
	0x20cd, 0x0000, 0x20fa, 0x0000, 0x2168, 0x0000, 0x21cb, 0x0000, 0x21fd,
	0x0000, 0x22ac, 0x7fed, 0x1ffa, 0x1492, 0x14f9,
	0x0000, 0x15d3, 0x0000, 0x1637, 0x1458, 0x1fbc, 0x1552,
	0x20d3, 0x151f, 0x12db, 0x140c, 0x12d6,
	0x1407, 0x2132, 0x216f, 0x210d, 0x21ad,
	0x219f, 0x0000, 0x21b2, 0x23e6, 0x0000, 0x23f5, 0x0000, 0x240b,
	0x0000, 0x2441, 0x0000, 0x2476, 0x0000, 0x24b0, 0x0000, 0x24c5, 0x0000, 0x2529,
	0x0000, 0x2548, 0x0000, 0x2575, 0x0000, 0x265a, 0x0000, 0x2683, 0x0000, 0x2775,
	0x0000, 0x27b1, 0x0000, 0x27df, 0x0000, 0x280c, 0x2883, 0x28cc,
	0x20ff, 0x0000, 0x23ec, 0x0000, 0x2554, 0x0000, 0x2582, 0x0000, 0x2677,
	0x0000, 0x2803, 0x2418, 0x0000, 0x242a, 0x0000, 0x244c, 0x0000, 0x245e,
	0x0000, 0x2486, 0x2304, 0x2438, 0x0000, 0x246d, 0x2311,
	0x2402, 0x0000, 0x2569, 0x0000, 0x26af, 0x0000, 0x2701, 0x0000, 0x2816,
	0x24eb, 0x7fed, 0x2505, 0x0000, 0x2597, 0x0000, 0x25f9,
	0x0000, 0x26f1, 0x0000, 0x2742, 0x0000, 0x27a2, 0x24ff, 0x0000, 0x2514,
	0x0000, 0x258b, 0x0000, 0x25ed, 0x0000, 0x264b, 0x0000, 0x2733, 0x0000, 0x2793,
	0x251a, 0x0000, 0x25aa, 0x0000, 0x2651, 0x0000, 0x279d, 0x112c,
	0x25bd, 0x0000, 0x2636, 0x25af, 0x0000, 0x260c, 0x0000, 0x262d,
	0x2611, 0x2276, 0x0000, 0x228e, 0x2269, 0x0000, 0x2271,
	0x0000, 0x2289, 0x269f, 0x2693, 0x0000, 0x26e5, 0x26d0,
	0x26c4, 0x2711, 0x273d, 0x277b, 0x2784,
	0x281b, 0x218d, 0x0000, 0x2195, 0x0000, 0x299f, 0x0000, 0x2a2e,
	0x0000, 0x579d, 0x2a15, 0x0000, 0x2a9b, 0x21d9, 0x0000, 0x22b5,
	0x2248, 0x1b45, 0x0000, 0x1f21, 0x1b9e, 0x0000, 0x1f1c,
	0x28a3, 0x283e, 0x1872, 0x18f3, 0x1910,
	0x2a8c, 0x2a37, 0x2a73, 0x2918, 0x2938,
	0x296a, 0x297d, 0x2923, 0x292e, 0x28c3,
	0x0000, 0x295d, 0x1ba7, 0x0000, 0x1f2d, 0x2236, 0x17ea,
	0x14a6, 0x0000, 0x15e4, 0x0000, 0x1648, 0x0000, 0x4c69, 0x0000, 0x590f,
	0x19f7, 0x0000, 0x2b0f, 0x2752, 0x5959, 0x5995,
	0x5990, 0x598a, 0x5980, 0x597b, 0x5975,
	0x7fed, 0x578f, 0x2d1c, 0x2d27, 0x0000, 0x2d89,
	0x0000, 0x2e46, 0x0000, 0x537e, 0x2d38, 0x2d7e, 0x2d98,
	0x0000, 0x539c, 0x2deb, 0x2df4, 0x2e0d, 0x2e4f,
	0x2e66, 0x2ae9, 0x2b54, 0x2b99, 0x2af9,
	0x2b8a, 0x2b37, 0x0000, 0x2bb1, 0x2b2b, 0x2be7,
	0x7fed, 0x2c37, 0x2c60, 0x2bfb, 0x2c71,
	0x2c24, 0x2ca8, 0x2d16, 0x2ca2, 0x2c90,
	0x1e3b, 0x84e, 0x0000, 0x1e44, 0x1e55, 0x1e91,
	0x1ae5, 0x1ae7, 0x1ae9, 0x1aeb, 0x1aed,
	0x1aef, 0x1af1, 0x1af3, 0x1af5, 0x1cce,
	0x1cd0, 0x1cd2, 0x1cd4, 0x1cd6, 0x1cd8,
	0x1cda, 0x1cdc, 0x1cde, 0x1ce0, 0x1574,
	0x17ff, 0x27c3, 0x27cf, 0x27bc, 0x27ca,
	0x1786, 0x178c, 0x2bc0, 0x0000, 0x2d9d, 0x0000, 0x4d88,
	0x2e3d, 0x6c6e, 0x2c82, 0x5939, 0x5949,
	0x2cef, 0x7ee, 0x7fe, 0x7fed, 0x7e3,
	0x82f, 0x83a, 0x859, 0x16a8, 0x136e,
	0x47da, 0x47e3, 0x47ec, 0x14cc, 0x58bd,
	0x24d6, 0x45ef, 0x45fa, 0x4605, 0x4643,
	0x464e, 0x4659, 0x4664, 0x466f, 0x4688,
	0x4693, 0x469e, 0x46a9, 0x46b4, 0x46e7,
	0x46f2, 0x471b, 0x4726, 0x4800, 0x480b,
	0x4816, 0x4821, 0x482c, 0xffff,
};

//////////////////////////////////////////////////////

void Create_Node(node_t& node, int size, int item, int ptr, int root, int left, int right)
{
	node.size = size;
	node.item = item;

	node.ptr = ptr;
	node.root = root;
	node.left = left;
	node.right = right;
	node.branch = -1;
}


void Insert_Node(std::deque<node_t>& tree, node_t& node)
{
	std::deque<node_t>::iterator ptr;

	ptr = tree.end();

	// insert smallest items at back
	for (int lcv = tree.size() - 1; lcv >= 0; lcv--, ptr--)
	{
		if (node.size <= tree[lcv].size) break;
	}

	tree.insert(ptr, node);
}


#ifdef DEBUG
int travel_level;
#endif

// Note: Reference variables to cut down on stack space
//       during pre-order traversal
void Travel_Node(int& tree, int& ptr)
{
	node_t& node = nodes[tree][ptr];

	if (node.left == -1)
	{
		// root
		tree_shape[tree].push_back(1);
		tree_symbol[tree].push_front(node.item);

#ifdef DEBUG
		printf( " 1 [%02X %03X %01X]", node.item, node.size, travel_level );
#endif
	}
	else
	{
#ifdef DEBUG
		printf( " 0" );
		travel_level++;
#endif

		// non-root
		tree_shape[tree].push_back(0);
		Travel_Node(tree, node.left);
		Travel_Node(tree, node.right);

#ifdef DEBUG
		travel_level--;
#endif
	}
}


void Huffman_Generate(const char* inputFilename, const char* treeFilename, const char* vectorFilename)
{
	FILE *fp, *out;
	int symbol;

	fp = fopen(inputFilename, "rb");
	out = fopen(treeFilename, "wb");
	if (!fp)
	{
		printf("Error: Could not open file \"%s\"\n", inputFilename);
		return;
	}
	if (!out)
	{
		printf("Error: Could not write to file \"%s\"\n", treeFilename);
		return;
	}

	/*------------------------------------------*/

	// Build symbol statistics first
	// These are a count of bytes seen for each preceding byte.
	int counts[256][256] = {};
	int precedingByte = EOS;
	std::ifstream input(inputFilename, std::ios::in | std::ios::binary);
	char c;
	while (input.get(c))
	{
		// Cast to unsigned
		int thisByte = (uint8_t)c;
		// Count
		++counts[precedingByte][thisByte];
		precedingByte = thisByte;
	}

	/*------------------------------------------*/

#ifdef DEBUG
	printf( "Tree location data:\n");
#endif

	// The "tree vector" file - pointers to each of the 256 trees
	std::ofstream vector(vectorFilename, std::ios::out | std::ios::binary);

	// An assemblable version
	std::vector<std::string> treeLabels;
	std::vector<std::string> treeDatas;

	for (int tree = 0; tree < 256; tree++)
	{
		std::ostringstream ss;
		ss << "HuffmanTree" << std::hex << std::setw(2) << std::setfill('0') << std::uppercase << tree;
		treeLabels.push_back(ss.str());
		
		int node_ptr;
		int tree_ptr;

		int buffer;
		int bits;

		// grab place markers
		int start = ftell(out);
		int start_ptr = start + 0x80b0 + 256 * 2;

		// start creating leaf nodes
		for (int symbol = 0; symbol < 256; symbol++)
		{
			int size = counts[tree][symbol];

			if (size != 0)
			{
				node_t& node = nodes[tree][symbol];

				// add basic node
				Create_Node(node, size, symbol, symbol, -1, -1, -1);
				Insert_Node(trees[tree], node);
			}
		}

		// build huffman tree
		node_ptr = 256;
		while (trees[tree].size() > 1)
		{
			node_t item1, item2;

			// take two smallest items
			item1 = trees[tree].back();
			trees[tree].pop_back();

			item2 = trees[tree].back();
			trees[tree].pop_back();

			// grab target memory location
			node_t& node = nodes[tree][node_ptr];
			node_t& left = nodes[tree][item1.ptr];
			node_t& right = nodes[tree][item2.ptr];

			// link nodes for encoding speed
			left.root = node_ptr;
			right.root = node_ptr;

			left.branch = 0;
			right.branch = 1;

			// merge
			Create_Node(node, left.size + right.size, -1,
			            node_ptr, -1, left.ptr, right.ptr);
			Insert_Node(trees[tree], node);

			node_ptr++;
		}

		// format tree to storable form
		if (!trees[tree].empty())
		{
			node_ptr = trees[tree][0].ptr;
			tree_ptr = tree;
			Travel_Node(tree_ptr, node_ptr);
		}

		// save data to file: symbols
		std::ostringstream treeData;
		treeData << ".db ";
		for (int symbol : tree_symbol[tree])
		{
			fputc(symbol, out);
			treeData << '$' << std::hex << std::setw(2) << std::setfill('0') << symbol << ' ';

			// bump pointer
			start_ptr++;
		}

		treeData << "\n.db";

		// save data to file: shape
		bits = 0;
		buffer = 0;
		for (int bit : tree_shape[tree])
		{
			if (bits == 0)
			{
				treeData << " %";
			}
			treeData << bit;
			buffer <<= 1;
			buffer |= bit;
			bits++;

			// flush to file
			if (bits == 8)
			{
				fputc(buffer, out);
				bits = 0;
				buffer = 0;
			}
		}

		// Flush remaining data to file
		if (bits)
		{
			while (bits < 8)
			{
				treeData << '0';
				buffer <<= 1;
				bits++;
			}
			fputc(buffer, out);
		}

		treeDatas.push_back(treeData.str());

		// no tree pointer check
		if (trees[tree].empty()) start_ptr = 0xffff;

		// Pointer to tree
		vector.put(start_ptr & 0xff);
		vector.put(start_ptr >> 8);

		// log output
#ifdef DEBUG
		printf( "(%02X) Symbols = $%03X, %06X\n", tree,
			tree_symbol[ tree ].size(), start );
#endif
	}

	std::ofstream o("foo.asm");
	o << "TreeVector:\n.dw";
	// Labels
	for (unsigned int i = 0; i < treeLabels.size(); ++i)
	{
		if (trees[i].empty())
		{
			o << " $ffff";
		}
		else
		{
			o << ' ' << treeLabels[i];
		}
	}
	o << "\n";
	// Data
	for (unsigned int i = 0; i < treeLabels.size(); ++i)
	{
		if (trees[i].empty())
		{
			continue;
		}
		o << treeLabels[i] << ":\n" << treeDatas[i] << '\n';
	}

	// final area
	printf("Trees end at: %06X\n", ftell(out) + 0x80b0 + 256 * 2);
	tree_end = ftell(out) + 0x80b0 + 256 * 2;

	printf("\n");

	fclose(fp);
	fclose(out);
}


void Huffman_Encode(char* file, char* file_out)
{
	FILE *fp, *out;
	int symbol;
	int old_tree;

	int buffer;
	int bits;

	fp = fopen(file, "rb");
	out = fopen(file_out, "wb");

	if (!fp)
	{
		printf("Error: Could not open file \"%s\"\n", file);
		return;
	}
	if (!out)
	{
		printf("Error: Could not write to file \"%s\"\n", file_out);
		return;
	}

	// Starting tree number
	old_tree = 0;
	buffer = 0;
	bits = 0;

	// Construct each Huffman code
	while ((symbol = fgetc(fp)) != EOF)
	{
		std::deque<int> codeword;
		node_t node = nodes[old_tree][symbol];

		// Work upwards through tree
		while (node.root != -1)
		{
			codeword.push_front(node.branch);
			node = nodes[old_tree][node.root];
		}

		// Write out created codeword
		while (codeword.size())
		{
			buffer <<= 1;
			buffer |= codeword[0];
			bits++;
			codeword.pop_front();

			// Flush data to file
			if (bits == 8)
			{
				fputc(buffer, out);
				bits = 0;
				buffer = 0;
			}
		}

		// Use new symbol as fresh index
		old_tree = symbol;
	}

	// Flush remaining data to file
	if (bits)
	{
		while (bits < 8)
		{
			buffer <<= 1;
			bits++;
		}
		fputc(buffer, out);
	}

	fclose(out);
	fclose(fp);
}


void Huffman_Script(const char* file, const char* file_out, const char* script_list)
{
	FILE *fp, *out = nullptr, *script_out;
	//FILE *vector1, *vector2;

	int symbol;
	int old_tree;
	std::string code;

	int buffer;
	int bits;

	int table_number;
	int table_entry;
	int table_last;
	float script_size;

	int overage;
	int offsets[6 * 2];

	// init
	table_number = 1;
	table_entry = 0;
	table_last = 0;
	script_size = 0;
	overage = 0;

	memset(offsets, 0, sizeof(offsets));

	// Open up files
	fp = fopen(file, "rb");
	script_out = fopen(script_list, "w");

	if (!fp)
	{
		printf("Error: Could not open file \"%s\"\n", file);
		return;
	}
	if (!script_out)
	{
		printf("Error: Could not open file \"script-list.txt\"\n");
		return;
	}

	fprintf(script_out, "%x script1.bin\n", tree_end);

	// Header
	printf("Text entry locations:\n\n");

	do
	{
		char file_name[256];

		// Create a new file
		if (table_entry == 0)
		{
			sprintf(file_name, "%s%d.bin", file_out, table_number);
			out = fopen(file_name, "wb");
			if (!out)
			{
				printf("Error: Could not write to file \"%s\"\n", file_name);
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

		// Construct each Huffman code
		do
		{
			std::deque<int> codeword;
			node_t node;

			// grab symbol to encode
			symbol = fgetc(fp);
			if (symbol == EOF) break;

			// find in tree
			node = nodes[old_tree][symbol];

			// Work upwards through tree
			while (node.root != -1)
			{
				codeword.push_front(node.branch);
				node = nodes[old_tree][node.root];
			}

			// Write out created codeword
			while (!codeword.empty())
			{
				buffer <<= 1;
				buffer |= codeword[0];
				bits++;

#ifdef DEBUG_SCRIPT
				printf( "%01d", codeword[0] );
#endif

				codeword.pop_front();

				// Flush data to buffer
				if (bits == 8)
				{
					code += (char)buffer;
					bits = 0;
					buffer = 0;
				}
			}

#ifdef DEBUG_SCRIPT
			printf( "~\n" );
#endif

			// Use new symbol as fresh index
			old_tree = symbol;
		}
		while (symbol != EOS);

#ifdef DEBUG_SCRIPT
		printf( "\n" );
#endif

		if (symbol == EOF) break;

		// Flush remaining data to buffer
		if (bits)
		{
			while (bits < 8)
			{
				buffer <<= 1;
				bits++;
			}
			code += buffer;
		}

		/*------------------------------------------*/

		// Defrag, splinter text
		if (overage == 0 && ftell(out) + tree_end + 1 + code.length() >= 0xbecf)
		{
			overage = 1;

			// add up volume of data
			script_size += ftell(out);
			fclose(out);

			// move to next portion
			out = fopen("script2.bin", "wb");
			tree_end = 0x6f40b - 0x6c000 + 0x4000; // page 1

			// log file
			fprintf(script_out, "%x script2.bin\n", 0x6f40b);
		}

		/*------------------------------------------*/

		if (!code.length()) continue;

		// Write out hard-coded pointers
		int ptr = ftell(out) + tree_end;
		fprintf(script_out, "%x hex_%02x%02x.bin\n",
		        pointers[table_entry] + 1, ptr & 0xff, (ptr >> 8) & 0xff);

		table_entry++;
		while (pointers[table_entry] == 0x0000)
		{
			table_entry++;
			fprintf(script_out, "%x hex_%02x%02x.bin\n",
			        pointers[table_entry] + 1, ptr & 0xff, (ptr >> 8) & 0xff);
			table_entry++;
		}

		// Now write to file
		//fputc( code.length(), out );
		fwrite(code.c_str(), 1, code.length(), out);

		// adjustments
		table_last += (1 + code.length());
	}
	while (symbol != EOF);

	// add up last page
	if (out)
	{
		script_size += ftell(out);
	}

	// size status
	script_size /= 1024.0;
	printf("\n\nTotal size: %.2f KB\n", script_size);

	/*------------------------------------------*/

	//fclose( vector1 );
	//fclose( vector2 );
	fclose(script_out);
	fclose(out);
	fclose(fp);
}


void Huffman_Compress(const char* inputFilename, const char* outputFilename, const char* treeFilename, const char* vectorFilename, const char* listFilename)
{
	Huffman_Generate(inputFilename, treeFilename, vectorFilename);
	Huffman_Script(inputFilename, outputFilename, listFilename);
}
