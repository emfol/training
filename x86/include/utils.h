#ifndef _UTILS_H
#define _UTILS_H

#include <stdarg.h>

unsigned int utils_strlen( const char *str );
unsigned int utils_itoa( int num, char *buf, int base );
unsigned int utils_sprintf( char *buf, const char *fmt, ... );

#endif

