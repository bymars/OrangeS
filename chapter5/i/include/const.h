/************************************************************
 * const.h
 * author: liu, linhong
 ***********************************************************/
#ifndef _ORANGES_CONST_H_
#define _ORANGES_CONST_H_

/* for reason, see file 'include/global.h' */
#define EXTERN extern

/* type of function */
#define PUBLIC
#define PRIVATE static

/* discriptor number in GDT and IDT */
#define GDT_SIZE 128
#define IDT_SIZE 256

/* privilege */
#define PRIVILEGE_KRNL 0
#define PRIVILEGE_TASK 1
#define PRIVILEGE_USER 3

/*8259A interrupt controller ports. */
#define INT_M_CTL	0x20
#define INT_M_CTLMASK	0x21
#define INT_S_CTL	0xA0
#define INT_S_CTLMASK	0xA1

#endif /* _ORANGES_CONST_H_*/
