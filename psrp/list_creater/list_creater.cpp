/*
Phantasy Star: List Creater
*/

#include <cstdio>

extern int Convert_Symbols(const char* list_name, const char* table_name, const char* out_name);

int main(int argc, const char** argv)
{
    // Assert proper usage
    if (argc != 3)
    {
        printf("Usage: %s <list file> <table file>\n", argv[0]);
        return -1;
    }

    // phase 1: text conversion
    if (Convert_Symbols(argv[1], argv[2], "pass1.bin")) return -1;

    return 0;
}
