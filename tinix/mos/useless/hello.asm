  [section .data]
  strHello db "Hello World!",0Ah
  STRLEN equ $-strHello
  [section .text]
  global _start
_start:
  mov edx,STRLEN
  mov ecx,strHello
  mov ebx,1
  mov eax,4
  int 0x80
  mov ebx,0
  mov ebx,1
  int 0x80
