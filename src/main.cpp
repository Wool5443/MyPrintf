#include <stdio.h>
#include <stdlib.h>

extern "C" int MyPrintf(const char* fmt, ...);

int main()
{
    int x = 45;
    MyPrintf("bin = %b\n", x);
    MyPrintf("oct = %o\n", x);
    MyPrintf("dec = %d\n", x);
    MyPrintf("hex = %x\n", x);
    MyPrintf("ptr = %p\n", &x);
    printf("ptr = %p\n", &x);

    MyPrintf("хуй");
    MyPrintf("хуй");
    MyPrintf("хуй");
    MyPrintf("хуй");
    MyPrintf("\n");

    int strl = 60000;
    char* hugeString = (char*)calloc(strl, 1);
    for (int i = 0; i < strl - 2; i++)
        hugeString[i] = 'A' + (i % 26);
    hugeString[strl - 4] = '%';
    hugeString[strl - 3] = 'b';
    hugeString[strl - 2] = '\n';

    MyPrintf(hugeString, 10000);

    return 0;
}
