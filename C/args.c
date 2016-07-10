#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define FORMAT "%02d. %s (%lu)\n"

int main(int argc, char **argv) {

  int i;
  char *p;

  for (i = 1; i < argc; i++) {
    p = *(argv + i);
    printf(FORMAT, i, p, strlen(p));
  }

  return EXIT_SUCCESS;

}
