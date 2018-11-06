#include "type.h"
#include "const.h"
#include "protect.h"

PUBLIC void *memcpy(void *pDst, void *pSrc, int iSize);

PUBLIC t_8 gdt_ptr[6];
PUBLIC DESCRIPTOR gdt[GDT_SIZE];

PUBLIC void cstart() {
  memcpy(&gdt,(void *)(*((t_32 *)(&gdt_ptr[2]))),((t_16 *)(&gdt_ptr[0])));
  t_16 *p_gdt_limit = (t_16*)(&gdt_ptr[0]);
  t_32 *p_gdt_base  = (t_32*)(&gdt_ptr[2]);
  *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR);
  *p_gdt_base = (t_32)&gdt;

  disp_str("-----\"cstart\" finished-----\n");
}
