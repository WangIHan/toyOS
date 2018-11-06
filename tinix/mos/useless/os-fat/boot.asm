  org 0x7c00
  BaseOfStack equ 0x7c00

  BaseOfLoader            equ 0x9000
  OffsetOfLoader          equ 0x100
  RootDirSectors          equ 14
  SectorNoOfRootDirectory equ 19
  SectorNoOfFAT1          equ 1
  DeltaSectorNo           equ 17

  jmp short LABEL_START
  nop

  BS_OEMName DB 'ForrestY'      ;OEM string and it is 8 characters
  BPB_BytsPerSec DW 512         ;Byts per sector
  BPB_SecPerClus DB 1            ;sectors per cluster
  BPB_RsvdSecCnt DW 1            ;sectors which are token by boot
  BPB_NumFATs    DB 2            ;the quantity of fat table
  BPB_RootEntCnt DW 224          ;the max quantity of root driver file quan
  BPB_TotSec16   DW 2880         ;the sumary of logic drivers
  BPB_Media      DB 0xF0         ;Media Descriptor
  BPB_FATSz16    DW 9            ;sectors per fat
  BPB_SecPerTrk	DW 18		         ;sectors per track
  BPB_NumHeads	DW 2		         ;quantity of heads
  BPB_HiddSec	DD 0		           ; 隐藏扇区数
  BPB_TotSec32	DD 0		       ; 如果 wTotalSectorCount 是 0 由这个值记录扇区数
  BS_DrvNum	DB 0		; 中断 13 的驱动器号
  BS_Reserved1	DB 0		; 未使用
  BS_BootSig	DB 29h		; 扩展引导标记 (29h)
  BS_VolID	DD 0		; 卷序列号
  BS_VolLab	DB 'Tinix0.01  '; 卷标, 必须 11 个字节
  BS_FileSysType	DB 'FAT12   '	; 文件系统类型, 必须 8个字节

LABEL_START:
  mov ax,cs
  mov ds,ax
  mov es,ax
  mov ss,ax
  mov sp,BaseOfStack            ;init
  ;; clear the screen
  mov ax,0x600
  mov bx,0x700
  mov cx,0
  mov dx,0x184f
  int 10h

  mov dh,0                      ;booting
  call DispStr

  xor ah,ah
  xor dl,dl
  int 13h                       ;reset floopy
  ;; find loader.bin in the root directory
  mov word [wSectorNo],SectorNoOfRootDirectory
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
  cmp word [wRootDirSizeForLoop],0
  jz LABEL_NO_LOADERBIN
  dec word [wRootDirSizeForLoop]
  mov ax,BaseOfLoader
  mov es,ax
  mov bx,OffsetOfLoader
  mov ax,[wSectorNo]
  mov cl,1
  call ReadSector
  mov si,LoaderFileName
  mov di,OffsetOfLoader
  cld
  mov dx,0x10

LABEL_SEARCH_FOR_LOADERBIN:
  cmp dx,0
  jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
  dec dx
  mov cx,11
LABEL_CMP_FILENAME:
  cmp cx,0
  jz LABEL_FILENAME_FOUND
  dec cx
  lodsb
  cmp al,byte [es:di]
  jz LABEL_GO_ON
  jmp LABEL_DIFFERENT
LABEL_GO_ON:
  inc di
  jmp LABEL_CMP_FILENAME
LABEL_DIFFERENT:
  and di,0xFFE0
  add di,20h
  mov si,LoaderFileName
  jmp LABEL_SEARCH_FOR_LOADERBIN


LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
  add word [wSectorNo],1
  jmp LABEL_SEARCH_IN_ROOT_DIR_BEGIN
LABEL_NO_LOADERBIN:
  mov dh,2
  call DispStr
  jmp $
LABEL_FILENAME_FOUND:
  mov ax,RootDirSectors
  add di,0xFFE0
  add di,0x1A
  mov cx,word [es:di]
  push cx
  add cx,ax
  add cx,DeltaSectorNo
  mov ax,BaseOfLoader
  mov es,ax
  mov bx,OffsetOfLoader
  mov ax,cx
LABEL_GOON_LOADING_FILE:
  push ax
  push bx
  mov ah,0xE
  mov al,'.'
  mov bl,0xF
  int 10h
  pop bx
  pop ax

  mov cl,1
  call ReadSector
  pop ax
  call GetFATEntry
  cmp ax,0xFFF
  jz LABEL_FILE_LOADED
  push ax
  mov dx,RootDirSectors
  add ax,dx
  mov ax,DeltaSectorNo
  add bx,[BPB_BytsPerSec]
  jmp LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
  mov dh,1
  call DispStr

  ;;----------------------------------------------------------------
  jmp BaseOfLoader:OffsetOfLoader

  ;; Variable
  wRootDirSizeForLoop dw RootDirSectors
  wSectorNo dw 0
  bOdd      db 0

  ;; String
  LoaderFileName db 'LOADER  BIN',0
  MessageLength equ 9
  BootMessage   db 'Booting  ',0
  Message1      db 'Ready.   ',0
  Message2      db 'No Loader',0

	

DispStr:
  mov ax,MessageLength
  mul dh
  add ax,BootMessage
  mov bp,ax
  mov ax,ds
  mov es,ax
  mov cx,MessageLength
  mov ax,0x1301
  mov bx,0x007
  mov dl,0
  int 10h
  ret

ReadSector:
  push bp
  mov bp,sp
  sub esp,2
  mov byte[bp-2],cl
  push bx
  mov bl,[BPB_SecPerTrk]
  div bl
  inc ah
  mov cl,ah
  mov dh,al
  shr al,1
  mov ch,al
  and dh,1
  pop bx
  mov dl,[BS_DrvNum]
.GoOnReading:
  mov ah,2
  mov al,byte [bp-2]
  int 13h
  jc .GoOnReading

  add esp,2
  pop bp
  ret

GetFATEntry:
  push es
  push bx
  push ax
  mov ax,BaseOfLoader
  sub ax,0x100
  mov es,ax
  pop ax
  mov byte [bOdd],0
  mov bx,3
  mul bx
  mov bx,2
  div bx
  cmp dx,0
  jz LABEL_EVEN
  mov byte [bOdd],1
LABEL_EVEN:
  xor dx,dx
  mov bx,[BPB_BytsPerSec]
  div bx
  push dx
  mov bx,0
  add ax,SectorNoOfFAT1
  mov cl,2
  call ReadSector
  pop dx
  add bx,dx
  mov ax,[es:bx]
  cmp byte [bOdd],1
  jnz LABEL_EVEN_2
  shr ax,4
LABEL_EVEN_2:
  and ax,0xFFF

LABEL_GET_FAT_ENRY_OK:
  pop bx
  pop es
  ret

  times 510 - ($-$$) db 0
  dw 0xAA55

