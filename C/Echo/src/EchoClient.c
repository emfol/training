#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define APP_NAME "EchoClient"

#define MIN_IMSG_LEN 4

#define MSG_USAGE "Usage:\n" \
    "    " APP_NAME " <message> <host> [<port>]"
#define MSG_IMSG_TOOSHORT "Message too short..."
#define MSG_BADADDR "Bad host address..."
#define MSG_BADSOCK "Error creating socket..."
#define MSG_CONNREFUSED "Connection refused..."
#define MSG_UNREACH "Server unreachable..."
#define MSG_TIMEOUT "Connection timed out..."
#define MSG_SENDFAIL "Error sending data to server..."
#define MSG_RECVFAIL "Error receiving data from server..."
#define MSG_CONNCLOSED "Connection closed abruptly..."
#define MSG_UNKNOWN "Unkown error..."

#define DEFAULT_SERVER_PORT 7

int main( int argc, char *argv[] ) {

    struct sockaddr_in server_addr;
    char *imsg, *host, *emsg, buf[BUFSIZ];
    int res, port, imsg_len, recv_len, scktfd = -1;

    if ( argc < 3 || argc > 4 ) {
        emsg = MSG_USAGE;
        goto _abort;
    }

    imsg = argv[1];
    host = argv[2];
    port = ( argc > 3 ) ? atoi( argv[3] ) : DEFAULT_SERVER_PORT;

    /* check if message is too short... */
    if ( ( imsg_len = (int)strlen( imsg ) ) < MIN_IMSG_LEN ) {
        emsg = MSG_IMSG_TOOSHORT;
        goto _abort;
    }

    /* let's show some action... */
    printf(
        "Echo Client App\n  message: %s\n  host...: %s\n  port...: %d\n\n",
        imsg,
        host,
        port
    );

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

    /* connected... let's send a message! */
    res = (int)send( scktfd, (void *)imsg, (size_t)imsg_len, 0 );
    if ( res != imsg_len ) {
        emsg = MSG_SENDFAIL;
        goto _abort;
    }

    /* any response? ... */
    recv_len = 0;
    while ( recv_len < imsg_len ) {
        res = (int)recv( scktfd, (void *)buf, BUFSIZ - 1, 0 );
        if ( res <= 0 ) {
            emsg = ( res == 0 ) ? MSG_CONNCLOSED : MSG_RECVFAIL;
            goto _abort;
        }
        buf[ res ] = '\0';
        recv_len += res;
        fputs( buf, stdout );
    }

    fputc( '\n', stdout );

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

