bits 32

section .text

  global _sys.exit
  global _sys.write
  _sys:
    .exit:
      push ebx
      mov ebx, dword [ esp + 8 ]
      mov eax, 1 ; service number for "exit"
      int 0x80
      ; execution will never make it to this point :)
      pop ebx 
      ret
    .write:
      push ebx
      mov ebx, dword [ esp + 8 ]
      mov ecx, dword [ esp + 12 ]
      mov edx, dword [ esp + 16 ]
      mov eax, 4 ; service number for "write"
      int 0x80
      pop ebx
      ret

