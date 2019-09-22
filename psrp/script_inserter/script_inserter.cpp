/*
Phantasy Star: Script Inserter
*/

#include <cstdio>
#include <exception>
#include <stdexcept>
#include <vector>
#include "ScriptItem.h"


extern void Convert_Symbols(const std::string& scriptFilename, const std::string& tableFilename, std::vector<ScriptItem>& script);
extern void Huffman_Compress(const std::string& outputFilename, const std::string& treeFilename, const std::vector<ScriptItem>& script);


int main(int argc, const char** argv)
{
	try
	{
		// Assert proper usage
		if (argc != 5)
		{
			throw std::runtime_error("Usage: script_inserter <script name> <table file> <output script file> <output Huffman data file>");
		}

		// phase 1: Script conversion
		std::vector<ScriptItem> script;
		Convert_Symbols(argv[1], argv[2], script);

		// phase 2: Huffman encoding
		Huffman_Compress(argv[3], argv[4], script);
	}
	catch (const std::exception& e)
	{
		fprintf(stderr, "%s\n", e.what());
		return -1;
	}
	
	return 0;
}
