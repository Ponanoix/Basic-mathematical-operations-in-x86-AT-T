EXIT_SUCCESS = 0
SYSEXIT = 1


.section .data

liczba1:
	.ascii "1635fa"
koniec_liczby1 = . - liczba1
koniec_liczby1_bin:
	.skip 24

liczba2:
	.ascii "fb3346"
koniec_liczby2 = . - liczba2
koniec_liczby2_bin:
	.skip 24

.section .bss

wynik:
	.skip 12
wynik_bin:
	.skip 48

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

# Konwersja zapisu liczb z HEX na BIN
	mov $liczba1, %eax
	mov $koniec_liczby1_bin, %ebx
	mov $5, %esp
	mov $23, %edx
konwersja_liczby1_start:
	cmp $0, %esp
	jl konwersja_liczby2_prolog
	mov $liczba1, %eax
	mov $koniec_liczby1_bin, %ebx
	movb (%esp,%eax,1), %al
	mov $1, %cl
	
	movb %al, %ah
	andb $0x01, %ah
	movb %ah, (%edx,%ebx,1)
	dec %edx
konwersja_liczby1:
	mov %al, %ah
	shr %cl, %ah
	andb $0x01, %ah
	movb %ah, (%edx,%ebx,1)
	dec %edx
	inc %cl
	cmp $3, %cl
	jle konwersja_liczby1
	dec %esp
	jmp konwersja_liczby1_start
konwersja_liczby2_prolog:
	mov $liczba2, %eax
	mov $koniec_liczby2_bin, %ebx
	mov $5, %esp
	mov $23, %edx
konwersja_liczby2_start:
	cmp $0, %esp
	jl sumowanie_start
	mov $liczba2, %eax
	mov $koniec_liczby2_bin, %ebx
	movb (%esp,%eax,1), %al
	mov $1, %cl

	movb %al, %ah
	andb $0x01, %ah
	movb %ah, (%edx,%ebx,1)
	dec %edx
konwersja_liczby2:
	mov %al, %ah
	shr %cl, %ah
	andb $0x01, %ah
	movb %ah, (%edx,%ebx,1)
	dec %edx
	inc %cl
	cmp $3, %cl
	jle konwersja_liczby2
	dec %esp
	jmp konwersja_liczby2_start

# Dodanie do mnożnej mnożnika odpowiednią liczbę razy, na odpowiednich pozycjach
sumowanie_start:
	mov $koniec_liczby1_bin, %eax
	mov $koniec_liczby2_bin, %ebx
	mov $23, %ecx
	mov $wynik_bin, %esp
	mov %ecx, %ebp
	add $24, %ebp
porownanie:
	mov $23, %edx
	jmp porownanie_dalej
odnowa:
	dec %ecx
	mov $23, %edx
	mov %ecx, %ebp
	add $24, %ebp
porownanie_dalej:
	cmpb $1, (%ecx,%eax,1)
	je sumowanie
	dec %ecx
	dec %ebp
	cmp $0, %ecx
	jl naprawa_wyniku
	jmp porownanie_dalej
sumowanie:
	mov (%edx,%ebx,1), %dil
	addb %dil, wynik_bin(%ebp)
proces_sumowania:
	dec %edx
	dec %ebp
	cmp $0, %edx
	jl odnowa
	jmp sumowanie

# Naprawa wyniku, żeby był zapisany w formie binarnej (komórki pamięci są 8 bitowe, my chcecmy mieć binarny wynik)
naprawa_wyniku:
	mov $47, %ebp
	jmp proces_naprawy
dekrementacja_naprawy:
	dec %ebp
	cmp $0, %ebp
	jl konwersja_na_szesnastkowy
proces_naprawy:	
	cmpb $1, wynik_bin(%ebp)
	jle dekrementacja_naprawy
	subb $2, wynik_bin(%ebp)
	dec %ebp
	addb $1, wynik_bin(%ebp)
	inc %ebp
	jmp proces_naprawy

# Konwersja wyniku z binarnego na szesnastkowy
konwersja_na_szesnastkowy:
	mov $0, %ch
	mov $47, %ebp
	mov $11, %edx
	mov $4, %bh
proces_konwersji:
	orb wynik_bin(%ebp), %ch
	ror $1, %ch
	dec %ebp
	dec %bh
	cmp $0, %bh
	je wpisanie_do_wyniku
	jmp proces_konwersji
wpisanie_do_wyniku:
	ror $4, %ch
	movb %ch, wynik(%edx)
	dec %edx
	cmp $0, %edx
	jl exit
	mov $4, %bh
	mov $0, %ch
	jmp proces_konwersji	
exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80
