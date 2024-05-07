EXIT_SUCCESS = 0
SYSEXIT = 1


.section .data

liczba1:
	.ascii "00467d"
koniec_liczby1 = . - liczba1

liczba2:
	.ascii "e5778a"
koniec_liczby2 = . - liczba2

.section .bss

wynik:
	.skip 7

.section .text
.global _start

_start:
# Normalizacja wartości obu liczb i zapisanie ich do pamięci
	mov $liczba1, %eax
	mov $koniec_liczby1, %ebx
	mov $0, %ecx
check_letters:
	cmpb $'9', (%ecx,%eax,1)
	jg check_small_letters
	subb $48, (%ecx,%eax,1)
	jmp skip
check_small_letters:
	cmpb $'F', (%ecx,%eax,1)
	jg small_letters
	subb $55, (%ecx,%eax,1)
	jmp skip
small_letters:
	subb $87, (%ecx,%eax,1)
skip:
	inc %ecx
	cmp $koniec_liczby1, %ecx
	jl check_letters


	mov $liczba2, %eax
	mov $koniec_liczby2, %ebx
	mov $0, %ecx
check_letters2:
	cmpb $'9', (%ecx,%eax,1)
	jg check_small_letters2
	subb $48, (%ecx,%eax,1)
	jmp skip2
check_small_letters2:
	cmpb $'F', (%ecx,%eax,1)
	jg small_letters2
	subb $55, (%ecx,%eax,1)
	jmp skip2
small_letters2:
	subb $87, (%ecx,%eax,1)
skip2:
	inc %ecx
	cmp $koniec_liczby2, %ecx 
	jl check_letters2

# Dodanie wartości komórek pamięci do siebie, od najmłodszego bitu
	mov $6, %ecx
dodawanie_z_przeniesieniem:
	mov $liczba1, %eax
	mov $liczba2, %edx
	mov $wynik, %ebx
	dec %ecx
	cmp $0, %ecx
	jl end

	mov (%ecx,%eax,1), %al
	mov (%ecx,%edx,1), %ah
	mov (%ecx,%ebx,1), %dl
	add %al,%dl
	add %ah,%dl
	inc %ecx
	addb (%ecx,%ebx,1), %dl
	cmp $16, %dl
	jge przeniesienie
	jmp dalej2

przeniesienie:
	sub $16, %dl
	mov %dl, wynik(%ecx)
	dec %ecx
	addb $1, wynik(%ecx)
	jmp dodawanie_z_przeniesieniem

dalej2:
	mov %dl, wynik(%ecx)
	dec %ecx
	jmp dodawanie_z_przeniesieniem	

end:	

exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
