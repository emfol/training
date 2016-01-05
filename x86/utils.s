; utils.s
; NASM assembly syntax

bits 32


section .text


global utils_strlen
global _utils_strlen
global utils_strcpy
global _utils_strcpy
global utils_sprintf
global _utils_sprintf


utils_strlen:
_utils_strlen:
    ; # PROLOG
    push ebp
    mov ebp, esp
    ; # PAYLOAD
    mov edx, dword [ ebp + 8 ]
    mov eax, edx
.loop:
    cmp byte [ eax ], 0
    je .done
    inc eax
    jmp .loop
.done:
    sub eax, edx ; adjust EAX
    ; # EPILOG
    pop ebp
    ret


utils_strcpy:
_utils_strcpy:
    ; # PROLOG
    push ebp
    mov ebp, esp
    ; # PAYLOAD
    mov ecx, dword [ ebp +  8 ] ; source
    mov edx, dword [ ebp + 12 ] ; destination
.loop:
    mov al, byte [ ecx ]
    mov byte [ edx ], al
    cmp al, byte 0
    je .done
    inc ecx
    inc edx
    jmp .loop
.done:
    mov eax, edx
    sub eax, dword [ ebp + 12 ] ; adjust EAX
    ; # EPILOG
    pop ebp
    ret


utils_itoa:
_utils_itoa:

    ; # ARGUMENTS
    ; [ EBP + 16 ] = numerical base
    ; [ EBP + 12 ] = buffer address
    ; [ EBP +  8 ] = signed integer to be encoded
    ; # LOCALS:
    ; [ EBP -  4 ] = $N
    ; [ EBP -  8 ] = $BUF (next byte pointer)

    ; # PROLOG
    push ebp
    mov ebp, esp


    ; # PAYLOAD
    ; [ EBP - 4 ] <- [ EBP +  8 ]
    push dword [ ebp +  8 ]
    ; [ EBP - 8 ] <- [ EBP + 12 ]
    push dword [ ebp + 12 ]

    ; load base to ECX
    mov ecx, dword [ ebp + 16 ]
    cmp ecx, byte 16
    je .base16
    cmp ecx, byte 2
    jl .done
    cmp ecx, byte 36
    jg .done

    ; # SUBROUTINES
.append:
    cmp dl, byte 0x0A
    jge .append.alpha
    add dl, byte 0x30 ; add '0'
    jmp .append.write
.append.alpha:
    sub dl, byte 0x0A
    add dl, byte 0x61
.append.write:
    mov eax, [ ebp - 8 ]
    mov byte [ eax ], dl
    inc eax
    mov dword [ ebp - 8 ], eax
    ret

.loop:
    mov eax, dword [ ebp - 4 ]
    cdq
    idiv ecx
    mov dword [ ebp - 4 ], eax
    call .append
    jmp .loop

.base16:
.abort:
    xor eax, eax
.done:
    ; terminate string
    mov eax, dword [ ebp - 8 ]
    mov byte [ eax ], 0
    sub eax, dword [ ebp + 12 ]

    ; # EPILOG
    ; no need for "add esp, byte 8"
    mov esp, ebp
    pop ebp
    ret


utils_sprintf:
_utils_sprintf:

    ; # ARGUMENTS:
    ; [ EBP +  8 ] = buffer address
    ; [ EBP + 12 ] = format string address
    ; [ EBP + 16 ] = argument vector
    ; # LOCALS:
    ; [ EBP -  4 ] = $SRC
    ; [ EBP -  8 ] = $DST
    ; [ EBP - 12 ] = $ARG
    ; [ EBP - 16 ] = $SPF ; format specifier ( not yet used )
    ; [ EBP - 32 ] = $BUF ; buffer 16 bytes long
    ; # RETURNS: number of bytes written to buffer ( termination byte not included )

    ; # PROLOG
    push ebp
    mov ebp, esp
    sub esp, byte 32 ; alloc space for locals

    ; # PAYLOAD
    ; initialization

    mov eax, dword [ ebp + 8 ] ; buffer address
    mov dword [ ebp - 8 ], eax ; ... to $DST

    mov eax, dword [ ebp + 12 ] ; format string address
    mov dword [ ebp - 4 ], eax ; ... to $SRC

    xor eax, eax ; zero out EAX
    mov dword [ ebp - 12 ], eax ; ... to $ARG

    jmp .loop

    ; # SUBROUTINES
.getc:
    mov edx, dword [ ebp - 4 ]
    mov al, byte [ edx ]
    inc edx
    mov dword [ ebp - 4 ], edx
    ret
.putc:
    mov edx, dword [ ebp - 8 ]
    mov byte [ edx ], al
    inc edx
    mov dword [ ebp - 8 ], edx
    ret
.geta:
    mov ecx, dword [ ebp - 12 ]
    mov eax, dword [ ebp + ecx * 4 + 16 ]
    inc ecx
    mov dword [ ebp - 12 ], ecx
    ret

.loop:
    call .getc
    cmp al, byte 0
    je .done
    cmp al, byte 0x25 ; '%'
    je .arg
    ; nor EOF, nor ARG
    ; ... simply put char in buffer
    call .putc
    jmp .loop

.arg:
    call .getc
    cmp al, byte 0    ; '\0'
    je .done
    cmp al, byte 0x25 ; '%'
    je .arg.esc
    cmp al, byte 0x53 ; 'S'
    je .arg.str
    cmp al, byte 0x73 ; 's'
    je .arg.str
    jmp .loop ; simply discard unsupported types
.arg.esc: ; write escaped percent sign
    call .putc
    jmp .loop
.arg.str: ; write string
    call .geta
    push dword [ ebp - 8 ]
    push eax
    call utils_strcpy
    add esp, byte 8
    add [ ebp - 8 ], eax
    jmp .loop

.done:
    mov eax, dword [ ebp - 8 ]
    mov byte [ eax ], 0 ; terminate destination string
    ; returns the number of bytes written to buffer
    sub eax, dword [ ebp + 8 ]

    ; # EPILOG
    ; no need for "add esp, byte 32"
    mov esp, ebp
    pop ebp
    ret

