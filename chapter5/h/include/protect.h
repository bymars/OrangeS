/**************************************************************
 * protect.h
 * author: liu, linhong
 *************************************************************/

#ifndef _ORANGES_PROTECT_H_
#define _ORANGES_PROTECT_H_
/* segment discriptor  */
typedef struct s_descriptor
{
    u16 limit_low;	/* Limit */
    u16 base_low;	/* Base  */
    u8 base_mid;	/* Base  */
    u8 attr1;		/* P(1) DPL(2) DT(1) TYPE(4) */
    u8 limit_high_attr2;/* G(1) D(1) 0(1) AVL(1) LimitHigh(4) */
    u8 base_high;
}DESCRIPTOR;

/* gate discriptor  */
typedef struct s_gate
{
    u16 offset_low;
    u16 selector;
    u8 dcount;
    u8 attr;
    u16 offset_high;
}GATE;

/* type value for system segment discriptor */
#define DA_386IGate	0x8E

/* index of segment discriptor */
#define INDEX_DUMMY	0
#define INDEX_FLAT_C	1
#define INDEX_FlAT_RW	2
#define INDEX_VIDEO	3

/* Selector */
#define SELECTOR_DUMMY		0
#define SELECTOR_FLAT_C		0x08
#define SELECTOR_FLAT_RW	0x10
#define SELECTOR_VIDEO		(0x18+3)

#define SELECTOR_KERNEL_CS SELECTOR_FLAT_C
#define SELECTOR_KERNEL_DS SELECTOR_FLAT_RW

/* interrupt vector */
#define INT_VECTOR_DIVIDE	0x0
#define INT_VECTOR_DEBUG	0x1
#define INT_VECTOR_NMI		0x2
#define INT_VECTOR_BREAKPOINT	0x3
#define INT_VECTOR_OVERFLOW	0x4
#define INT_VECTOR_BOUNDS	0x5
#define INT_VECTOR_INVAL_OP	0x6
#define INT_VECTOR_COPROC_NOT	0x7
#define INT_VECTOR_DOUBLE_FAULT	0x8
#define INT_VECTOR_COPROC_SEG	0x9
#define INT_VECTOR_INVAL_TSS	0xA
#define INT_VECTOR_SEG_NOT	0xB
#define INT_VECTOR_STACK_FAULT	0xC
#define INT_VECTOR_PROTECTION	0xD
#define INT_VECTOR_PAGE_FAULT	0xE
#define INT_VECTOR_COPROC_ERR	0x10

/* interrupt vector */
#define INT_VECTOR_IRQ0	0x20
#define INT_VECTOR_IRQ8	0x28

#endif /* _ORANGES_PROTECT_H_  */
