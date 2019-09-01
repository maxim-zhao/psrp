/*
Phantasy Star: Credits encoder
by Maxim
*/

#include <cstdio>
#include <cstring>
#include <cstdint>

const int base = 0xbdbc;

int main(int argc, char** argv)
{
    // Assert proper usage
    if (argc != 3) 
    {
        printf("Usage: %s <input file> <output file>\n", argv[0]);
        return -1;
    }

    // Open files
    FILE* in;
    if (fopen_s(&in, argv[1], "r") != 0)
    {
        printf("Error opening %s", argv[1]);
        return -1;
    }

    // count how many credits
    int numScreens = 0;
    char s[1024]; // overflowable buffer
    while (!feof(in)) 
    {
        fgets(s, 1024, in);
        if (s[0] == '-') 
        {
            ++numScreens;
        }
    }

    printf("%d screens\n", numScreens);

    fseek(in, 0, SEEK_SET);

    uint8_t buffer[1024]; // output

    uint8_t* data = buffer + numScreens * 2; // data starts after pointers

    // encode them
    int screensDone = 0;
    int linesThisScreen = 0;
    uint8_t* counter = data++;
    while (!feof(in)) 
    {
        fgets(s, 1024, in);
        if (s[0] != '-') 
        {
            // parse string
            int x, y;
            if (sscanf_s(s, "%d,%d", &x, &y) == 2)
            {
                const int offset = 0xd000 + 64 * y + 2 * x;
                // offset
                *data++ = (offset >> 0) & 0xff;
                *data++ = (offset >> 8) & 0xff;
                // get text
                char * p;
                for (p = s; *p != ' '; ++p) {}
                ++p;
                // length
                const size_t length = strlen(p) - 1;
                *data++ = (uint8_t)length;
                // text
                memcpy(data, p, length);
                data += length;
                // line counter
                ++linesThisScreen;
            }
            else 
            {
                printf("error: \"%s\"\n", s);
            }
        }
        else 
        {
            // write pointer
            const auto ptr = counter - buffer + base;
            buffer[screensDone * 2 + 0] = ptr >> 0 & 0xff;
            buffer[screensDone * 2 + 1] = ptr >> 8 & 0xff;
            ++screensDone;
            // write the line count
            *counter = linesThisScreen;
            linesThisScreen = 0;
            // make room for the next counter
            counter = data++;
        }
    }

    fclose(in);

    FILE* out;
    if (fopen_s(&out, argv[2], "wb") != 0)
    {
        printf("Error opening %s", argv[2]);
        return -1;
    }

    fwrite(buffer, 1, data - buffer - 1, out);

    fclose(out);

    return 0;
}
