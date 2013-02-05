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

/* Boolean */
#define TRUE	1
#define FALSE	0

/* Color */
#define BLACK	0x0
#define WHITE	0x7
#define RED	0x4
#define GREEN	0x2
#define BLUE	0x1
#define FLASH	0x80
#define BRIGHT	0x08
#define MAKE_COLOR(x,y) (x | y)

/* discriptor number in GDT and IDT */
#define GDT_SIZE 128
#define IDT_SIZE 256

/* privilege */
#define PRIVILEGE_KRNL 0
#define PRIVILEGE_TASK 1
#define PRIVILEGE_USER 3

/* RPL */
#define RPL_KERNL	SA_RPL0
#define RPL_TASK	SA_RPL1
#define RPL_USER	SA_RPL3

/*8259A interrupt controller ports. */
#define INT_M_CTL	0x20
#define INT_M_CTLMASK	0x21
#define INT_S_CTL	0xA0
#define INT_S_CTLMASK	0xA1

/* 8253/8254 PIT */
#define TIMER0		0x40
#define TIMER_MODE	0x43
#define RATE_GENERATOR	0x34
#define TIMER_FREQ	1193182L
#define HZ		100

/* AT keyboard */
/* 8042 ports */
#define KB_DATA		0x60	/* I/O port for keyboard data
					Read : Read Output Buffer
					Write: Write Input Buffer(8042 Data&8048 Command) */
#define KB_CMD		0x64	/* I/O port for keyboard command
					Read : Read Status Register
					Write: Write Input Buffer(8042 Command) */

/* Hardware interrupt*/
#define NR_IRQ		16
#define CLOCK_IRQ	0
#define KEYBOARD_IRQ	1
#define CASCADE_IRQ	2
#define ETHER_IRQ	3
#define SECONDARY	3
#define RS232_IRQ	4
#define XT_WINI_IRQ	5
#define FLOPPY_IRQ	6
#define PRINITER_IRQ	7
#define AT_WINI_IRQ	14

/* system call */
#define NR_SYS_CALL	1
#endif /* _ORANGES_CONST_H_*/
