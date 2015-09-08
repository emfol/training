package com.example.chatapp;

import java.lang.Object;
import java.lang.String;
import java.lang.Math;
import java.lang.System;
import java.lang.Thread;
import java.lang.Runnable;
import java.lang.InterruptedException;
import java.lang.IllegalArgumentException;

import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.nio.charset.Charset;

import java.util.concurrent.Semaphore;

import java.net.Socket;
import java.net.ServerSocket;
import java.net.SocketTimeoutException;

public final class ServerApp extends Object implements Runnable {

    private static final int SERVER_PORT = 12345;
    private static final int SERVER_BACKLOG = 20;
    private static final int SERVER_SOCKET_TIMEOUT = 60 * 1000; // ms
    private static final Charset CHARSET_UTF8 = Charset.forName( "UTF-8" );
    private static final Semaphore appSemaphore;
    private static final String[] appMessageList;
    private static volatile boolean appShouldContinue = true;

    private final Socket _socket;

    static {
        appSemaphore = new Semaphore( SERVER_BACKLOG, false );
        appMessageList = new String[] {
            "Take smaller bites...",
            "Go for the tight jeans. No, they do NOT make you look fat.",
            "One word: inappropriate.",
            "Just for today, be honest.",
            "Tell your boss what you REALLY think...",
            "You might want to rethink that haircut."
        };
    }

    private ServerApp( Socket socket ) {
        super();
        if ( socket == null || socket.isClosed() || !socket.isConnected() ) {
            throw new IllegalArgumentException(
                "ServerApp constructor requires a valid connected socket..."
            );
        }
        this._socket = socket;
    }

    private static String getRandomMessage() {
        int index = (int)( Math.random() * ServerApp.appMessageList.length );
        return ServerApp.appMessageList[index];
    }

    private static void workerLoop( BufferedReader input, PrintWriter output ) throws IOException {

        boolean shoudContinue = true;
        String cmd;

        do {
            cmd = input.readLine();
            if ( cmd == null ) {
                shoudContinue = false;
            } else if ( cmd.equals( "NEXT" ) ) {
                output.println( ServerApp.getRandomMessage() );
            } else if ( cmd.equals( "SHUTDOWN" ) ) {
                ServerApp.appShouldContinue = false;
                shoudContinue = false;
            } else {
                output.println( "I'm sorry... Can you repeat?" );
            }
        } while ( shoudContinue );

    }

    public void run() {

        BufferedReader in;
        PrintWriter out;

        try {

            // no timeout for socket I/O...
            this._socket.setSoTimeout( 0 );

            in = new BufferedReader( new InputStreamReader(
                this._socket.getInputStream(),
                ServerApp.CHARSET_UTF8
            ) );

            out = new PrintWriter( new OutputStreamWriter(
                this._socket.getOutputStream(),
                ServerApp.CHARSET_UTF8
            ), true );

            // run worker loop...
            ServerApp.workerLoop( in, out );

        } catch ( IOException e ) {
            System.err.println( "Error #3: ".concat( e.getMessage() ) );
        } finally {

            // close socket...
            try {
                this._socket.close();
            } catch ( IOException e ) {
                System.err.println( "Error #4: ".concat( e.getMessage() ) );
            }

            // release semaphore...
            ServerApp.appSemaphore.release();
            System.out.println( " ~ Connection closed..." );

        }

    }

    public static void main( String[] args ) {

        Socket socket;
        ServerSocket serverSocket;

        try {

            serverSocket = new ServerSocket(
                ServerApp.SERVER_PORT,
                ServerApp.SERVER_BACKLOG
            );
            serverSocket.setSoTimeout( ServerApp.SERVER_SOCKET_TIMEOUT );

            // server socket run loop...
            run_loop:
            while ( ServerApp.appShouldContinue ) {

                // acquire semaphore permit...
                try {
                    ServerApp.appSemaphore.acquire();
                } catch ( InterruptedException e ) {
                    System.err.println( "Error #1: Main thread interrupted on semaphore wait..." );
                    continue run_loop;
                }

                // accept connections...
                try {

                    System.out.print( "Listening for incoming connection... " );
                    socket = serverSocket.accept();
                    // start worker thread to deal with client connection...
                    ( new Thread( new ServerApp( socket ) ) ).start();
                    System.out.println( "OK!" );

                } catch ( SocketTimeoutException e ) {
                    ServerApp.appSemaphore.release();
                    System.out.println( "Timeout!" );
                }

            }

            // destroy server socket...
            serverSocket.close();

        } catch ( IOException e ) {
            System.err.println( "Error #2: ".concat( e.getMessage() ) );
        }

        // Bye!
        System.out.println( "Bye!" );

    }

}
