#include <stdio.h>

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
    return 0;
}
