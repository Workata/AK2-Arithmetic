	SYSEXIT = 1
	EXIT_SUCCESS = 0
	SYSWRITE = 4
	STDOUT = 1
	SYSREAD = 3
	STDIN = 0

	.global _start	

	.data

	cyfra: .long 0x00
	cyfry_len = .-cyfra

	liczba1:
		.long 0x103040FF#, 0x701100FF#,  0x45100020 , 0x08570030

	liczba1_len = .-liczba1  #4
	
	liczba2:
		.long 0xF04050FF#, 0x00220026#, 0x321000CB , 0x04520031
	
	liczba2_len=  .-liczba2  #4

	enter: .ascii "\n"
	enter_len = .-enter
	
	#regOnStack = (liczba1_len+liczba2_len)/4

	_start:	#liczba2 x liczba1

	#mov $SYSREAD, %eax
	#mov $STDIN, %ebx
	#mov $liczba1, %ecx
	#mov $16, %edx
	#int $0x80
	
	#mov $regOnStack, %eax
	
	jmp mnozenie
	
	_notLetter:
	add $0x30, %dx
	jmp _cont

	
	_letter:
	add $0x37, %dx
	ret
	
	_checkValue:
	clc
	cmp $0x09, %dx
	jle _notLetter
	call _letter
	_cont:
	ret



	#------------------POCZATEK----WYPISYWANIA----LICZB----
	# liczba 32 biowych blokow ma byc w edx	
	
	_wypiszStackPrep:

	mov $2, %edx
	mov $0, %edi
	push wynik(,%edi,4)
	mov $1, %edi
	push wynik(,%edi,4)	

	_wypiszStack:	#Funkcja wypisujaca wynik ze stosu

	clc
	mov $0, %edi	
	pop %eax
	push %edx	# store edx
	

	mov $8, %ecx	
	_pushDigit:

	mov $0, %dx
	mov $0x00000010, %ebx
	div %ebx
	call _checkValue
	push %edx

	dec %ecx
	cmp $0, %ecx
	jne _pushDigit

		
	mov $8, %ecx
	_showDigit:
	
	pop %edx
	mov %dl, cyfra(,%edi,1)
	
	push %ecx	

	mov $SYSWRITE, %eax
	mov $STDOUT, %ebx
	mov $cyfra, %ecx
	mov $cyfry_len, %edx
	int $0x80

	pop %ecx
	dec %ecx
	cmp $0, %ecx
	jne _showDigit
	
	
	pop %edx
	dec %edx
	clc
	cmp $0,%edx	# liczba 32 bitowych blokow do wypisania w edx
	je _exit
	jmp _wypiszStack  	

	#-------KONIEC WYPISYWANIA LICZB--------------------------	

	mnozenie:

	clc
	pushf
	mov $0, %edi	#indeks petli zewnetrznej
	mov $0, %esi	#indeks petli wewnetrznej


	#wyzerowanie bufora
	zerujWynik:
	mov $0x00000000, %eax
	mov %eax, wynik(,%edi,4)
	inc %edi
	cmp $256, %edi
	jl zerujWynik

	mov $0,%edi


	petlaZew:

	mov liczba1(,%edi,1), %bl


	petlaWew:

	mov %ah, %bh	#zapamietanie starszej czescie wyniku z poprz. iter.	

	mov liczba2(,%esi,1), %al
	mul %bl				#wynik mnozenia w %ax		
	
	popf	#przeniesienie wynikajace z dodawania poprz. star. czesc.
	adc %bh, %al	#dodanie starszej czescie z poprzedniego obiegu
	pushf

	mov %edi,%ecx	#obliczanie indeksu iloczynu czesciowego w wyniku
	add %esi, %ecx	#suma indeksow
	
	add %al, wynik(,%ecx,1)
	jc dodajPrzeniesienieDoStarszejCzesci
	cont:	

	inc %esi
	cmp $liczba2_len, %esi
	jl petlaWew

#petla wewnetrzna sie konczyla, dodaj ostatnie przeniesienie w tej serii
	#starsza czesc jest teraz w ah bo jescze jej nie przenioslem	
	#zewnetrzna juz zostala inkrementowana, oblicz nowy indeks
	mov %edi, %ecx
	add %esi, %ecx

	popf
	adc $0, %ah	#dodanie mozliwego przeniesienia ze wcze. sumy
	pushf
	

	add %ah, wynik(,%ecx,1)	#dodaj ostatnia starsza  czesc

	#iteracja petli zwenetrznej
	mov $0, %esi	#wyzeruj indeks wewnetrznej
	mov $0, %ah	#wyzeruj starsza czesc
	inc %edi	#inkrementuj zewnetrzna
	cmp $liczba1_len, %edi	#sprawdzamy czy zewnetrzna sie zakonczyla
	jl petlaZew
	
	jmp _wypiszStackPrep	#jezeli sie zakonczyla to wypisz i wyjdz
	

	#przeniesienie wynikajace z dodawania do wyniku
	dodajPrzeniesienieDoStarszejCzesci:
	add $1, %bh
	add $1, %ah	#przyda sie przy ostatnim obiegu petli wew

	clc	#wyczysc przeniesienie
	jmp cont
	

	
	_exit:

	mov $SYSWRITE, %eax
	mov $STDOUT, %ebx
	mov $enter, %ecx
	mov $enter_len, %edx
	int $0x80

	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80


	.bss
	#.lcomm liczba1, 8
	#.lcomm liczba2, 8
	.lcomm wynik, 256
	#wynik: .space 256
	
	
