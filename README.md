# 8086-Number-Converter
A console-based application developed in 8086 Assembly Language that takes a 2-digit decimal number (00–99) as input and converts it into three different number systems through an interactive menu.
The user enters a number, selects a conversion type, and instantly sees the result. The program uses DOS INT 21h interrupts for input/output and demonstrates core low-level programming concepts including registers, arithmetic, bit manipulation, loops, and modular subroutines.

## Conversion Modes:

1 → Binary (8-bit representation)
2 → Hexadecimal
3 → Octal (3-digit)
0 → Exit

## Key Features:

Interactive menu with input validation
Reusable print_nibble subroutine for Hex conversion
Bit manipulation using ROL instruction for Binary
DIV instruction for Octal decomposition
Option to convert another number or exit
Written in pure 8086 Assembly using DOS interrupts
