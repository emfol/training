; utils.s
; NASM assembly syntax

bits 32

section .text

global utils_strlen
utils_strlen:
    ; prolog
    push ebp
    mov ebp, esp
    ; payload
    mov edx, [ ebp + 8 ]
    xor eax, eax
.next:
    cmp byte [ edx + eax ], 0
    je .done
    inc eax
    jmp .next
.done:
    ; epilog
    pop ebp
    ret

