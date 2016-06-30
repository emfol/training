/*
 * @file exit.s
 * @description This program sets the a return code and exits...
 */

.section .data

# empty data section...

.section .text

.globl _start

_start:
    movl $2, %ebx
    movl $1, %eax
    int $0x80

