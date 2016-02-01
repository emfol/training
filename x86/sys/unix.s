
bits 32

section .text

  global _sys.exit
  global _sys.write
  _sys:
    .exit:
      mov eax, 1 ; service number for "exit"
      jmp .trap
    .write:
      mov eax, 4 ; service number for "write"
    .trap:
      int 0x80 ; trap into kernel space...
      ret

