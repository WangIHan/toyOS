%include "pm.inc"               ;constant,macro and some instructions
org 0x7c00
  jmp LABEL_BEGIN


[SECTION .gdt]
  ;; GDT----------------------------------------------------------
LABEL_GDT:          Descriptor 0, 0, 0
LABEL_DESC_CODE32:  Descriptor 0, SegCode32Len-1, DA_C+DA_32
LABEL_DESC_VIDEO:   Descriptor  0xB8000, 0xFFFF, DA_DRW
  ;; GDT end                    DA_DRW = 92h DA_C=98h DA_32=4000h
  ;; 4000h is the 32 bit code segment
  GdtLen equ $ - LABEL_GDT      ;length of GDT
  GdtPtr dw  GdtLen              ;edge of GDT
         dd  0
  ;; GDT seclector
  SelectorCode32 equ LABEL_DESC_CODE32 - LABEL_GDT 
  SelectorVideo  equ LABEL_DESC_VIDEO  - LABEL_GDT
  ;; SelectorCode32 Relative to GDT's offset
  ;; SelectorVideo  Relative to GDT's offset
  ;; End---------------------------------------------------------

[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
  mov ax,cs
  mov ds,ax
  mov es,ax
  mov ss,ax
  mov sp,0100h

  ;; initialize 32 bits code segment descaiptors
  xor eax,eax
  mov ax,cs
  shl eax,4
  add eax,LABEL_SEG_CODE32
  mov word [LABEL_DESC_CODE32+2],ax ;[GdtLen]
  shr eax,16
  mov byte [LABEL_DESC_CODE32+4],al ;[SelectorCode32]
  mov byte [LABEL_DESC_CODE32+7],ah ;[SECTION s.16]

  ;; Prepare for loading gdtr
  xor eax,eax
  mov ax,ds
  shl eax,4
  add eax,LABEL_GDT             ;eax <--gdt basic addersss
  mov dword [GdtPtr+2],eax      ;[GdtPtr+2] <-- gdt basic address

  ;; load gdtr
  lgdt [GdtPtr]

  ;; close the interrupt
  cli

  ;; open the address line A20
  in al,92h
  or al,2h                       ;2 = 0000 0010b
  out 92h,al

  ;;prepare for changing to protect mode
  mov eax,cr0
  or eax,1
  mov cr0,eax

  ;; jump to protect mode
  jmp dword SelectorCode32:0

  [SECTION .s32]
  [BITS 32]
LABEL_SEG_CODE32:
  mov ax,SelectorVideo
  mov gs,ax

  mov ecx,28
  mov edi,0
  mov bx,pmsMsg
.show:
  mov ah,0Ch
  mov al,[bx]
  mov [gs:edi],ax
  inc edi
  inc edi
  inc bx
  loop .show

  jmp $
  pmsMsg db 'Switch to protect mode!',0
  SegCode32Len equ $ - LABEL_SEG_CODE32

  times 510 - ($-$$) db 0
  db 0x55
  db 0xAA
