/*
Phantasy Star: RLE Compression
*/

#include <cstdio>
#include <vector>

#define DEBUG_RLE

typedef struct
{
    int pos;
    int ptr;
    int len;
    int type;
} run;

unsigned char buffer[0x4000];

///////////////////////////////////////////////////////

int ptr = 0;

int min_match = 1 + 1;
int max_match = 0x7f; // 7-bits


void find_rle(int buf_ptr, int& length, int& pos, int size)
{
    int longestLength = 1;
    const int longestPtr = buf_ptr;

    // find longest RLE string
    for (int lcv = buf_ptr; lcv + 4 < size; lcv += 4)
    {
        if (buffer[lcv] != buffer[lcv + 4]) break;
        longestLength++;

        if (longestLength == max_match) break;
    }

    // output findings
    length = longestLength;
    pos = longestPtr;
}


void rle_encode(FILE* in, FILE* out)
{
    std::vector<run> table;

    int loops = 0;

    // read whole bitmap
    const int size = fread(buffer, 1, 0x4000, in);
    fclose(in);

    // buf_ptr going through each color plane
    while (loops < 4)
    {
        run rec;
        int rawCount;

        int bufIndex = loops;
        rawCount = 0;
        table.clear();

        ///////////////////////////////////////////////////////////////

        // Step 1: Find RLE strings

        while (bufIndex < size)
        {
            int length, pos;

            if (loops == 1)
                loops = 1;

            // Go find the longest substring match
            find_rle(bufIndex, length, pos, size);

            // Raw + 2 RLE's + Raw = wastes 1 byte
            if (length == min_match)
            {
                find_rle(bufIndex + 8, length, pos, size);

                if (length == 1 && rawCount)
                {
                    // No substrings found; try again
                    bufIndex += 4;
                    rawCount++;
                    continue;
                }

                find_rle(bufIndex, length, pos, size);
            }

            if (length >= min_match)
            {
                // Add raw record
                while (rawCount)
                {
                    rec.pos = -1;
                    rec.len = rawCount > max_match ? max_match : rawCount;
                    rec.type = 1;

                    table.push_back(rec);

                    rawCount -= max_match;
                    if (rawCount < 0) rawCount = 0;
                }

                // Found substring match; record and re-do
                rec.pos = bufIndex;
                rec.len = length;
                rec.type = 2;

                table.push_back(rec);

                // Fast update
                bufIndex += 4 * length;
            }
            else
            {
                // No substrings found; try again
                bufIndex += 4;
                rawCount++;
            }
        } // end scan

        // Add raw record
        while (rawCount)
        {
            rec.pos = -1;
            rec.len = rawCount > max_match ? max_match : rawCount;
            rec.type = 1;

            table.push_back(rec);

            rawCount -= max_match;
            if (rawCount < 0) rawCount = 0;
        }

        // insert dummy entry
        rec.pos = -1;
        rec.type = 0;
        table.push_back(rec);

        ///////////////////////////////////////////////////////////////

        // Step 2: Prepare encoding methods

        int recIndex = 0;

        bufIndex = loops;

        for (;;)
        {
            rec = table[recIndex];

#ifdef DEBUG_RLE
            printf("%04X, %d\n", ftell(out), rec.type);
#endif

            // exit condition
            if (rec.type == 0) break;

            if (rec.type == 2)
            {
                // RLE
                fputc(rec.len, out);
                fputc(buffer[bufIndex], out);

                bufIndex += rec.len * 4;
            }
            else
            {
                // Raw
                fputc(rec.len | 0x80, out);
                while (rec.len--)
                {
                    fputc(buffer[bufIndex], out);
                    bufIndex += 4;
                }
            }

            recIndex++;
        } // end encode

        ///////////////////////////////////////////////////////////////

        // terminate byte
        fputc(0x00, out);
        loops++;
    } // stop full encoder

    // close shop
    fclose(out);
}
