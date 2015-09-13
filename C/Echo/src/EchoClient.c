#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define APP_NAME "EchoClient"
#define MSG_USAGE "Usage:\n" \
    "    " APP_NAME " <message> <host> [<port>]"
#define MSG_BADADDR "Bad host address..."
#define MSG_BADSOCK "Error creating socket..."
#define MSG_CONNREFUSED "Connection refused..."
#define MSG_UNREACH "Server unreachable..."
#define MSG_TIMEOUT "Connection timed out..."
#define MSG_UNKNOWN "Unkown error..."

#define DEFAULT_SERVER_PORT 7

int main( int argc, char *argv[] ) {

    struct sockaddr_in server_addr;
    char *imsg, *host, *emsg;
    int res, port, scktfd = -1;

    if ( argc < 3 || argc > 4 ) {
        emsg = MSG_USAGE;
        goto _abort;
    }

    imsg = argv[1];
    host = argv[2];
    port = ( argc > 3 ) ? atoi( argv[3] ) : DEFAULT_SERVER_PORT;

    /* prepare socket address structure... */
    memset( (void *)&server_addr, 0, sizeof(struct sockaddr_in) );
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons( (in_port_t)port );
    res = inet_pton( AF_INET, host, (void *)&server_addr.sin_addr.s_addr );
    if ( res != 1 ) {
        emsg = MSG_BADADDR;
        goto _abort;
    }

    /* create socket... */
    scktfd = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
    if ( scktfd < 0 ) {
        emsg = MSG_BADSOCK;
        goto _abort;
    }

    /* connect to server... */
    res = connect( scktfd, (struct sockaddr *)&server_addr, sizeof(struct sockaddr_in) );
    if ( res != 0 ) {
        switch ( errno ) {
            case ECONNREFUSED:
                emsg = MSG_CONNREFUSED;
                goto _abort;
                break;
            case ENETUNREACH:
                emsg = MSG_UNREACH;
                goto _abort;
            case ETIMEDOUT:
                emsg = MSG_TIMEOUT;
                goto _abort;
            default:
                emsg = MSG_UNKNOWN;
                goto _abort;
                break;
        }
    }

    printf(
        "message: %s\nhost...: %s\nport...: %d\n\n",
        imsg,
        host,
        port
    );

    /* no need for the socket anymore... */
    close( scktfd );

    return EXIT_SUCCESS;

_abort:
    if ( scktfd >= 0 ) {
        close( scktfd );
    }
    puts( emsg );
    return EXIT_FAILURE;

}

