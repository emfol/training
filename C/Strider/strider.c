#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>

static void yet_more_dangerous_call( jmp_buf *, char * );
static void dangerous_call( jmp_buf *, char * );

int main( int argc, char **argv )
{

    jmp_buf s_buf;
    int r_val;

    puts( "> before dangerous call..." );

    /* start of dangerous call... */
    r_val = setjmp( s_buf );
    if ( r_val == 0 ) {
        dangerous_call( &s_buf, argc > 1 ? *( argv + 1 ) : NULL );
    }
    /* end of dangerous call... */

    puts( "> after dangerous call..." );

    return EXIT_SUCCESS;

}

static void dangerous_call( jmp_buf *buf, char *str )
{
    yet_more_dangerous_call( buf, str );
    puts( "> dangerous executed correctly..." );
}

static void yet_more_dangerous_call( jmp_buf *buf, char *str )
{
    char c = str != NULL ? *str : '\0';
    if ( c == 'y' || c == 'Y' ) {
        longjmp( *buf, 1 );
    }
    puts( "> yet more dangerous executed correctly..." );
}

