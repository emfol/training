#include <stdlib.h>
#include <stdio.h>

#define FORMAT "%02d. %s\n"

int main( int argc, char **argv ) {

  int i;

  for ( i = 1; i < argc; i++ )
    printf( FORMAT, i, *( argv + i ) );

  return EXIT_SUCCESS;

}
