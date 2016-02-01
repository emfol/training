
bits 32

section .data
    msg: db "Hello, World...", 0x0A, 0x0A, 0x00
    arg: db "Arguments:", 0x0A, 0x0A, 0x00
    fmt: db '  > "%s" + [%s] + (%s) = 100%% :-)', 0x0A, 0x00

section .text

  extern _sys.write
  extern utils_strlen
  extern utils_sprintf

  global main
  main:

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
    push dword arg
    call print
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
    push fmt
    push edx
    call utils_sprintf
    add esp, 20
    lea eax, [ ebp - 1028 ]
    push eax
    call print
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
    push dword msg
    call print
    add esp, 4
    mov eax, 65 ; set status code

  .leave:
    ; epilog
    mov esp, ebp
    pop ebp
    ret

  print:
    ; prolog
    push ebp
    mov ebp, esp
    push dword [ ebp + 8 ]
    call utils_strlen
    add esp, 4
    push eax
    push dword [ ebp + 8 ]
    push dword 1 ; STDOUT
    call _sys.write
    add esp, 12
    ; epilog
    mov esp, ebp
    pop ebp
    ret

