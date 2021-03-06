#include <type.h>
#include <const.h>
#include <protect.h>
#include <proto.h>

PUBLIC void init_8259A() {
  //Master 8259 ICW1
  out_byte(INT_M_CTL, 0x11);
  //Slave 8259 ICW2
  out_byte(INT_S_CTL, 0x11);
  //Master 8259 ICW2 Master interrupt entry address is 0x20
  out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);
  //Slave 8259 ICW2 Slave interrupt entry address is 0x28
  out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);
  //M ICW3
  out_byte(INT_M_CTLMASK, 0x4);
  //S ICW3
  out_byte(INT_S_CTLMASK, 0x2);
  // M ICW4
  out_byte(INT_M_CTLMASK, 0x1);
  //S ICW4
  out_byte(INT_S_CTLMASK, 0x1);
  // M OCW1
  out_byte(INT_M_CTLMASK, 0xff);
  //S OCW1
  out_byte(INT_S_CTLMASK, 0xff);
}
