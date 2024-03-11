debug : CFLAGS = -Wall -O0 -g -D _DEBUG -ggdb3
debug : SFLAGS = -f elf64 -F dwarf
debug  : main

release : CFLAGS = -Wall -O3
release : SFLAGS = -f elf64
release : main

main : obj/main.o obj/MyPrintf.o obj/IntToStrDec.o
	g++ $(CFLAGS) $^ -o $@ -no-pie

obj/main.o : src/main.cpp
	g++ $(CFLAGS) $^ -c -o $@

obj/MyPrintf.o : src/MyPrintf.s
	nasm $(SFLAGS) $^ -o $@

obj/IntToStrDec.o : src/IntToStrDec.s
	nasm $(SFLAGS) $^ -o $@

clean:
	rm obj/* main
