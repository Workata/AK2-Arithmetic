	.code32
	SYSEXIT = 1
	EXIT_SUCCESS = 0
	SYSWRITE = 4
	STDOUT = 1
	SYSREAD = 3
	STDIN = 0

	.global _start

	.data
	
	# wielkosc liczb w bajtach
	liczba1_len= 8	
	liczba2_len= 8
	# wielkosc liczb w slowach
	liczba1_len_word = liczba1_len/4
	liczba2_len_word = liczba2_len/4
	
	cyfra: .long 0x00	
	cyfry_len=.-cyfra

	# dlugosc liczby znakow na wejsciu (w ba
	ASCIIstring_len = 32	
	
	enter: .ascii "\n"
	enter_len = .-enter

	# zakladajac, ze liczba 2 jest nie dluzsza niz 1
	wordsOnStack = liczba1_len_word+1
	# w przeciwnym wypadku powinno byc liczba2_len_word +1

	_start:

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
	je dodawanie

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

	dodawanie:
	mov $0, %edx	# wyzerowanie licznika indeksu wyniku
	mov $0, %edi	# wyzerowanie licznika indeksu liczby 1
	mov $0, %esi	# wyzerowanie licznika indeksu liczby 2

	#wyzerowanie bufora
	zerujWynik:
	mov $0x00000000, %eax
	mov %eax, wynik(,%edi,4)
	inc %edi
	cmp $256, %edi
	jl zerujWynik

	mov $0,%edi


	clc	
	jmp _dodawaniePierwszyRaz


	_drugaSieSkonczylaAleSprawdzCzyPierwszaTez:
	cmp $liczba1_len_word, %edi	#jezeli pierwsza tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _drugaSieSkonczyla
	
	_pierwszaSieSkonczylaAleSprawdzCzyDrugaTez:
	cmp $liczba2_len_word, %esi	#jezeli druga tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _pierwszaSieSkonczyla


	_drugaSieSkonczyla:
	popf

	mov $0,%eax
	adc liczba1(,%edi,4),%eax
	mov %eax, wynik(,%edx,4)        # push %eax
	inc %edi
	inc %edx
	pushf
	
	cmp $liczba1_len_word, %edi #jezeli pierwsza tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _drugaSieSkonczyla
	
	_pierwszaSieSkonczyla:
	popf

	mov $0,%eax
	adc liczba2(,%esi,4),%eax
	mov %eax, wynik(,%edx,4)	# push %eax
	inc %esi
	inc %edx
	pushf
	
	cmp $liczba2_len_word, %esi #jezeli druga tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _pierwszaSieSkonczyla
	
	_dodawanie:
	popf
	_dodawaniePierwszyRaz:

	mov liczba1(,%edi,4),%eax
	adc liczba2(,%esi,4) ,%eax      
	mov %eax, wynik(,%edx,4)  # push %eax	

	inc %edx
	inc %edi
	inc %esi
	pushf

	cmp $liczba2_len_word, %esi					
	jz _drugaSieSkonczylaAleSprawdzCzyPierwszaTez
	cmp $liczba1_len_word, %edi
	jz _pierwszaSieSkonczylaAleSprawdzCzyDrugaTez  

	jmp _dodawanie

	_dodajOstatniePrzeniesienie:
	mov $1, %eax  		# push $1
	mov %eax, wynik(,%edx,4)
	# juz nie trzeba inkrementowac edx
	
	jmp _wypiszStackPrep

	_sprawdzOstatniePrzeniesienie:
	popf
	jc _dodajOstatniePrzeniesienie
	jmp _wypiszStackPrep

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
	.lcomm liczba1, liczba1_len
	.lcomm liczba2, liczba2_len
	.lcomm ASCIIstring, ASCIIstring_len
	.lcomm wynik, 256


