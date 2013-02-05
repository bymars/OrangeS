#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "string.h"
#include "proc.h"
#include "global.h"
#include "keyboard.h"
#include "keymap.h"

PRIVATE KB_INPUT kb_in;

PRIVATE	int	code_with_E0 = 0;
PRIVATE	int	shift_l;	/* l shift state */
PRIVATE	int	shift_r;	/* r shift state */
PRIVATE	int	alt_l;		/* l alt state	 */
PRIVATE	int	alt_r;		/* r left state	 */
PRIVATE	int	ctrl_l;		/* l ctrl state	 */
PRIVATE	int	ctrl_r;		/* l ctrl state	 */
PRIVATE	int	caps_lock;	/* Caps Lock	 */
PRIVATE	int	num_lock;	/* Num Lock	 */
PRIVATE	int	scroll_lock;	/* Scroll Lock	 */
PRIVATE	int	column;
/*==================================================*
		keyboard_handler
 *==================================================*/
PUBLIC void keyboard_handler(int irq)
{
//	disp_str("*");
	u8 scan_code = in_byte(KB_DATA);
	if (kb_in.count < KB_IN_BYTES) 
	{
		*(kb_in.p_head) = scan_code;
		kb_in.p_head++;
		if (kb_in.p_head == kb_in.buf + KB_IN_BYTES)
		{
			kb_in.p_head = kb_in.buf;
		}
		kb_in.count++;
	}
	
	//disp_int(scan_code);
}

/*==================================================*
		init_keyboard
 *==================================================*/
PUBLIC void init_keyboard()
{
	kb_in.count = 0;
	kb_in.p_head = kb_in.p_tail = kb_in.buf;

	put_irq_handler(KEYBOARD_IRQ, keyboard_handler);
	enable_irq(KEYBOARD_IRQ);
}
/*======================================================================*
                           keyboard_read
*======================================================================*/
PUBLIC void keyboard_read()
{
	u8 scan_code;
	char output[2];
	int make;

	u32 key;
	u32 *keyrow;
	
	memset(output, 0, 2);
	if (kb_in.count > 0) 
	{
		disable_int();
		scan_code = *(kb_in.p_tail);
		kb_in.p_tail++;
		if (kb_in.p_tail == kb_in.buf + KB_IN_BYTES)
		{
			kb_in.p_tail = kb_in.buf;
		}
		kb_in.count--;
		enable_int();

		/* 下面开始解析扫描码 */
		if (scan_code == 0xE1) {
		} else if (scan_code == 0XE0) {
			code_with_E0 = 1;
		} else {
			
			make = (scan_code & FLAG_BREAK ? FALSE : TRUE);
			keyrow = &keymap[(scan_code & 0x7F) * MAP_COLS];
			column = 0;
			if (shift_l || shift_r) {
				column = 1;	
			}
			if (code_with_E0) {
				column = 2;
				code_with_E0 = 0;
			}
			key = keyrow[column];
			switch(key) {
				case SHIFT_L :
					shift_l = make;
					key = 0;
					break;	
				case SHIFT_R :
					shift_r = make;
					key = 0;
					break;
				case CTRL_L :
					ctrl_l = make;
					key = 0;
					break;
				case CTRL_R :
					ctrl_r = make;
					key = 0;
					break;
				case ALT_L :
					alt_l = make;
					key = 0;
					break;
				case ALT_R :
					alt_r = make;
					key = 0;
					break;
				default :
					if (!make) key = 0;
					break;
			}
			if (key) {
				output[0] = key;
				disp_str(output);
			}
		}
		//disp_int(scan_code);
	}
}
