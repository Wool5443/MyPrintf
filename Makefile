debug : CFLAGS = -Wall -O0 -g -D _DEBUG -ggdb3
debug : SFLAGS = -f elf64 -F dwarf
debug  : main

release : CFLAGS = -Wall -O3
release : SFLAGS = -f elf64
release : main

main : obj/main.o obj/myprintf.o obj/inttostr.o obj/strlen.o
	g++ $(CFLAGS) $^ -o $@ -no-pie

obj/main.o : src/main.cpp
	g++ $(CFLAGS) $^ -c -o $@

obj/myprintf.o : src/myprintf.s
	nasm $(SFLAGS) $^ -o $@

obj/inttostr.o : src/inttostr.s
	nasm $(SFLAGS) $^ -o $@

obj/strlen.o : src/strlen.s
	nasm $(SFLAGS) $^ -o $@

clean:
	rm obj/* main
