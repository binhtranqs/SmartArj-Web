package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;

@WebServlet(urlPatterns = { "/admin/vip-queue", "/admin/ai-insights", "/admin/subscriptions",
        "/admin/system" })
public class AdminPlaceholderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User admin = (User) req.getSession(false).getAttribute("user");
        if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String path = req.getServletPath();
        String jspPath = "";

        switch (path) {
            case "/admin/vip-queue":
                jspPath = "/WEB-INF/views/admin/vip-queue.jsp";
                break;
            case "/admin/chat-stats":
                jspPath = "/WEB-INF/views/admin/chat-stats.jsp";
                break;
            case "/admin/ai-insights":
                jspPath = "/WEB-INF/views/admin/ai-insights.jsp";
                break;
            case "/admin/subscriptions":
                jspPath = "/WEB-INF/views/admin/subscriptions.jsp";
                break;
            case "/admin/system":
                jspPath = "/WEB-INF/views/admin/system.jsp";
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
        }

        req.getRequestDispatcher(jspPath).forward(req, resp);
    }
}
