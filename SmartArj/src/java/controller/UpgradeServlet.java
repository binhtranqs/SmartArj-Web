package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Transaction;
import model.User;
import service.AuthService;
import service.PaymentService;
import system.events.EventPublisher;
import system.events.types.VipUpgradeEvent;

import java.io.IOException;

/**
 * Servlet xử lý nâng cấp VIP
 */
@WebServlet("/upgrade")
public class UpgradeServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final PaymentService paymentService = new PaymentService();

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

        // Kiểm tra đăng nhập
        User user = authService.getCurrentUser(req.getSession(false));
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // Lấy thông tin gói VIP
            String packageType = req.getParameter("package"); // "1month", "3months", "1year"
            String paymentMethod = req.getParameter("paymentMethod"); // "MOMO", "VNPAY", etc.

            int days;
            double amount;

            switch (packageType) {
                case "1month":
                    days = 30;
                    amount = 99000;
                    break;
                case "3months":
                    days = 90;
                    amount = 249000;
                    break;
                case "1year":
                    days = 365;
                    amount = 899000;
                    break;
                default:
                    throw new RuntimeException("Gói VIP không hợp lệ");
            }

            // Tạo transaction
            Transaction transaction = paymentService.createVIPUpgrade(user, days, amount, paymentMethod);

            // Xử lý thanh toán (giả lập)
            boolean success = paymentService.processPayment(transaction);

            if (success) {
                // Refresh user trong session
                user = authService.refreshUser(user);
                authService.setCurrentUser(req.getSession(), user);

                // EVENT: VIP upgrade completed
                EventPublisher.publish(new VipUpgradeEvent(
                        user.getUserId(), user.getUsername(), days));

                // Thông báo thành công
                req.getSession().setAttribute("message",
                        "Nâng cấp VIP thành công! Bạn đã trở thành thành viên VIP.");
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                throw new RuntimeException("Thanh toán thất bại. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("user", user);
            req.getRequestDispatcher("/WEB-INF/views/auth/upgrade.jsp").forward(req, resp);
        }
    }
}
