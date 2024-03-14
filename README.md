# MyPrintf

## This is my version of printf written purely in assembly.

## Supported specifiers
```c
int x = 45;
MyPrintf("bin = %b\n", x); // 0b101101
MyPrintf("oct = %o\n", x); // 0o55
MyPrintf("dec = %d\n", x); // 45
MyPrintf("hex = %x\n", x); // 0x2d
MyPrintf("ptr = %p\n", &x); // 0x7ffe7c0b35f4
MyPrintf("char = %c\n", '!'); // !
MyPrintf("string = %s\n", "Hi!!!"); // Hi!!!
MyPrintf("bin = %b\n", x); // 0b101101
```

## Usage
Compile your project with the source file and add
this line to your cpp file:
```c++
extern "C" int MyPrintf(const char* fmt, ...);
```
On C just exclude "C" part.

## Implementation
This printf uses jump table to handle different
specifiers.

## Fun fact
My printf is **4** times faster than the C one!!!
![alt text](image.png)
