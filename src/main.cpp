#include <stdio.h>
#include <stdlib.h>

extern "C" int MyPrintf(const char* fmt, ...);

int main()
{
    int x = -45;
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

    char* hugeString = (char*)calloc(1, 2048);
    for (int i = 0; i < 2046; i++)
        hugeString[i] = 'b';
    hugeString[2046] = '\n';

    printf("%s\n", hugeString);

    return 0;
}
