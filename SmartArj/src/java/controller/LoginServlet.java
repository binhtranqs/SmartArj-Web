package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import service.AuthService;


import java.io.IOException;


@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Nếu đã đăng nhập rồi thì chuyển về dashboard
        if (authService.isAuthenticated(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Hiển thị trang đăng nhập
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String remember = req.getParameter("remember"); // checkbox "Ghi nhớ đăng nhập"

        try {
            // Đăng nhập
            User user = authService.login(username, password);

            // Lưu vào session
            HttpSession session = req.getSession(true);
            authService.setCurrentUser(session, user);

            // Nếu chọn "Ghi nhớ", session sẽ tồn tại lâu hơn
            if ("on".equals(remember)) {
                session.setMaxInactiveInterval(7 * 24 * 60 * 60); // 7 ngày
            }

            // Chuyển về dashboard
            resp.sendRedirect(req.getContextPath() + "/dashboard");

        } catch (Exception e) {
            e.printStackTrace(); // Log lỗi ra console server

            String errorMessage = e.getMessage();

            // Nếu là lỗi hệ thống (JDBC, SQL, Connection...) thì hiển thị thông báo chung
            if (errorMessage != null && (errorMessage.contains("JDBC") || errorMessage.contains("SQL")
                    || errorMessage.contains("Exception"))) {
                errorMessage = "Lỗi hệ thống: Không thể kết nối đến cơ sở dữ liệu. Vui lòng thử lại sau.";
            }

            // Đăng nhập thất bại
            req.setAttribute("error", errorMessage);
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }
}
