#ifndef _TINIX_PROTECT_H_
#define _TINIX_PROTECT_H_
//i8259
#define INT_VECTOR_IRQ0 0x20
#define INT_VECTOR_IRQ8 0x28

typedef struct s_descriptor {
  t_16 limit_low;
  t_16 base_low;
  t_8 base_mid;
  t_8 attr1;
  t_8 limit_high_attr2;
  t_8 base_high;
}DESCRIPTOR;



#endif
