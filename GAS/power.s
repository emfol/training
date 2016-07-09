/*
 * @file power.s
 * @description calculate the power of a number
 * @author Emanuel F. Oliveira
 */

    .section .data

_usage:
    .string "Usage:\n    %s <base> <exponent>\n\n"
_format:
    .string "Result:\n    %d ^ %d = %d\n\n"


    .section .text
    .globl _main

_main:
    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp # -4(%ebp): base, -8(%ebp): power, -12(%ebp): result
    movl $0, -12(%ebp)

    cmpl $3, 4(%ebp)
    jl _main_print_usage

    # payload
    # convert base
    pushl 12(%ebp)
    calll atoi
    addl $4, %esp
    movl %eax, -4(%ebp)
    # convert power
    pushl 16(%ebp)
    calll atoi
    addl $4, %esp
    movl %eax, -8(%ebp)
    # call power function
    pushl -8(%ebp)
    pushl -4(%ebp)
    calll _power
    addl $8, %esp
    movl %eax, -12(%ebp)
    # print result
    pushl -12(%ebp)
    pushl -8(%ebp)
    pushl -4(%ebp)
    pushl $_format
    calll printf
    addl $16, %esp
    # exit with success
    movl $0, %ebx
    jmp _main_exit

  _main_print_usage:
    pushl 8(%ebp)
    pushl $_usage
    calll printf
    addl $8, %esp
    movl $1, %ebx

  _main_exit:
    andl $0xF, %ebx
    movl $1, %eax
    int $0x80

.type _power, @function
_power:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl 12(%ebp), %ecx
    cmpl $0, %ecx
    jge _power_loop_init

    movl $-1, %edx
    movl %edx, %eax
    jmp _power_exit

  _power_loop_init:
    movl $0, %edx
    movl $1, %eax
    movl 8(%ebp), %ebx

  _power_loop:
    cmpl $0, %ecx
    je _power_exit
    decl %ecx
    imull %ebx
    jmp _power_loop

  _power_exit:
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

