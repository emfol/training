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
_utils_strcpy:
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
_utils_sprintf:
    ; # ARGUMENTS:
    ; [ EBP +  8 ] = buffer address
    ; [ EBP + 12 ] = format string address
    ; [ EBP + 16 ] = argument vector
    ; # LOCALS:
    ; [ EBP -  4 ] = $SRC
    ; [ EBP -  8 ] = $DST
    ; [ EBP - 12 ] = $ARG

    ; # PROLOG
    push ebp
    mov ebp, esp
    sub esp, 12 ; alloc space for locals

    ; # PAYLOAD
    ; initialization

    mov eax, [ ebp + 8 ] ; buffer address
    mov [ ebp - 8 ], eax ; ... to $DST

    mov eax, [ ebp + 12 ] ; format string address
    mov [ ebp - 4 ], eax ; ... to $SRC

    xor eax, eax ; zero out EAX
    mov [ ebp - 12 ], eax ; ... to $ARG

    jmp .loop

    ; # SUBROUTINES
.getc:
    mov edx, [ ebp - 4 ]
    mov al, [ edx ]
    inc edx
    mov [ ebp - 4 ], edx
    ret
.putc:
    mov edx, [ ebp - 8 ]
    mov [ edx ], al
    inc edx
    mov [ ebp - 8 ], edx
    ret
.geta:
    mov ecx, [ ebp - 12 ]
    mov eax, [ ebp + ecx * 4 + 16 ]
    inc ecx
    mov [ ebp - 12 ], ecx
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
    call .geta
    push dword [ ebp - 8 ]
    push eax
    call utils_strcpy
    add esp, 8
    add [ ebp - 8 ], eax
    jmp .loop

.done:
    mov eax, [ ebp - 8 ]
    mov byte [ eax ], 0 ; terminate destination string
    ; returns the number of bytes written to buffer
    sub eax, [ ebp + 8 ]

    ; # EPILOG
    ; no need for "add esp, 12"
    mov esp, ebp
    pop ebp
    ret

