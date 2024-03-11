#include <stdio.h>

extern "C" void MyPrintf(const char* fmt, ...);

int main()
{
    int b = 185000;
    MyPrintf("x = %d\n", b);
    return 0;
}
