<%@ page import="java.sql.*" %>
    <%@ page import="util.DBContext" %>
        <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>DB Test</title>
            </head>

            <body>
                <h1>Database Connection Test</h1>
                <% try { util.DBContext db=new util.DBContext(); Connection conn=db.getConnection(); if (conn !=null) {
                    out.println("<h2 style='color:green'>SUCCESS: Connection established!</h2>");

                    // Try query
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM Zones");
                    if(rs.next()) {
                    out.println("<p>Zone Count: " + rs.getInt(1) + "</p>");
                    }
                    conn.close();
                    } else {
                    out.println("<h2 style='color:red'>FAILURE: getConnection() returned null.</h2>");
                    out.println("<p>Check server logs for ClassNotFoundException or SQLException.</p>");
                    }
                    } catch (Exception e) {
                    out.println("<h2 style='color:red'>EXCEPTION: " + e.getMessage() + "</h2>");
                    e.printStackTrace(new java.io.PrintWriter(out));
                    }
                    %>
            </body>

            </html>