	SYSEXIT = 1
	EXIT_SUCCESS = 0
	SYSWRITE = 4
	STDOUT = 1
	SYSREAD = 3
	STDIN = 0

	.global _start	#o

	.data

	liczba1:
		.long 0x103040FF#, 0x701100FF#, 0x45100020 , 0x08570030

	liczba1_len= (.-liczba1)/4
	
	liczba2:
		.long 0xF04050FF#, 0x00220026#, 0x321000CB , 0x04520031
	
	liczba2_len= (.-liczba2)/4
	
	operand:
	.long 0x00

	part:
		.long 0x00000000

	part2:
		.long 0x00000000 #FF
	
	wynikPointer= 254 # wynik ma 256 B ale od zeraz indeksujemy	


	_start:
	
	mov $liczba1_len, %edi
	mov $liczba2_len, %esi	
	mov $0, %edx
	mov $0, %ebx
	dec %esi
	mov liczba2(,%esi,4), %eax
	mov %eax, part2(,%ebx,4)
	mov $wynikPointer, %ecx
	push %ecx

	clc
	#pushf	
	jmp _mnozenie

	_resetNumber1:
	mov $0, %ebx
	mov $liczba1_len, %edi
	dec %edi
	mov liczba1(,%edi,4), %eax
	mov %eax, part(,%ebx,4)
	ret

	_incEdxIKontynnujMnozenie:
	call _resetNumber1
	inc %edx
	cmp $4, %edx
	je _nextWordInPart2
	jmp _mnozenieUp
	
	_mnozenie:
	mov $0, %ebx
	cmp $0, %edi
	je _incEdxIKontynnujMnozenie
	dec %edi
	mov liczba1(,%edi,4), %eax
	mov %eax, part(,%ebx,4)
	
	jmp _mnozenieUp
	
	
	_nextWordInPart2:	
	cmp $0, %esi		#zakonczenie generowania ilocz. czesc.
	je _exit
	dec %esi
	mov liczba2(,%esi,4), %eax
	mov %eax, part2(,%ebx,4)
	mov $0, %edx

	_mnozenieUp:
	mov part2(,%edx,1), %al
	mov part(,%ebx,1), %cl
	mul %cl		#wynik w ax
	#push %eax

	pop %ecx
	push %ebx

	#------------------dodawanie iloczynow czesciowych------------
	#mov wynik(,%ecx,2), %bx
	#add %al, %bh
	#mov %bx, wynik(,%ecx,2)
	#dec %ecx
	#mov wynik(,%ecx,2), %bx
	#mov %ah, %bl
	#add %bl,wynik(,%ecx,2) # %bl
	#mov %bx, wynik(,%ecx,2)
	#dec %ecx
	#addb %al, wynik(,%ecx,1)
	#inc %ecx  #inc ???
	#add %ah, wynik(,%ecx,1)
	
	

	pop %ebx  #restore ebx
	push %ecx #store ecx

	inc %ebx
	
	cmp $4,%ebx
	je _mnozenie
	jmp _mnozenieUp

	_exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80


	.bss
	.lcomm wynik, 256
	
	
