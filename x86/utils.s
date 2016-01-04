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
    mov edx, [ ebp + 8 ]
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
    mov ecx, [ ebp +  8 ] ; source
    mov edx, [ ebp + 12 ] ; destination
.loop:
    mov al, [ ecx ]
    mov [ edx ], al
    cmp al, byte 0
    je .done
    inc ecx
    inc edx
    jmp .loop
.done:
    mov eax, edx
    sub eax, [ ebp + 12 ] ; adjust EAX
    ; # EPILOG
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
    ; [ EBP - 16 ] = $MOD
    ; [ EBP - 32 ] = $BUF

    ; # PROLOG
    push ebp
    mov ebp, esp
    sub esp, byte 32 ; alloc space for locals

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
    add esp, byte 8
    add [ ebp - 8 ], eax
    jmp .loop

.done:
    mov eax, [ ebp - 8 ]
    mov byte [ eax ], 0 ; terminate destination string
    ; returns the number of bytes written to buffer
    sub eax, [ ebp + 8 ]

    ; # EPILOG
    ; no need for "add esp, byte 32"
    mov esp, ebp
    pop ebp
    ret

