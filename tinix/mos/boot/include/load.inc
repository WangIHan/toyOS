BaseOfLoader		equ	 09000h	; LOADER.BIN 被加载到的位置 ----  段地址
OffsetOfLoader	equ	 0100h	; LOADER.BIN 被加载到的位置 ---- 偏移地址

BaseOfLoaderPhyAddr	equ	BaseOfLoader * 10h
BaseOfKernelFile	  equ	 08000h	
OffsetOfKernelFile	equ	     0h	

BaseOfKernelFilePhyAddr	equ	BaseOfKernelFile * 10h
KernelEntryPointPhyAddr	equ	030400h	
			

PageDirBase		equ	200000h	
PageTblBase		equ	201000h	