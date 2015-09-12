#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>

#define APP_NAME "EchoClient"
#define MSG_USAGE "Usage:\n" \
    "    " APP_NAME " <message> <host> [<port>]"

#define DEFAULT_SERVER_PORT 7

int main( int argc, char *argv[] ) {

    char *imsg, *host, *emsg;
    int port;

    if ( argc < 3 || argc > 4 ) {
        emsg = MSG_USAGE;
        goto _abort;
    }

    imsg = argv[1];
    host = argv[2];
    port = ( argc > 3 ) ? atoi( argv[3] ) : DEFAULT_SERVER_PORT;

    printf(
        "message: %s\n host: %s\nport: %d",
        imsg,
        host,
        port
    );
    return EXIT_SUCCESS;

_abort:
    puts( emsg );
    return EXIT_FAILURE;

}

