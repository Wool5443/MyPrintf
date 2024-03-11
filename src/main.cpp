#include <stdio.h>

extern "C" void MyPrintf(const char* fmt, ...);

int main()
{
    MyPrintf("x = %d\n", 10);
    return 0;
}
