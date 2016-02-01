; C Run Time Library

bits 32

section .text

    extern _sys.exit
    extern main

    ; allocate both "start" and "_start" identifiers
    global _start
    global start
    _start:
    start:

        ; prolog
        nop ; somehow being nice to the debugger
        ; save initial stack pointer to EBP...
        ; ... and align stack with paragraph
        mov ebp, esp 
        and esp, -16 

        ; prepare to call main
        ; make room for 4 DWORD parameters although only 3 are used...
        ; ... this keeps the paragraph alignment
        sub esp, 16 
        ; get and set "argc"
        mov ecx, dword [ ebp ]
        mov [ esp ], ecx
        ; calc effective address of "argv"
        lea eax, [ ebp + 4 ]
        mov [ esp + 4 ], eax
        ; calc effective address of "envp"
        lea eax, [ ebp + ecx * 4 + 8 ] 
        mov [ esp + 8 ], eax
        ; set last argument as a NULL pointer
        xor eax, eax
        mov eax, dword [ esp + 12 ]
        call main
        add esp, 16

        ; exit code
        push eax
        call _sys.exit

        ; execution will never make it to this point...
        ; ... hopefully!
        nop
