/*
Phantasy Star: Bitmap Encoder
*/

#include <cstdio>

extern void rle_encode(FILE* in, FILE* out);

int main(int argc, char** argv)
{
    if (argc < 3)
    {
        printf("Usage: bitmap_encode <input file> <output file>\n");
        return -1;
    }

    // check for file errors
    FILE* in = fopen(argv[1], "rb");
    FILE* out = fopen(argv[2], "wb");
    if (!in)
    {
        printf("Error: Could not open file '%s' for reading\n", argv[1]);
        return -1;
    }
    if (!out)
    {
        printf("Error: Could not open file '%s' for writing\n", argv[2]);
        return -1;
    }

    // re-crunch data
    rle_encode(in, out);

    fclose(in);
    fclose(out);

    return 0;
}
