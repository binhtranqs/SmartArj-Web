package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import service.AuthService;

import java.io.IOException;

/**
 * Servlet xử lý đăng xuất
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Đăng xuất
        authService.logout(req.getSession(false));

        // Chuyển về trang đăng nhập
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
