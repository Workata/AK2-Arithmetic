	SYSEXIT =1  
	EXIT_SUCCESS=0
	SYSWRITE=4
	STDOUT=1
	SYSREAD=3
	STDIN=0
	SYSCALL = 0x80
	
	.global _start

	.data
	
	enter: .ascii "\n"
	enter_len =.-enter
	
	_start:
	




	_exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS,%ebx
	int $0x80


