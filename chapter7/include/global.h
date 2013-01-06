/********************************************************************
 * global.h
 * author: liu, linhong
 *******************************************************************/

/* EXTERN is deined as extern except in global.c */
/* use this, when other file include golbal.h, this code will be 'extern int disp_pos' */
/* in global.c, this code wiil be 'int disp_pos' */
#ifdef GLOBAL_VARIABLES_HERE
#undef EXTERN
#define EXTERN
#endif

EXTERN int 		disp_pos;
EXTERN u8 		gdt_ptr[6];
EXTERN DESCRIPTOR 	gdt[GDT_SIZE];
EXTERN u8 		idt_ptr[6];
EXTERN GATE 		idt[IDT_SIZE];

EXTERN u32		k_reenter;

EXTERN TSS		tss;
EXTERN PROCESS*		p_proc_ready;

EXTERN int 		ticks;

extern PROCESS 		proc_table[];
extern TASK		task_table[];
extern char		task_stack[];
extern irq_handler	irq_table[];
