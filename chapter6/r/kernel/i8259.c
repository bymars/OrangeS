/******************************************************************
 * i8259.c
 * author: liu, linhong
 ******************************************************************/
#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "proc.h"
#include "global.h"

/**
 * init_8259A
**/
PUBLIC void init_8259A()
{
    /* Master 8259, ICW1. */
    out_byte(INT_M_CTL, 0x11);
    /* Slave 8259, ICW1 */
    out_byte(INT_S_CTL, 0x11);
    /* Master 8259, ICW2. Set entry 0x20 */
    out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);
    /* Slave 8259, ICW2. Set entry 0x28 */
    out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);
    /* Master 8259, ICW3. IR2 link to slave 8259 */
    out_byte(INT_M_CTLMASK, 0x4);
    /* Slave 8259, ICW3. link to IR2 of master 8259 */
    out_byte(INT_S_CTLMASK, 0x2);
    /* Master 8259, ICW4 */
    out_byte(INT_M_CTLMASK, 0x1);
    /* Slave 8259, ICW4 */
    out_byte(INT_S_CTLMASK, 0x1);
    /* Master 8259, OCW1 */
    out_byte(INT_M_CTLMASK, 0xFE);
    /* Slave 8259, OCW1 */
    out_byte(INT_S_CTLMASK, 0xFF);

	int i;
	for (i = 0; i < NR_IRQ; i++) {
		irq_table[i] = spurious_irq;
	}
}

/*============================================================*
		spurious_irq
 *============================================================*/
PUBLIC void spurious_irq(int irq)
{
	disp_str("spurious_irq: ");
	disp_int(irq);
	disp_str("\n");
}

/*============================================================*
		put_irq_handler
 *============================================================*/
PUBLIC void put_irq_handler(int irq, irq_handler handler)
{
	disable_irq(irq);
	irq_table[irq] = handler;
}
