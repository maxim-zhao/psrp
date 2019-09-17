/*
Phantasy Star: Script Inserter
*/

#include <cstdio>


extern int Convert_Symbols(const char* list_name, const char* table_name, const char* out_name);
extern void Huffman_Compress(const char* file_in, const char* file_out, const char* tree_out, const char* tree_vector_filename, const char* script_list);


int main(int argc, const char** argv)
{
	// Assert proper usage
	if (argc != 7)
	{
		printf("Usage: script_inserter <script name> <table file> <output file> <output trees file> <output vector file> <output script list file>\n");
		return -1;
	}

	// phase 1: Script conversion
	Convert_Symbols(argv[1], argv[2], "pass1.bin");

	// phase 2: Huffman encoding
	Huffman_Compress("pass1.bin", argv[3], argv[4], argv[5], argv[6]);

	return 0;
}
