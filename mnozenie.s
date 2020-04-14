	SYSEXIT = 1
	EXIT_SUCCESS = 0
	SYSWRITE = 4
	STDOUT = 1
	SYSREAD = 3
	STDIN = 0

	.global _start	#o

	.data

	liczba1:
		.long 0x10304008, 0x701100FF#, 0x45100020 , 0x08570030

	liczba1_len= (.-liczba1)/4
	
	liczba2:
		.long 0xF040500C#, 0x00220026, 0x321000CB , 0x04520031
	
	liczba2_len= (.-liczba2)/4

	wynikMnozenia:  .long 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

	wynikMnozenia_len =(.-wynikMnozenia)/4
	
	operand:
	.long 0x00

	part:
		.long 0x00000000

	part2:
		.long 0x00000000
	

	_start:
	
	mov $liczba1_len, %edi
	mov $liczba2_len, %esi	
	mov $0, %edx
	dec %esi
	mov liczba2(,%esi,1), %eax
	mov %eax, part2(,%ebx,4)

	clc
	#pushf	
	jmp _mnozenie

	_incEdxIKontynnujMnozenie:
	inc %edx
	mov $liczba1_len, %edi
	dec %edi
	mov liczba1(,%edi,4), %eax
	mov %eax, part(,%ebx,4)
	jmp _mnozenieUp
	
	_mnozenie:
	mov $0, %ebx
	cmp $0, %edi
	je _incEdxIKontynnujMnozenie
	dec %edi
	mov liczba1(,%edi,4), %eax
	mov %eax, part(,%ebx,4)
	
	jmp _mnozenieUp
	
	
	_mnozenieWew:	#flagi, przeniesienie
	dec %esi
	mov liczba2(,%esi,1), %eax
	mov %eax, part2(,%ebx,4)
	_mnozenieUp:
	mov part2(,%edx,1), %al
	mov part(,%ebx,1), %cl
	mul %cl		#wynik w ax
	push %eax  #add %ax,wynikMnozenia(,,2)
	inc %ebx
	
	cmp $4,%ebx
	je _mnozenie
	jmp _mnozenieUp

	_exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
