/*
Phantasy Star: RLE Compression
*/

#include <cstdio>

///////////////////////////////////////////////////////

void RLE_Decode(FILE* fp, FILE* out, int offset)
{
    // init
    int buf_ptr = 0;
    int loops = 0;

    fseek(fp, offset, SEEK_SET);

    unsigned char buffer[0x4000];

    // start going through each color plane
    while (loops < 4)
    {
        buf_ptr = loops;

        for (;;)
        {
            // read encoding method bits
            const int data = fgetc(fp);

            // terminate
            if (data == 0) break;

            // determine run length
            int run = data & 0x7f;

            // Raw byte copy
            if (data & 0x80)
            {
                while (run--)
                {
                    buffer[buf_ptr] = fgetc(fp);
                    buf_ptr += 4;
                }
            }
            else
            {
                // RLE
                const int value = fgetc(fp);
                while (run--)
                {
                    buffer[buf_ptr] = value;
                    buf_ptr += 4;
                }
            }
        } // end decode

        loops++;
    } // stop full decoder

    // close shop
    buf_ptr -= (4 - 1);
    fwrite(buffer, 1, buf_ptr, out);
}
