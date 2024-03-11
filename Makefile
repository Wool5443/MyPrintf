main : obj/main.o obj/MyPrintf.o
	g++ $^ -o $@ -no-pie

obj/main.o : src/main.cpp
	g++ -Wall -O0 -g -D _DEBUG -ggdb3 $^ -c -o $@

obj/MyPrintf.o : src/MyPrintf.s
	nasm -f elf64 -F dwarf $^ -o $@

clean:
	rm obj/* main
