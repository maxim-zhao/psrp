/*
Phantasy Star: Script Inserter
*/

#include <cstdio>
#include <exception>
#include <stdexcept>


extern void Convert_Symbols(const char* listName, const char* tableName, const char* outName);
extern void Huffman_Compress(const char* inputFilename, const char* outputFilename, const char* treeFilename, const char* vectorFilename, const char* listFilename);


int main(int argc, const char** argv)
{
	try
	{
		// Assert proper usage
		if (argc != 7)
		{
			throw std::runtime_error("Usage: script_inserter <script name> <table file> <output file> <output trees file> <output vector file> <output script list file>");
		}

		// phase 1: Script conversion
		Convert_Symbols(argv[1], argv[2], "pass1.bin");

		// phase 2: Huffman encoding
		Huffman_Compress("pass1.bin", argv[3], argv[4], argv[5], argv[6]);
	}
	catch (const std::exception& e)
	{
		fprintf(stderr, "%s\n", e.what());
		return -1;
	}
	
	return 0;
}
