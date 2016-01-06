#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "include/utils.h"

int main( int argc, char **argv )
{

    int i;
    unsigned int t, r;
    char buf[2048];
    struct { int n; char *s; int b; } *lsp, ls[] = { 
        { 0x1234, "1234", 16 },
        { 1234, "1234", 10 },
        { 0xC0FFEE, "110000001111111111101110", 2 },
        { 0xC0FFEE, "c0ffee", 16 },
        { 10000, "10000", 10 },
        { 511, "777", 8 }
    };

    if ( argc > 1 ) {
        unsigned int la, lb;
        for ( i = 1; i < argc; i++ ) {
            r = utils_sprintf( buf, " > %s [ %s ]... 100%%", "Arg:", *(argv + i) );
            la = utils_strlen( buf );
            lb = strlen( buf );
            if ( r == la && r == lb )
                printf( "Eba! %d, %d, %d\n", r, la, lb );
            puts( buf );
        }
    }

    for ( i = 0; i < 6; i++ ) {
        lsp = &ls[i];
        r = utils_itoa( lsp->n, buf, lsp->b );
        printf( "Result: ( %d, %d ) -> \"%s\" ( %d )\n", lsp->n, lsp->b, buf, r );
        if ( ( t = strlen( buf ) ) != r )
            printf( "  > Expecting length %u and got %u...\n", t, r );
        if ( strcmp( lsp->s, buf ) != 0 )
            printf( "  > Expecting string \"%s\" and got \"%s\"...\n", lsp->s, buf );
    }

    return EXIT_SUCCESS;

}

