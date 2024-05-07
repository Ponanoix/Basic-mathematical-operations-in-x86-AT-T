EXIT_SUCCESS = 0
SYSEXIT = 1


.section .data

liczba1:
	.ascii "ffffff"
koniec_liczby1 = . - liczba1

liczba2:
	.ascii "eeeeee"
koniec_liczby2 = . - liczba2

.section .bss

wynik:
	.skip 6
koniec_wyniku = . - wynik

reszta:
	.skip 6
koniec_reszty = . - reszta

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

# Najpierw obliczenie wartości dzielnika i wpisanie jej do rejestru
# eax - Adres najstarszego bitu liczby
	mov $liczba2, %eax
# ecx - Rejestr do przechowywania wartości dzielnika
	mov $0, %ecx
# edx - Rejestr do przechowywania danych odnośnie bitu, który jest aktualnie liczony
	mov $0, %edx
# edi - Rejestr do porównywania z edx
	mov $5, %edi
# esi - Rejestr do przechowywania aktualnie obliczonej wartości
	mov $0, %esi
obliczanie_wartosci_dzielnika:
	cmp $0, %edi
	jl poczatek_dzielenia
	mov %edi, %edx
	mov $0, %esi
czy_bit_zero:
	cmp $5, %edi
	je tak_bit_zero
	movzx liczba2(%edi), %esi
	jmp nie_bit_zero
tak_bit_zero:
	add liczba2(%edi), %ecx
	dec %edi
	jmp obliczanie_wartosci_dzielnika
nie_bit_zero:
	cmp $5, %edx
	je koniec_danego_bitu
	imul $16, %esi
	inc %edx
	jmp nie_bit_zero
koniec_danego_bitu:
	add %esi, %ecx
	dec %edi
	jmp obliczanie_wartosci_dzielnika
# Rejestry, które są aktualnie wykorzystywane i nie można ich teraz nadpisać:
# ecx - Przechowuje wartość dzielnika
poczatek_dzielenia:
# Rejestry, które wykorzystane będą teraz:
# eax - Adres najstarszego bitu dzielnej
	mov $liczba1, %eax
# ebx - Adres najstarszego bitu wyniku
	mov $wynik, %ebx
# esp - Rejestr informujący, który bit jest aktualnie w użyciu
	mov $0, %esp
# ebp - Rejestr pomocniczy
	mov $0, %ebp
# edx - Rejestr przechowujący aktualnie obliczoną wartość
	mov $0, %edx
# edi - Adres najstarszego bitu reszty
	mov $0, %edi
# esi - Rejetr przechowujący liczbę powtórzeń dzielnika podczas odejmowania
	mov $0, %esi
najstarszy_bit:
	movzx liczba1(%esp), %edx
powrot_do_porownania:
	cmp %edx, %ecx
	jle dzielnik_mniejszy
	jg koniec_przywracania_dzielnika
dzielnik_mniejszy:
	inc %esi
	sub %ecx, %edx
	cmp $0, %edx
	jge dzielnik_mniejszy
dopisanie_cyfry_do_wyniku:
	mov %esi, %ebp
	dec %esi
	mov %esi, wynik(%esp)
przywrocenie_dzielnej:
	cmp $0, %ebp
	je przemnozenie_dzielnika
	add %ecx, %edx
	dec %ebp
	jmp przywrocenie_dzielnej
przemnozenie_dzielnika:
	mov %ecx, %ebp
	imul %esi, %ecx
	sub %ecx, %edx
przywrocenie_dzielnika:
	mov %ebp, %ecx
	mov $0, %ebp
koniec_przywracania_dzielnika:
	cmp $5, %esp
	je obliczanie_reszty
	inc %esp
	imul $16, %edx
	movzx liczba1(%esp), %ebp
	add %ebp, %edx
	mov $0, %esi
	jmp powrot_do_porownania
obliczanie_reszty:
	mov %edx, %edi
exit:
	mov $SYSEXIT, %eax
	mov $EXIT_SUCCESS, %ebx
	int $0x80






















