package com.example.chatapp;

import java.lang.Object;
import java.lang.String;
import java.lang.Integer;
import java.lang.System;

import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.nio.charset.Charset;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.net.SocketTimeoutException;

public final class ClientApp extends Object {

    private static final int CONNECT_TIMEOUT = 4096;
    private static final Charset CHARSET_UTF8 = Charset.forName( "UTF-8" );

    private static boolean isVerbosityEnabled;
    private static String appServerHost;
    private static int appServerPort;
    private static InetSocketAddress appServerSockerAddress;
    private static BufferedReader appInput;

    private boolean _shouldContinue;
    private Socket _socket;

    private ClientApp() {
        super();
        this._shouldContinue = false;
        this._socket = null;
    }

    private static void verbosity( String msg ) {
        if ( ClientApp.isVerbosityEnabled ) {
            System.out.println( "~ ".concat( msg ) );
        }
    }

    private static InetSocketAddress getServerSocketAddress() throws UnknownHostException {

        InetSocketAddress addr = ClientApp.appServerSockerAddress;

        if ( addr == null ) {
            addr = new InetSocketAddress(
                InetAddress.getByName( ClientApp.appServerHost ),
                ClientApp.appServerPort
            );
            ClientApp.appServerSockerAddress = addr;
            ClientApp.verbosity( "Server address defined..." );
        }

        return addr;

    }

    private static Socket getConnectedSocket() throws IOException {

        InetSocketAddress addr = ClientApp.getServerSocketAddress();
        Socket socket = new Socket();
        socket.setSoTimeout( 0 );
        socket.connect( addr, ClientApp.CONNECT_TIMEOUT );
        ClientApp.verbosity( "Socket connected..." );
        return socket;

    }

    private Socket init() throws IOException {

        Socket s;

        this.closeConnection();
        s = ClientApp.getConnectedSocket();
        this._socket = s;
        System.out.println( "Connected!" );

        return s;

    }

    private void closeConnection() {

        Socket s = this._socket;
        if ( s != null ) {
            try {
                this._socket = null;
                s.close();
                System.out.println( "Connection closed..." );
            } catch ( IOException e ) {
                System.err.println( "Error #5: Failure while closing socket...\n  > ".concat( e.getMessage() ) );
            }
        }

    }

    private void startRunLoop( PrintWriter output, BufferedReader input ) throws IOException {

        boolean shouldContinue = true;
        String cmd, msg;

        this._shouldContinue = false;

        do {

            cmd = ClientApp.appInput.readLine();
            if ( cmd == null || cmd.equalsIgnoreCase( "QUIT" ) ) {
                shouldContinue = false;
            } else if ( cmd.equalsIgnoreCase( "RESTART" ) ) {
                this._shouldContinue = true;
                shouldContinue = false;
            } else {
                output.println( cmd );
                msg = input.readLine();
                if ( msg == null ) {
                    System.out.println( "Oops! No response..." );
                    shouldContinue = false;
                } else {
                    System.out.println( "Response: ".concat( msg ) );
                }
            }

        } while ( shouldContinue );

    }

    public void run() {

        Socket socket;
        PrintWriter out;
        BufferedReader in;

        try {

            do {

                socket = this.init();

                out = new PrintWriter( new OutputStreamWriter(
                    socket.getOutputStream(),
                    ClientApp.CHARSET_UTF8
                ), true );

                in = new BufferedReader( new InputStreamReader(
                    socket.getInputStream(),
                    ClientApp.CHARSET_UTF8
                ) );

                this.startRunLoop( out, in );

            } while ( this._shouldContinue );

        } catch ( UnknownHostException e ) {
            System.err.println( "Error #2: Could not resolve host name...\n  > ".concat( e.getMessage() ) );
        } catch ( SocketTimeoutException e ) {
            System.err.println( "Error #3: Connection timeout...\n  > ".concat( e.getMessage() ) );
        } catch ( IOException e ) {
            System.err.println( "Error #4: ".concat( e.getMessage() ) );
        } finally {
            this.closeConnection();
            System.out.println( "Bye!" );
        }

    }

	public static void main( String[] args ) {

        String sSysProp;
        Integer iSysProp;

        // verbosity...
        sSysProp = System.getProperty( "verbose" );
        ClientApp.isVerbosityEnabled = ( sSysProp != null && sSysProp.equalsIgnoreCase( "true" ) );
        // host...
        sSysProp = System.getProperty( "host" );
        ClientApp.appServerHost = ( sSysProp != null ) ? sSysProp : "localhost";
        // port...
        iSysProp = Integer.getInteger( "port", null );
        ClientApp.appServerPort = ( iSysProp != null ) ? iSysProp.intValue() : 12345;

        // garbage out!
        sSysProp = null;
        iSysProp = null;

        // app input...
        ClientApp.appInput = new BufferedReader( new InputStreamReader( System.in ) );

        // run app!
        ClientApp app = new ClientApp();
        app.run();

	}

}
