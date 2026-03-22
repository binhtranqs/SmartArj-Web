<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.User" %>
        <%@ page import="dao.UserDAO" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>Test Login Debug</title>
            </head>

            <body>
                <h1>Debug Login Issue</h1>

                <% try { // Test 1: Check if User class works out.println("<h2>Test 1: Create User Object</h2>");
                    User testUser = new User();
                    testUser.setUsername("test");
                    testUser.setAccountType("FREE");
                    out.println("✅ User object created: " + testUser.getUsername() + "<br>");

                    // Test 2: Check isVIP method
                    out.println("<h2>Test 2: Check isVIP()</h2>");
                    boolean isVip = testUser.isVIP();
                    out.println("✅ isVIP() returned: " + isVip + "<br>");

                    // Test 3: Check getDaysRemaining method
                    out.println("<h2>Test 3: Check getDaysRemaining()</h2>");
                    long days = testUser.getDaysRemaining();
                    out.println("✅ getDaysRemaining() returned: " + days + "<br>");

                    // Test 4: Check session user
                    out.println("<h2>Test 4: Check Session User</h2>");
                    User sessionUser = (User) session.getAttribute("user");
                    if (sessionUser == null) {
                    out.println("⚠️ No user in session<br>");
                    } else {
                    out.println("✅ User in session: " + sessionUser.getUsername() + "<br>");
                    out.println("Account Type: " + sessionUser.getAccountType() + "<br>");
                    out.println("Is VIP: " + sessionUser.isVIP() + "<br>");

                    try {
                    long daysLeft = sessionUser.getDaysRemaining();
                    out.println("Days Remaining: " + daysLeft + "<br>");
                    } catch (Exception e) {
                    out.println("❌ Error calling getDaysRemaining(): " + e.getMessage() + "<br>");
                    e.printStackTrace(new java.io.PrintWriter(out));
                    }
                    }

                    // Test 5: Try to load a user from database
                    out.println("<h2>Test 5: Load User from Database</h2>");
                    UserDAO userDAO = new UserDAO();
                    User dbUser = userDAO.findById(1);
                    if (dbUser != null) {
                    out.println("✅ Loaded user from DB: " + dbUser.getUsername() + "<br>");
                    out.println("Account Type: " + dbUser.getAccountType() + "<br>");
                    out.println("Is VIP: " + dbUser.isVIP() + "<br>");

                    try {
                    long daysLeft = dbUser.getDaysRemaining();
                    out.println("Days Remaining: " + daysLeft + "<br>");
                    } catch (Exception e) {
                    out.println("❌ Error calling getDaysRemaining() on DB user: " + e.getMessage() + "<br>");
                    e.printStackTrace(new java.io.PrintWriter(out));
                    }
                    } else {
                    out.println("⚠️ No user with ID 1 found<br>");
                    }

                    } catch (Exception e) {
                    out.println("<h2>❌ ERROR</h2>");
                    out.println(""
                    + "<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
                    }
                    %>

                    <hr>
                    <a href="login">Back to Login</a>
            </body>

            </html>