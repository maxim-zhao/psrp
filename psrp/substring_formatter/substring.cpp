/*
Phantasy Star: Substring Table Creater
*/

#include <cstdio>

#include <deque>
#include <string>

using namespace::std;

constexpr auto start_code = 0x60;

constexpr auto switch_code = 0xFFFF;
constexpr auto start_code2 = 0xFFFF;

int main(int argc, char** argv)
{
    if (argc < 2)
    {
        printf("Usage: substring_formatter.exe <# codes>\n");
        return 0;
    }

    int code_amount;
    sscanf(argv[1], "%X", &code_amount);

    // open files
    FILE* fp = fopen("words.txt", "r");
    FILE* out = fopen("words_final.txt", "w");
    FILE* dict = fopen("dict.txt", "w");

    // read each string and add conversion code
    char line[8192];
    int code = start_code;
    deque<string> list;
    while (fgets(line, sizeof(line), fp))
    {
        // remove '\n'
        if (line[strlen(line) - 1] == 0x0a) line[strlen(line) - 1] = 0;

        // dictionary word
        fprintf(dict, "%s\n", line);

        // print <string>
        fprintf(out, "%02X=%s\n", code, line);

        // queue up
        list.emplace_back(line);

        // bump substring assignment range
        code++;

        // formatting
        if (code % 16 == 0)
        {
            fprintf(out, "\n");

            // print <string> / <space><string>
            for (int lcv = code - 16; lcv < code; lcv++)
            {
                //fprintf( out, "D0%02X= %s\n", lcv, list[0].c_str() );
                list.pop_front();
            }

            fprintf(out, "\n");
        }

        if (code == switch_code) code = start_code2;
        if (code == start_code + code_amount) break;
    }

    // dictionary EOF
    fprintf(dict, "#\n");

    fclose(fp);
    fclose(out);
    fclose(dict);

    return 0;
}
