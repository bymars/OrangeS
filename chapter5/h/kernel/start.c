/**********************************************************************
 *start.c
 *author: liu, linhong
 *********************************************************************/

#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "string.h"
#include "global.h"

PUBLIC void cstart() 
{
	disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
		"-----\"cstart\" begins-----\n");

	/* copy gdt in loader to new gdt in kernel */
	memcpy(&gdt,       /*base of new gdt*/
		(void*)(*((u32*)(&gdt_ptr[2]))), /*base of old gdt*/
		*((u16*)(&gdt_ptr[0])) + 1   /*limit of old gdt*/
	);
	/* now the entry in old gdt is copy to new gdt*/
	/* assemble code 'sgdt [gdt_ptr]' store gdtr to gdt_ptr*/
	/* here, change the value of gdt_ptr, then lgdt will load new gdt*/
	u16* p_gdt_limit = (u16*)(&gdt_ptr[0]);
	u32* p_gdt_base = (u32*)(&gdt_ptr[2]);
	*p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
	*p_gdt_base = (u32)&gdt;

	/* the same with IDT */
	u16* p_idt_limit = (u16*)(&idt_ptr[0]);
	u32* p_idt_base = (u32*)(&idt_ptr[2]);
	*p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
	*p_idt_base = (u32)&idt;

	init_prot();

	disp_str("-----\"cstart\" ends-----\n");
}
