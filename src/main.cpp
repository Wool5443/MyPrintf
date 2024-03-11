#include <stdio.h>

extern "C" int MyPrintf(const char* fmt, ...);

int main()
{
    MyPrintf("%b\n\n", 7);
    MyPrintf("%%%s%c\n\n", "Hello, my friends", '!');
    MyPrintf("Last print exit code = %d\n", MyPrintf("%g\n"));
    return 0;
}
