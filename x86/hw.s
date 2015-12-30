; nasm program...

bits 32

section .data
    _msg: db "Hello, World...", 0x0A, 0x0A, 0x00
    _arg: db "Arguments:", 0x0A, 0x00
    _sep: db 0x0A, "  > ", 0x00

section .text

    extern utils_strlen
    global start
    start:

        ; prolog
        nop ; help debugger
        mov ebp, esp ; store initial stack pointer to EBP
        and esp, -16 ; align stack with paragraph

        ; prepare to call _main
        sub esp, 12 ; make room for three dword parameters
        mov ecx, [ ebp ] ; store argument count in ECX
        mov [ esp ], ecx ; set argc
        lea eax, [ ebp + 4 ] ; calc effective address of argv
        mov [ esp + 4 ], eax ; set argv
        lea eax, [ ebp + ecx * 4 + 8 ] ; calc effective address of envp
        mov [ esp + 8 ], eax
        call _main
        add esp, 12

        ; exit
        push eax
        call _sys.exit ; execution will never get after this point...
        nop ; hopefully...


    _main:

        ; prolog
        push ebp
        mov ebp, esp
        sub esp, 4 ; int i

        ; check if any argument is given
        mov eax, [ ebp + 8 ]
        cmp eax, 1
        jle .default

        ; print loop
        sub esp, 4 ; make room for "_print" argument
        mov eax, _arg
        mov [ esp ], eax
        call _print ; leave ESP as is
        xor eax, eax
        mov [ ebp - 4 ], eax ; ... i = 0
        jmp .lpt0
        .lp0:
        mov eax, _sep
        mov [ esp ], eax
        call _print
        mov ecx, [ ebp - 4 ]
        mov eax, [ ebp + 12 ]
        mov eax, [ eax + ecx * 4 ]
        mov [ esp ], eax
        call _print
        .lpt0:
        lea eax, [ ebp - 4 ] ; &i
        mov ecx, [ eax ]
        inc ecx
        mov [ eax ], ecx ; ... ++i
        mov eax, [ ebp + 8 ] ; load argc
        cmp eax, ecx
        jg .lp0
        add esp, 4 ; get rid of "_print" argument
        mov eax, 66 ; set status code
        jmp .leave

        .default:
        push dword _msg
        call _print
        add esp, 4
        mov eax, 65 ; set status code

        .leave:
        ; epilog
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


    _print:
        ; prolog
        push ebp
        mov ebp, esp
        push dword [ ebp + 8 ]
        call utils_strlen
        add esp, 4
        push eax
        push dword [ ebp + 8 ]
        push dword 1
        call _sys.write
        add esp, 12
        ; epilog
        mov esp, ebp
        pop ebp
        ret

