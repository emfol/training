/*
 * @file max.s
 * @description Finds the greatest number in a list.
 * @author Emanuel F. Oliveira
 */

    .section .data

_array:
    .long 1, 48, 78, 160, 25, 47, 15, 2, 36, 78, 77, 224, 0


    .section .text

    .globl _start

_exit:
    movl $1, %eax
    int $0x80

_start:

    movl $_array, %esi
    movl (%esi), %ebx
    movl $0, %ecx

  _loop:
    movl (%esi, %ecx, 4), %eax
    cmpl $0, %eax
    je _exit
    incl %ecx
    cmpl %eax, %ebx
    jge _loop
    movl %eax, %ebx
    jmp _loop




