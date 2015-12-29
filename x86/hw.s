; nasm program...

bits 32

section .data
    msg: db "Hello, World...", 0x0A, 0x0A, 0x00

section .text

    global start
    start:
        nop
        push ebp
        mov ebp, esp

        ; call "_print"
        push dword msg
        call _print
        add esp, 4

        ; call "_exit"
        push dword 0
        call _sys.exit
        ; execution will very very probably never get to this point...
        add esp, 4

        mov esp, ebp
        pop ebp
        ret


    _sys:
        .exit:
        mov eax, 1 ; service number for "exit"
        jmp .trap
        .write:
        mov eax, 4 ; service number for "write"
        .trap:
        int 0x80 ; trap into kernel space...
        ret


    _strlen:
        ; prolog
        push ebp
        mov ebp, esp
        push edi ; save EDI since it will be used by SCAS instruction
        mov edx, [ ebp + 8 ] ; save first parameter to EDX
        ; prepare for SCASB instruction
        mov edi, edx
        mov al, 0
        cld
        repne scasb
        sub edi, edx
        mov eax, edi ; set return value
        ; epilog
        pop edi
        mov esp, ebp
        pop ebp
        ret


    _print:
        ; prolog
        push ebp
        mov ebp, esp
        sub esp, 4 ; make room for last parameter of "_kern" call
        push dword [ ebp + 8 ]
        call _strlen
        mov [ esp + 4 ], eax ; replace last parameter [EBP-4] with returned value
        push dword 1 ; file descriptor for "stdout"
        call _sys.write
        ; epilog
        mov esp, ebp
        pop ebp
        ret

