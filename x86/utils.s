; utils.s
; NASM assembly syntax

bits 32

section .text

global utils_strlen
global utils_strcpy
global utils_format


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


utils_format:
    ; prolog
    push ebp
    mov ebp, esp
    push esi
    push edi
    sub esp, 12
    ; payload
    ; [ EBP + 8 ] = destination buffer address
    ; [ EBP + 12 ] = format string address
    ; [ [ EBP + 12 ] + $ARG * 4 ] = argument address
    ; [ EBP - 12 ] = $ARG
    mov edi, [ ebp + 8 ]
    mov esi, [ ebp + 12 ]
.loop:
.next:
    inc esi
    jmp .loop
.arg:
    inc esi
    mov al, [ esi ]
    cmp al, 0    ; '\0'
    je .done
    cmp al, 0x25 ; '%'
    je .arg.ps
    cmp al, 0x73 ; 's'
    je .arg.sp
    jmp .next
.arg.ps:
    mov byte [ edi ], 0x25 ; '%'
    inc edi
    jmp .next
.arg.sp:
.done:
    mov byte [ edi ], 0 ; terminate destination string
    sub edi, [ ebp + 8 ]
    mov eax, edi
    ; epilog
    add esp, 12
    pop edi
    pop esi
    pop ebp
    ret

