
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.Date;

public class ChOneServlet extends HttpServlet {

	public void doGet( HttpServletRequest req, HttpServletResponse res )
		throws IOException {

		PrintWriter out = res.getWriter();
		Date date = new Date();
		out.println( "Today is: " + date.toString() );

	}

} 