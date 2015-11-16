package com.loosingtouch.training;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.Date;

public class MyFirstServlet extends HttpServlet {

    @Override
    public void doGet( HttpServletRequest req, HttpServletResponse res )
        throws IOException {

        Date date = new Date();
        PrintWriter out = res.getWriter();
        out.println( "Hello World!" );
        out.println( "Today is: " + date.toString() );

    }

} 
