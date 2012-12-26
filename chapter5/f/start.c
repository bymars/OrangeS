/**********************************************************************
 *start.c
 *author: liu, linhong
 *********************************************************************/

#include "type.h"
#include "const.h"
#include "protect.h"

PUBLIC void* memcpy(void *pDst, void* pSrc, int iSize);
PUBLIC void disp_str(char* pszInfo);

PUBLIC u8 gdt_ptr[6];
PUBLIC DESCRIPTOR gdt[GDT_SIZE];

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
}
