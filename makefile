all: mnozenie dodawanie odejmowanie

mnozenie.o: mnozenie.s
	as -g --32  mnozenie.s -o mnozenie.o

mnozenie: mnozenie.o
	ld -m elf_i386 mnozenie.o -o mnozenie

dodawanie.o: dodawanie.s
	as -g --32  dodawanie.s -o dodawanie.o

dodawanie: dodawanie.o
	ld -m elf_i386 dodawanie.o -o dodawanie

odejmowanie.o: odejmowanie.s
	as -g --32  odejmowanie.s -o odejmowanie.o

odejmowanie: odejmowanie.o
	ld -m elf_i386 odejmowanie.o -o odejmowanie

