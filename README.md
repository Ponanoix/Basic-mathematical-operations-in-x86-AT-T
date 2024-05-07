# Basic-mathematical-operations-in-x86-AT-T
Four programs used to calculate results of basic mathematical operations (written in x86 AT&T syntax, using 32-bit architecture on a 64-bit device)

The following programs consist of:
- dodawanie (addition)
- odejmowanie (subtraction)
- mnozenie (multiplication)
- dzielenie (division)

NOTES:
- the numbers used in the programs are hardcoded at the beginning of each program using .ascii label
- the numbers should be 6 charaters long. Larger number are not supported. If one wants to use a smaller number, simply put enough zeroes before the first, significant digit.
- the programs interpret numbers as written in a natural hexadecimal code, not complementary, meaning negative numbers are not supported for the two initial numbers (results can be negative on one condition, check the next note)
- when it comes to subtraction, the result can be a negative number and that's why it is always written using hexadecimal complementary code, even if the difference is a positive number. If you don't know how complementary code works in computers, I advise learning about it before using the subtraction program. In short, if the oldest bit is represented by one of the characters from the latter half (8 - F), the number is negative and when converting it to decimal, one should multiply the oldest bit by (-1) and then proceed as usual.
- the division program does not support IEEE-754 standard for fractions. Instead, it uses the standard quotient and remainder approach.
