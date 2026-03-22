<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Simple Test</title>
    </head>

    <body>
        <h1>Simple Test Page</h1>

        <% try { out.println("<p>Step 1: Import User class...</p>");
            Class.forName("model.User");
            out.println("<p>✅ User class found</p>");

            out.println("<p>Step 2: Create User object...</p>");
            model.User testUser = new model.User();
            out.println("<p>✅ User object created</p>");

            out.println("<p>Step 3: Set username...</p>");
            testUser.setUsername("test");
            out.println("<p>✅ Username set: " + testUser.getUsername() + "</p>");

            out.println("<p>Step 4: Call isVIP()...</p>");
            boolean vip = testUser.isVIP();
            out.println("<p>✅ isVIP() = " + vip + "</p>");

            out.println("<p>Step 5: Call getDaysRemaining()...</p>");
            long days = testUser.getDaysRemaining();
            out.println("<p>✅ getDaysRemaining() = " + days + "</p>");

            out.println("<h2 style='color: green;'>ALL TESTS PASSED!</h2>");

            } catch (Exception e) {
            out.println("<h2 style='color: red;'>ERROR at some step:</h2>");
            out.println("<p><b>Error message:</b> " + e.getMessage() + "</p>");
            out.println("<p><b>Error type:</b> " + e.getClass().getName() + "</p>");
            out.println("<h3>Stack Trace:</h3>");
            out.println("
            <pre style='background: #f0f0f0; padding: 10px;'>");
        java.io.StringWriter sw = new java.io.StringWriter();
        e.printStackTrace(new java.io.PrintWriter(sw));
        out.println(sw.toString());
        out.println("</pre>");
            }
            %>

    </body>

    </html>