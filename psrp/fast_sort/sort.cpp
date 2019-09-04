// Phantasy Star: List sorter and pointer table creater
#include <cstdio>

int main(int argc, char** argv)
{
    int MAIN = argc > 2 ? 1 : 0;

    int address, offset;
    char junk[4096];
    int list1[4096], list2[4096], index = 0;

    FILE* in = fopen(argv[1], "r");
    while (fscanf(in, "%X %X", &address, &offset))
    {
        fgets(junk, sizeof(junk), in);

        if (address == -1 && offset == -1) break;

        list1[index] = address;
        list2[index] = offset;
        index++;
    }
    fclose(in);

    int loop = 0;
    int old_lowest = -1;

    if (MAIN) printf("\t");

    for (int lcv = 0; lcv < index; lcv++)
    {
        int lowest = list2[0];
        int offset = list1[0];
        int spot = 0;

        for (int lcv2 = 1; lcv2 < index; lcv2++)
        {
            if (lowest > list2[lcv2])
            {
                // new lower
                lowest = list2[lcv2];
                spot = lcv2;
                offset = list1[lcv2];
            }
            else if (lowest == list2[lcv2] && offset > list1[lcv2])
            {
                // swap
                int old = list1[lcv2];
                list1[lcv2] = list1[spot];
                list1[spot] = old;

                old = list2[lcv2];
                list2[lcv2] = list2[spot];
                list2[spot] = old;

                offset = list1[spot];
            }
        }

        if (MAIN)
        {
            if (old_lowest == list2[spot]) printf("0x0000, ");
            printf("0x%x, ", list1[spot]);

            old_lowest = list2[spot];
            list2[spot] = 0xffff;

            // formatting
            loop++;
            if (loop == 5)
            {
                printf("\n\t");
                loop = 0;
            }
        }
        else
        {
            printf("%X %04X\n", list1[spot], list2[spot]);
            list2[spot] = 0xffff;
        }
    }

    if (MAIN) { printf("0xffff,\n"); }

    return 0;
}
