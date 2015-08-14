
var port = 8000,
    http = require( "http" ),
    server = http.createServer( function httpHandler( request, response ) {
        response.writeHead( 200, { "Content-Type": "text/plain; charset=UTF-8" } );
        response.end( "Hello, World!\n" );
    } );

server.listen( port );
console.log( "HTTP Server Running @ " + port );

