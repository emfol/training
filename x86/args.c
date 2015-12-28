#include <stdlib.h>
#include <stdio.h>

int main( int argc, char **argv )
{
    if ( argc > 1 )
    {
        int i;
        puts( "Args:" );
        for ( i = 1; i < argc; i++ )
            printf( "  > %02d. %s\n", i, *(argv + i) );
    }
    return EXIT_SUCCESS;
}

