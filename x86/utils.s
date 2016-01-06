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

    ; # PROLOG
    push ebp
    mov ebp, esp
    push esi
    push edi

    ; # PAYLOAD
    ; load registers with parameters
    mov eax, dword [ ebp +  8 ]
    mov esi, dword [ ebp + 12 ]
    mov edi, esi
    mov ecx, dword [ ebp + 16 ]

    ; check if conversion base is valid
    cmp ecx, byte 2
    jl .done
    cmp ecx, byte 36
    jg .done

    ; check for negative values
    test eax, eax
    jns .alg
    neg eax
    mov byte [ edi ], 0x2D ; '-'
    inc edi

.alg:
    ; determine best algorithm
    cmp ecx, byte 2
    je .loop.alt
    cmp ecx, byte 4
    je .loop.alt
    cmp ecx, byte 8
    je .loop.alt
    cmp ecx, byte 16
    je .loop.alt
    cmp ecx, byte 32
    je .loop.alt
    jmp .loop

    ; subroutine for translating and storing digits
.append:
    cmp al, byte 0x0A
    jge .append.alpha
    add al, byte 0x30 ; '0'
    jmp .append.write
.append.alpha:
    add al, byte 0x57 ; AL = AL - 0x0A + 0x61 ( 'a' )
.append.write:
    mov byte [ edi ], al
    inc edi
    ret

.loop:
    cdq ; sign-extend EAX to EDX:EAX
    div ecx ; divide by base
    xchg eax, edx
    call .append
    mov eax, edx
    test eax, eax
    jz .reverse
    jmp .loop

.loop.alt:
    mov edx, eax
    lea eax, [ ecx - 1 ]
    and eax, edx
    call .append
    bsr eax, ecx
    xchg eax, ecx
    shr edx, cl
    mov ecx, eax
    mov eax, edx
    test eax, eax
    jz .reverse
    jmp .loop.alt

.reverse:
    cmp edi, esi
    jle .done
    mov eax, edi
    cmp byte [ esi ], 0x2D
.done:
    mov eax, edi
    cmp edi, esi
    mov eax, ebx
    mov byte [ eax ], 0
    sub eax, dword [ ebp + 12 ]

    ; # EPILOG
    pop edi
    pop esi
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

