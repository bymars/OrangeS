/********************************************************
 * proc.c
 * author: liu, linhong
 ********************************************************/

#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "string.h"
#include "proc.h"
#include "global.h"

/*==================================================*
		sys_get_ticks
 *==================================================*/
PUBLIC int sys_get_ticks()
{
	return ticks;
}
