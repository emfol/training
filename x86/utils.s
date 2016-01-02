; utils.s
; NASM assembly syntax

bits 32

section .text

global utils_strlen
global utils_strcpy
global utils_sprintf


utils_strlen:
    ; prolog
    push ebp
    mov ebp, esp
    ; payload
    mov edx, [ ebp + 8 ]
    xor eax, eax
.loop:
    cmp byte [ edx + eax ], 0
    je .done
    inc eax
    jmp .loop
.done:
    ; epilog
    pop ebp
    ret


utils_strcpy:
    ; prolog
    push ebp
    mov ebp, esp
    push ebx
    ; payload
    mov edx, [ ebp +  8 ] ; source
    mov ebx, [ ebp + 12 ] ; destination
    xor ecx, ecx
.loop:
    mov al, [ edx + ecx ]
    mov [ ebx + ecx ], al
    inc ecx
    cmp al, 0
    jne .loop
    lea eax, [ ecx - 1 ]
    ; epilog
    pop ebx
    pop ebp
    ret

utils_sprintf:
    ; # ARGUMENTS:
    ; [ EBP +  8 ] = buffer address
    ; [ EBP + 12 ] = format string address
    ; [ EBP + 16 ] = argument vector
    ; # LOCALS:
    ; [ EBP -  4 ] = ESI BACKUP
    ; [ EBP -  8 ] = EDI BACKUP
    ; [ EBP - 12 ] = $SI
    ; [ EBP - 16 ] = $DI
    ; [ EBP - 20 ] = $ARG_INDEX

    ; # PROLOG
    push ebp
    mov ebp, esp
    sub esp, 20 ; alloc space for locals ( dword * 5 )
    ; register backup
    mov [ ebp - 4 ], esi
    mov [ ebp - 8 ], edi

    ; # PAYLOAD
    ; initialization
    xor ecx, ecx
    mov [ ebp - 20 ], ecx

    mov edi, [ ebp + 8 ]
    mov [ ebp - 16 ], edi

    mov esi, [ ebp + 12 ]
    mov [ ebp - 12 ], esi

    jmp .loop

    ; # SUBROUTINES
.getc:
    mov al, [ esi ]
    inc esi
    ret
.putc:
    mov [ edi ], al
    inc edi
    ret
.geta:
    ; returns:
    ;   ECX: next argument index
    ;   EDX: argument address
    mov ecx, [ ebp - 20 ]
    lea edx, [ ebp + ecx * 4 + 16 ]
    inc ecx
    mov [ ebp - 20 ], ecx
    ret

.loop:
    call .getc
    cmp al, 0
    je .done
    cmp al, 0x25 ; '%'
    je .arg
    ; nor EOF, nor ARG
    ; ... simply put char in buffer
    call .putc
    jmp .loop

.arg:
    call .getc
    cmp al, 0    ; '\0'
    je .done
    cmp al, 0x25 ; '%'
    je .arg.esc
    cmp al, 0x53 ; 'S'
    je .arg.str
    cmp al, 0x73 ; 's'
    je .arg.str
    jmp .loop ; simply discard unsupported types
.arg.esc: ; write escaped percent sign
    call .putc
    jmp .loop
.arg.str: ; write string
    ; safety copy of important registers
    mov [ ebp - 12 ], esi
    mov [ ebp - 16 ], edi
    call .geta
    push edi
    push dword [ edx ]
    call utils_strcpy
    add esp, 8
    mov esi, [ ebp - 12 ]
    mov edi, [ ebp - 16 ]
    add edi, eax
    jmp .loop

.done:
    mov byte [ edi ], 0 ; terminate destination string
    ; returns the number of bytes written to buffer
    mov eax, edi
    sub eax, [ ebp + 8 ]

    ; # EPILOG
    ; retore backup
    mov esi, [ ebp - 4 ]
    mov edi, [ ebp - 8 ]
    mov esp, ebp
    pop ebp
    ret

