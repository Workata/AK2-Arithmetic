all: mnozenie

mnozenie.o: mnozenie.s
	as -g --32  mnozenie.s -o mnozenie.o

mnozenie: mnozenie.o
	ld -m elf_i386 mnozenie.o -o mnozenie

