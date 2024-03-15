#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern "C" int MyPrintf(const char* fmt, ...);

void perfFuncPrintf(size_t sampleSize)
{
    const char* fmt = "%d%d%d%d%d\n";

    for (size_t i = 0; i < sampleSize; i++)
        printf(fmt, i, i, i, i, i);
}


void perfFuncMyPrintf(size_t sampleSize)
{
    const char* fmt = "%d%d%d%d%d\n";

    for (size_t i = 0; i < sampleSize; i++)
        MyPrintf(fmt, i, i, i, i, i);
}

int main()
{
    int x = 45;
    MyPrintf("bin = %b\n", x);
    MyPrintf("oct = %o\n", x);
    MyPrintf("dec = %d %d %d %d %d %d %d\n%d %s %x %d%%%c%b\n", x, x, x, x, x, x, x, -1, "love", 3802, 100, 33, 30);
    MyPrintf("hex = %x\n", x);
    MyPrintf("ptr = %p\n", &x);
    printf("ptr = %p\n", &x);

    MyPrintf("х#й");
    MyPrintf("х#й");
    MyPrintf("х#й");
    MyPrintf("х#й");
    MyPrintf("\n");

    // int strl = 60000;
    // char* hugeString = (char*)calloc(strl, 1);
    // for (int i = 0; i < strl - 2; i++)
    //     hugeString[i] = 'A' + (i % 26);
    // hugeString[strl - 4] = '%';
    // hugeString[strl - 3] = 'b';
    // hugeString[strl - 2] = '\n';

    // MyPrintf(hugeString, 10000);

    size_t sampleSize = 100000;
    // perfFuncPrintf(sampleSize);
    // perfFuncMyPrintf(sampleSize);

    // Primer 0xBADDED

    MyPrintf("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, -1, "love", 3802, 100, 33, 126,
                                                           -1, "love", 3802, 100, 33, 126);

    return 0;
}
