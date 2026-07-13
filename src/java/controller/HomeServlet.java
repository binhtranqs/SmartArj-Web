package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import service.AuthService;

import java.io.IOException;

/**
 * Servlet hiển thị trang Home (Landing Page) - công khai, không cần đăng nhập
 */
@WebServlet(urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = authService.getCurrentUser(session);

        // Truyền thông tin user xuống view (có thể null nếu chưa đăng nhập)
        req.setAttribute("currentUser", user);

        req.getRequestDispatcher("/WEB-INF/views/home/index.jsp").forward(req, resp);
    }
}
