package com.loosingtouch.helloworld;

import java.lang.Object;
import java.lang.String;
import java.lang.StringBuilder;
import java.lang.System;

public class HelloWorld extends Object {

  public static final int INITIAL_BUFFER = 1024;

  public HelloWorld() {
    super();
  }

  public static void main( String[] args ) {

    StringBuilder buffer;
    int i;

    if ( args.length > 0 ) {
      buffer = new StringBuilder( INITIAL_BUFFER );
      i = 1;
      for ( String arg : args ) {
          buffer.append( String.format( "%02d. %s\n", i++, arg ) );
      }
      System.out.println( buffer.toString() );
    } else {
      System.out.println( "Oops! Nothing to be printed...\n" );
    }

  }

}

