	SYSEXIT = 1
	EXIT_SUCCESS = 0
	SYSWRITE = 4
	STDOUT = 1
	SYSREAD = 3
	STDIN = 0

	.global _start	

	.data
	
	# potrzebne do wypisania liczby jako kod ASCII
	cyfra: .long 0x00
	cyfry_len = .-cyfra
	
	# dlugosc pierwszej liczby (w bajtach) - trzeba okreslic!
	liczba1_len = 8      
	# dlugosc drugiej liczby (w bajtach) - trzeba okreslic!
	liczba2_len=  8      
	# dlugosc ciagu znakow na wejsciu (w bajtach) - obliczana
	ASCIIstring_len = (liczba1_len+liczba2_len)*2  

	# znak 'enter' do wypisania po zakonczeniu programu
	enter: .ascii "\n"
	enter_len = .-enter
	
	# maksymalna liczba slow (32b) do wypisania na wyjsciu - obliczana
	wordsOnStack =  (liczba1_len+liczba2_len)/4

	_start:	# Mnozenie w kolejnosci: liczba2 x liczba1

	# ----------WCZYTANIE--LICZB--JAKO--JEDEN---CIAG----

	mov $SYSREAD, %eax
	mov $STDIN, %ebx
	mov $ASCIIstring, %ecx
	mov $ASCIIstring_len, %edx
	int $0x80
	
	#---------------CONVERT ASCII TO HEX----------------
	mov $0, %edi
	mov $0, %esi
	mov $0, %edx

	_ASCIItoHEX:
	cmp $32, %esi
	je mnozenie

	mov ASCIIstring(,%esi,1), %al
	clc
	cmp $0x39, %al
	jg _letterAH
	
	sub $0x30, %al
	_checkPosition:
	clc
	cmp $0, %edx
	jne _secondDigit

	add %al, liczba1(,%edi,1)
	mov $1, %edx
	inc %esi
	jmp _ASCIItoHEX

	_secondDigit:
	mov $0x10, %bl
	mul %bl
	add %eax, liczba1(,%edi,1)
	mov $0, %edx
	inc %esi
	inc %edi
	jmp _ASCIItoHEX

	_letterAH:
	sub $0x37, %al
	jmp _checkPosition


	#-----------(END)---CONVERT ASCII TO HEX-------------	

	
	#jmp mnozenie
	
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
	# liczba 32 bitowych blokow (slow)  ma byc w edx	
	
	_wypiszStackPrep:

	mov $wordsOnStack, %edx
	mov $0, %edi
	#push wynik(,%edi,4)
	#mov $1, %edi
	#push wynik(,%edi,4)
	mov $wordsOnStack, %esi	

	_wypiszStack:	#Funkcja wypisujaca wynik ze stosu
	dec %esi
	clc
	mov $0, %edi	
	mov wynik(,%esi,4), %eax  #pop %eax
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
	.lcomm liczba1, liczba1_len	# dlugosc liczby1 w bajtach
	.lcomm liczba2, liczba2_len	# dlugosc liczby2 w bajtach
	.lcomm ASCIIstring, ASCIIstring_len	# liczba znakow w pliku wej. (bajtow)
	.lcomm wynik, 256
	
	
