EXIT_SUCCESS = 0
SYSEXIT = 1


.section .data

liczba1:
	.ascii "046fde"
koniec_liczby1 = . - liczba1

liczba2:
	.ascii "f14256"
koniec_liczby2 = . - liczba2

.section .bss

wynik:
	.skip 7
koniec_wyniku = . - wynik

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

# Odejmowanie wartości w poszczególnych komórkach pamięci
	mov $liczba1, %eax
	mov $koniec_liczby1, %ebx
	dec %ebx
	mov $liczba2, %ecx
	mov $wynik, %esp
	mov $0, %dh
	sub $5, %ebx
czy_odjemna_wieksza:
	cmp $6, %ebx
	je odjemna_wieksza_rowna
	mov liczba1(%ebx), %dl
	cmpb %dl, liczba2(%ebx)
	jg odjemna_mniejsza
	jl odjemna_wieksza_rowna
	inc %ebx
	jmp czy_odjemna_wieksza
odjemna_wieksza_rowna:
	mov $1, %dh
odjemna_mniejsza:
	mov $5, %ebx
	mov $6, %ebp	
	mov $0, %dl
odejmowanie:
	mov liczba1(%ebx), %dil
	mov liczba2(%ebx), %sil
	cmp %sil, %dil
	jl pozyczka
powrot:
	mov %dil, wynik(%ebp)
	sub %sil, wynik(%ebp)
	dec %ebp
	dec %ebx
	cmp $0, %ebx
	jl dopelnienie_wyniku
	jmp odejmowanie
koniec_dzielnej:
	dec %dl
	addb $0xf, liczba1(%ebx)
	inc %ebx
	cmp $0, %dl
	jg koniec_dzielnej
	je kontynuacja
pozyczka_zero:
	inc %dl
	cmp $0, %ebx
	je koniec_dzielnej
pozyczka:
	dec %ebx
	cmp $0, %ebx
	jl koniec_pamieci
	jmp nie_koniec_pamieci
koniec_pamieci:
	inc %ebx
	jmp kontynuacja
nie_koniec_pamieci:
	cmpb $0, liczba1(%ebx)
	je pozyczka_zero
	subb $1, liczba1(%ebx)
	cmp $0, %dl
	jg koniec_dzielnej
	inc %ebx
kontynuacja:
	addb $0x10, liczba1(%ebx)
	mov liczba1(%ebx), %dil
	jmp powrot	
dopelnienie_wyniku:
	mov $0, %ebx
	mov $0, %ebp
	cmp $1, %dh
	je exit
	inc %ebp
	cmpb $0, wynik(%ebp)
	je jesli_2_bit_zero
	jmp proces_dopelnienia2
jesli_2_bit_zero:
	dec %ebp
	cmpb $0, liczba2(%ebx)
	jne zero_nie_przez_zera
	jmp proces_dopelnienia2
zero_nie_przez_zera:
	movb $0xf, wynik(%ebp)
	jmp exit
proces_dopelnienia:
	inc %ebp
proces_dopelnienia2:
	cmpb $0, wynik(%ebp)
	je proces_dopelnienia
	cmpb $8, wynik(%ebp)
	jge dopelnianie
dopelnianie:
	cmp $0, %ebp
	je exit
	dec %ebp
	movb $0xf, wynik(%ebp)
	jmp dopelnianie
		
exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
