/**
 * @author Emanuel F. Oliveira
 * @date 2016-06-12
 * @description "This program prints a default message if no argument is passed..."
 * @motivation "Training AT&T Assembly Syntax"
 */

    .section .text

    .globl start
    .globl _start

exit:
    movl $1, %eax
    int $0x80
    ret

write:
    movl $4, %eax
    int $0x80
    ret

strlen:
    movl 4(%esp), %eax
    movl %eax, %ecx
  strlen_loop:
    cmpb $0, (%eax)
    je strlen_exit
    incl %eax
    jmp strlen_loop
  strlen_exit:
    subl %ecx, %eax
    ret

start:
_start:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    /* check argc... */
    cmpl $2, 4(%ebp)
    jl start_stdMsg
    movl $1, %ecx
    movl 8(%ebp, %ecx, 4), %eax /* load EAX with argv[1] */
    jmp start_stdFlw

  start_stdMsg:
    movl $msg, %eax

  start_stdFlw:
    movl %eax, -4(%ebp)

    /* how long is the string? */
    pushl %eax
    calll strlen
    addl $4, %esp
    /* now lets print it... */
    pushl %eax
    pushl -4(%ebp)
    pushl $1
    calll write
    addl $12, %esp

    /* clean exit... */
    pushl $0
    calll exit

    /* playing safe... */
    leave
    ret


    .section .data

msg:
    .asciz "Nothing more than my default message...\n"

