#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define DEFAULT_PORT 7
#define MAX_PENDING 4

/* Messages... */
#define MSG_SOCKFAIL "Error creating server socket..."
#define MSG_ADDRINUSE "The specified error is already in use..."
#define MSG_BINDFAIL "Error binding socket to address..."
#define MSG_LISTENFAIL "Cannot start listening to connections..."
#define MSG_LISTENQUEUE "Cannot dequeue connection request..."

/* Connection handler... */
static int handler( int );

int main( int argc, char *argv[] ) {

    struct sockaddr_in srv_addr, clnt_addr;
    socklen_t clnt_addrlen;
    char *emsg = "", clnt_addrstr[INET_ADDRSTRLEN];
    int res, port, clnt_fd, srv_fd = -1;

    /* determine port number... */
    port = ( argc > 1 ) ? atoi( argv[1] ) : DEFAULT_PORT;

    /* prepare socket address structure... */
    memset( (void *)&srv_addr, 0, sizeof(struct sockaddr_in) );
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons( (in_port_t)port );
    srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);

    /* create socket... */
    srv_fd = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
    if ( srv_fd < 0 ) {
        emsg = MSG_SOCKFAIL;
        goto _abort;
    }

    /* bind address to created socket... */
    res = bind( srv_fd, (struct sockaddr *)&srv_addr, sizeof(struct sockaddr_in) );
    if ( res != 0 ) {
        emsg = ( errno == EADDRINUSE ) ? MSG_ADDRINUSE : MSG_BINDFAIL;
        goto _abort;
    }

    /* start listening to connections... */
    res = listen( srv_fd, MAX_PENDING );
    if ( res != 0 ) {
        emsg = MSG_LISTENFAIL;
        goto _abort;
    }

    /* Server initialization complete...
     * Starting client connection loop...
     */

    printf( "Server started @ %d...\n", port );

    do {
        clnt_addrlen = sizeof(struct sockaddr_in);
        clnt_fd = accept( srv_fd, (struct sockaddr *)&clnt_addr, &clnt_addrlen );
        if ( clnt_fd < 0 ) {
            emsg = MSG_LISTENQUEUE;
            goto _abort;
        }
        if ( inet_ntop( AF_INET, (void *)&clnt_addr.sin_addr.s_addr, clnt_addrstr, INET_ADDRSTRLEN ) != NULL ) {
            printf( "+ Connected... [ %s:%d ]\n", clnt_addrstr, ntohs( clnt_addr.sin_port ) );
        } else {
            puts( "+ Connected..." );
        }
        res = handler( clnt_fd );
        close( clnt_fd );
    } while ( res );

    /* close server socket... */
    close( srv_fd );

    /* say good bye... */
    puts( "Bye!" );

    return EXIT_SUCCESS;

_abort:
    if ( srv_fd >= 0 ) {
        close( srv_fd );
    }
    puts( emsg );
    return EXIT_FAILURE;

}

static int handler( int clnt_fd ) {
    char *p, *pf, buf[BUFSIZ];
    int res, recv_len, ret = 1, eof = 0;
    do {
        res = recv( clnt_fd, (void *)buf, BUFSIZ, 0 );
        /* exceptional situations... */
        if ( res < 0 ) {
            if ( errno == EINTR ) {
                continue;
            }
            puts( "- Error reading from client socket..." );
            break;
        } else if ( res == 0 ) {
            puts( "- Connection closed abruptly..." );
            break;
        }
        recv_len = res; /* save recv result... */
        /* send data back... */
        res = send( clnt_fd, (void *)buf, (size_t)recv_len, 0 );
        if ( res < 0 ) {
            puts( "- Error sending data back to client..." );
            break;
        }
        puts( "~ Data sent..." );
        /* check for special terminating word... */
        if ( strcmp( "QUIT", buf ) == 0 ) {
            ret = 0;
            eof = 1;
            puts( "- Quit!" );
        } else {
            /* search for eof symbol... */
            for ( p = buf, pf = buf + recv_len; p < pf; ) {
                if ( *p++ == '\0' ) {
                    eof = 1;
                    puts( "- Done!" );
                    break;
                }
            }
        }
    } while ( !eof );
    return ret;
}
