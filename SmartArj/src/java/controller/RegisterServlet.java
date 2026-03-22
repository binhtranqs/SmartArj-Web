package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.persistence.EntityManager;
import model.User;
import service.AuthService;
import util.JPAUtil;

import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý đăng ký
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Nếu đã đăng nhập rồi thì chuyển về dashboard
        if (authService.isAuthenticated(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Load danh sách thành phố thực tế từ DB
        loadCities(req);

        // Hiển thị trang đăng ký
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String fullName = req.getParameter("fullName");
        String agree = req.getParameter("agree"); // checkbox điều khoản

        String cityIdStr = req.getParameter("cityId");
        Integer cityId = null;
        if (cityIdStr != null && !cityIdStr.isBlank()) {
            cityId = Integer.parseInt(cityIdStr);
        }

        try {
            // Validate
            if (username == null || username.trim().isEmpty()) {
                throw new RuntimeException("Vui lòng nhập tên đăng nhập");
            }
            if (email == null || email.trim().isEmpty()) {
                throw new RuntimeException("Vui lòng nhập email");
            }
            if (password == null || password.trim().isEmpty()) {
                throw new RuntimeException("Vui lòng nhập mật khẩu");
            }
            if (!password.equals(confirmPassword)) {
                throw new RuntimeException("Mật khẩu xác nhận không khớp");
            }
            if (!"on".equals(agree)) {
                throw new RuntimeException("Vui lòng đồng ý với điều khoản sử dụng");
            }

            // Đăng ký
            User user = authService.register(username, email, password, fullName, cityId);

            // Tự động đăng nhập sau khi đăng ký
            HttpSession session = req.getSession(true);
            authService.setCurrentUser(session, user);

            // Chuyển về dashboard với thông báo
            req.getSession().setAttribute("message", "Đăng ký thành công! Chào mừng bạn đến với SmartArj.");
            resp.sendRedirect(req.getContextPath() + "/dashboard");

        } catch (Exception e) {
            e.printStackTrace(); // Log lỗi ra console server

            String errorMessage = e.getMessage();

            // Nếu là lỗi hệ thống (JDBC, SQL, Connection...) thì hiển thị thông báo chung
            if (errorMessage != null && (errorMessage.contains("JDBC") || errorMessage.contains("SQL")
                    || errorMessage.contains("Exception") || errorMessage.contains("Constraint"))) {
                // Kiểm tra lỗi duplicate key (username/email trùng)
                if (errorMessage.contains("Duplicate entry") || errorMessage.contains("UNIQUE KEY")) {
                    errorMessage = "Tên đăng nhập hoặc email đã tồn tại.";
                } else {
                    errorMessage = "Lỗi hệ thống: Không thể xử lý yêu cầu đăng ký. Vui lòng thử lại sau.";
                }
            }

            // Đăng ký thất bại
            req.setAttribute("error", errorMessage);
            req.setAttribute("username", username);
            req.setAttribute("email", email);
            req.setAttribute("fullName", fullName);
            loadCities(req); // reload lại danh sách thành phố
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }

    /**
     * Query bảng Cities từ DB và set vào request attribute để JSP sử dụng.
     * Mỗi phần tử là Object[] = { CityID (Number), CityName (String) }
     */
    private void loadCities(HttpServletRequest req) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> cities = em.createNativeQuery(
                    // FK_Users_City trỏ vào bảng CityID (không phải Cities)
                    "SELECT CityID, CityName FROM CityID ORDER BY CityName").getResultList();
            req.setAttribute("cities", cities);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("cities", new java.util.ArrayList<>());
        } finally {
            em.close();
        }
    }
}
