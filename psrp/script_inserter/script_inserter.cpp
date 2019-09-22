/*
Phantasy Star: Script Inserter
*/

#include <cstdio>
#include <exception>
#include <stdexcept>
#include <vector>


extern void Convert_Symbols(const char* listName, const char* tableName, std::vector<std::pair<std::string, std::vector<uint8_t>>>& script);
extern void Huffman_Compress(const char* outputFilename, const char* treeFilename, const char* listFilename, const std::vector<std::pair<std::string, std::vector<uint8_t>>>& script);


int main(int argc, const char** argv)
{
	try
	{
		// Assert proper usage
		if (argc != 6)
		{
			throw std::runtime_error("Usage: script_inserter <script name> <table file> <output file> <output Huffman data file> <output script list file>");
		}

		// phase 1: Script conversion
		std::vector<std::pair<std::string, std::vector<uint8_t>>> script;
		Convert_Symbols(argv[1], argv[2], script);

		// phase 2: Huffman encoding
		Huffman_Compress(argv[3], argv[4], argv[5], script);
	}
	catch (const std::exception& e)
	{
		fprintf(stderr, "%s\n", e.what());
		return -1;
	}
	
	return 0;
}
