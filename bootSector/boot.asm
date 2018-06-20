  ;; boot.asm
[ORG 0x7C00]                 ;add to offsets
  xor ax,ax                  ;make ax 0
  mov ds,ax                  ;make ds 0
  mov ss,ax                     ;stack starts at 0
  mov sp,0x9c00                 ;2000h past the code start

  cld

  mov ax,0xb800                 ;text video memory
  mov es,ax

  mov si,msg                    ;show string
  call sprint

  mov ax,0xb800
  mov gs,ax
  mov bx,0x0000                 ;'W' = 57 attrib = 0F
  mov ax,[gs:bx]

  mov word [reg16],ax            ;look at register
  call printreg16

hang:
  jmp hang
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dochar: call cprint             ;print one character
sprint: lodsb                   ;string char to AL
  cmp al,0
  jne dochar
  add byte[ypos],1              ;down one row
  mov  byte[xpos],0             ;back to left
  ret

cprint:
  mov ah,0x0f                   ;attrib = white and black
  mov cx,ax                     ;save char/attribute
  movzx ax,byte[ypos]
  mov dx,160                    ;2 bytes(char/attrib) the real address in 
  mul dx                        ;video memory
  movzx bx,byte[xpos]
  shl bx,1                      ;times 2 to skip attrib

  mov di,0                      ;start of video memory
  add di,ax                     ;add y offset
  add di,bx                     ;add x offset

  mov ax,cx                     ;restore char/attribute
  stosw                         ;write char/attribute
  add byte[xpos],1              ;advance to right

  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printreg16:
  mov di,outstr16
  mov ax,[reg16]
  mov si,hexstr
  mov cx,4
hexloop:
  rol ax,4
  mov bx,ax
  and bl,[si+bx]
  mov [di],bl
  inc di
  dec cx
  jnz hexloop

  mov si,outstr16
  call sprint

  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  xpos db 0
  ypos db 0
  hexstr db '0123456789ABCDEF'
  outstr16 db '0000',0
  reg16 dw 0
  msg db'Hello OS!',0
  ;; These func is mean to print to screen without BIOS,aswell as converting
  ;; hex so it can be sidpaly--so we can check register and memoey values
  ;; A stack is included, but only used by call and ret.
  times 510-($-$$) db 0
  ;; The CPU starts in real mode and the BIOS loads this code at address
  ;; 0000:7c00. "times 512-($-$$) db 0" is NASM's way of saying fill up 512
  ;; bytes with zero. And partcopy is going to expect that (200 int Hex =
  ;; 512 in Decimal). The next two message is 2 bytes.($-$$) refers to all
  ;; the commands that used before this statement.
  db 0x55
  db 0xAA
  ;; You will the signature(0xAA55) at the end.The high bytes will be store
  ;; in the front of RAM. The signature is that BIOS can find the boot
  ;; sector on a disk.
