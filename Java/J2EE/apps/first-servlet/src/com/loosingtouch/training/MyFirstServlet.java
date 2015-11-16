package com.loosingtouch.training;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.Date;

public class MyFirstServlet extends HttpServlet {

    public void doGet( HttpServletRequest req, HttpServletResponse res )
        throws IOException {

        PrintWriter out = res.getWriter();
        Date date = new Date();
        out.println( "Hi!" );
        out.println( "Today is: " + date.toString() );

    }

} 
