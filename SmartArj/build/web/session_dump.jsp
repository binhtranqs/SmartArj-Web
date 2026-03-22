<%@ page contentType="text/plain; charset=UTF-8" %>
    <%@ page import="java.util.Enumeration" %>
        <%@ page import="model.User" %>
            <% out.println("--- SESSION INFO ---"); out.println("Session ID: " + session.getId());
    out.println(" Is New: " + session.isNew());
    
    out.println(" --- ATTRIBUTES ---"); Enumeration<String> names = session.getAttributeNames();
                while (names.hasMoreElements()) {
                String name = names.nextElement();
                Object value = session.getAttribute(name);
                out.println(name + " = " + value);
                if (value instanceof User) {
                User u = (User) value;
                out.println(" User Name: " + u.getUsername());
                }
                }
                %>