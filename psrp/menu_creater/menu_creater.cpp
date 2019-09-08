/*
Phantasy Star: Menu Creater
*/

#include <cstdio>
#include <exception>

extern void ConvertSymbols(const char* listName, const char* tableName, const char* outName);

int main(int argc, const char** argv)
{
    // Assert proper usage
    if (argc != 4)
    {
        printf("Usage: %s <list file> <table file> <output name>\n", argv[0]);
        return -1;
    }

    try
    {
        ConvertSymbols(argv[1], argv[2], argv[3]);
    }
    catch (std::exception& ex)
    {
        printf("%s\n", ex.what());
        return -1;
    }

    return 0;
}
