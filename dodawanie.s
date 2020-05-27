	.code32
	SYSEXIT = 1
	EXIT_SUCCESS = 0
	SYSWRITE = 4
	STDOUT = 1
	SYSREAD = 3
	STDIN = 0

	.global _start

	.data

	liczba1:
		.long 0x10304009, 0x701100F1, 0x45100020 , 0x08570030

	liczba1_len=( .-liczba1)/4  #

	liczba1_len_bytes = .-liczba1
	
	liczba2:
		.long 0x10405003, 0x00220026, 0x321000C3 , 0x04520031
	
	liczba2_len=(.-liczba2)/4
	
	cyfra: .long 0x00	
	cyfry_len=.-cyfra
	
	enter: .ascii "\n"
	enter_len = .-enter

	_start:
	mov $0, %edx
	mov $liczba1_len, %edi
	mov $liczba2_len, %esi	

	clc	
	jmp _dodawaniePierwszyRaz

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
	
	_wypiszStack:	#Funkcja wypisujaca wynik ze stosu
	clc

	mov $0, %edi	
	pop %eax
	push %edx	
	

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

	
#--------------KONIEC--WYPISYWANIA---LICZB--------------------

	_drugaSieSkonczylaAleSprawdzCzyPierwszaTez:
	cmp $0, %edi	#jezeli pierwsza tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _drugaSieSkonczyla
	
	_pierwszaSieSkonczylaAleSprawdzCzyDrugaTez:
	cmp $0, %esi	#jezeli druga tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _pierwszaSieSkonczyla


	_drugaSieSkonczyla:
	popf

	dec %edi
	mov $0,%eax
	adc liczba1(,%edi,4),%eax
	push %eax
	pushf
	
	cmp $0, %edi	#jezeli pierwsza tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _drugaSieSkonczyla
	
	_pierwszaSieSkonczyla:
	popf

	dec %esi
	mov $0,%eax
	adc liczba2(,%esi,4),%eax
	push %eax
	pushf
	
	cmp $0, %esi		#jezeli druga tez sie skonczyla to wyjdz
	jz _sprawdzOstatniePrzeniesienie
	jmp _pierwszaSieSkonczyla
	
	_dodawanie:
	popf
	_dodawaniePierwszyRaz:
	dec %edi
	dec %esi

	mov liczba1(,%edi,4),%eax
	adc liczba2(,%esi,4) ,%eax      
	push %eax
	inc %edx	#tu mam zapisane jak duzo jest slow na stosie	
	pushf

	cmp $0,%esi					
	jz _drugaSieSkonczylaAleSprawdzCzyPierwszaTez
	cmp $0, %edi
	jz _pierwszaSieSkonczylaAleSprawdzCzyDrugaTez  

	jmp _dodawanie

	_dodajOstatniePrzeniesienie:
	push $1
	inc %edx
	jmp _wypiszStack

	_sprawdzOstatniePrzeniesienie:
	popf
	jc _dodajOstatniePrzeniesienie
	jmp _wypiszStack

	_exit:

	mov $SYSWRITE, %eax
	mov $STDOUT, %ebx
	mov $enter, %ecx
	mov $enter_len, %edx
	int $0x80



	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
