#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "include/utils.h"

int main( int argc, char **argv )
{
    if ( argc > 1 ) {
        int i;
        unsigned int r, la, lb;
        char buf[2048];
        for ( i = 1; i < argc; i++ ) {
            r = utils_sprintf( buf, " > %s [ %s ]... 100%%", "Arg:", *(argv + i) );
            la = utils_strlen( buf );
            lb = strlen( buf );
            if ( r == la && r == lb )
                printf( "Eba! %d, %d, %d\n", r, la, lb );
            puts( buf );
        }
    }
    return EXIT_SUCCESS;
}

