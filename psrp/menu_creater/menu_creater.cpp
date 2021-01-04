/*
Phantasy Star: Menu Creater
*/

#include <cstdio>
#include <exception>
#include <string>

extern void ConvertSymbols(const std::string& yamlFile, const std::string& language, const std::string& outName, const std::string& patchesName);

int main(int argc, const char** argv)
{
    // Assert proper usage
    if (argc != 5)
    {
        printf("Usage: %s <menu yaml> <language> <data output name> <patches output name>\n", argv[0]);
        return -1;
    }

    try
    {
        ConvertSymbols(argv[1], argv[2], argv[3], argv[4]);
    }
    catch (std::exception& ex)
    {
        printf("%s\n", ex.what());
        return -1;
    }

    return 0;
}
