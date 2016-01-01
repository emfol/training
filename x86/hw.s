; nasm program...

bits 32

section .data
    _msg: db "Hello, World...", 0x0A, 0x0A, 0x00
    _arg: db "Arguments:", 0x0A, 0x0A, 0x00
    _fmt: db '  > "%s" + [%s] + (%s) = 100%% :-)', 0x0A, 0x00

section .text

    extern utils_strlen
    extern utils_sprintf
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

        ; check if any argument is given
        mov eax, [ ebp + 8 ]
        cmp eax, 1
        jle .default

        ; [ EBP - 4 ] = $i
        ; [ EBP - 8 ] = $buf
        sub esp, 1028 ; alloc space for locals
        ; print header message
        push dword _arg
        call _print
        add esp, 4
        ; print loop
        ; init $i
        mov dword [ ebp - 4 ], 1
        jmp .test
    .loop:
        mov eax, [ ebp + 12 ] ; load argv
        mov eax, [ eax + ecx * 4 ] ; argv + i
        lea edx, [ ebp - 1028 ]
        push eax
        push eax
        push eax
        push _fmt
        push edx
        call utils_sprintf
        add esp, 20
        lea eax, [ ebp - 1028 ]
        push eax
        call _print
        add esp, 4
    .test:
        mov ecx, [ ebp - 4 ]
        inc dword [ ebp - 4 ]
        cmp [ ebp + 8 ], ecx
        jg .loop

        add esp, 1028
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

