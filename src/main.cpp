#include <stdio.h>

extern "C" void MyPrintf(const char* fmt, ...);

int main()
{
    MyPrintf("%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", 100, 200, 300, 400, 500, 600, 700, 800, 900);
    MyPrintf("\n");
    MyPrintf("%%%s%c\n\n", "Hello, my friends", '!');
    return 0;
}
