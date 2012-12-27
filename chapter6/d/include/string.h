/*************************************************************
 * string.h
 * author: liu, linhong
 *************************************************************/

/* symbol in 'lib/string.asm'  */
PUBLIC void* memcpy(void* p_dst, void* p_src, int size);
PUBLIC void memset(void* p_dst, char ch, int size);
PUBLIC char* strcpy(char* p_dst, char* p_src);
