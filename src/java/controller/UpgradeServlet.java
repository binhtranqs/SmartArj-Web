package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import service.AuthService;

import java.io.IOException;

/**
 * Servlet xử lý nâng cấp VIP
 */
@WebServlet("/upgrade")
public class UpgradeServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập
        User user = authService.getCurrentUser(req.getSession(false));
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Refresh thông tin user
        user = authService.refreshUser(user);
        req.setAttribute("user", user);

        // Hiển thị trang nâng cấp VIP
        req.getRequestDispatcher("/WEB-INF/views/auth/upgrade.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Disable fake payment flow. Redirect to the upgrade page.
        resp.sendRedirect(req.getContextPath() + "/upgrade");
    }
}
