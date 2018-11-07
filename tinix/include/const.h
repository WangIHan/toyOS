#ifndef _TINIX_CONST_H_
#define _TINIX_CONST_H_

#define PUBLIC
#define PRIVATE static

#define GDT_SIZE 128

//I8259
#define INT_M_CTL 0x20
#define INT_M_CTLMASK 0x21

#define INT_S_CTL 0xA0
#define INT_S_CTLMASK 0xA1
#endif
