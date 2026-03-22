package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.model.Order;
import marketplace.service.FarmerService;
import model.User;

import java.io.IOException;
import java.util.List;

/**
 * Farmer Orders Management Servlet
 * URL: /farmer/orders, /farmer/orders/confirm, /farmer/orders/ship
 */
@WebServlet(urlPatterns = {
        "/farmer/orders",
        "/farmer/orders/confirm",
        "/farmer/orders/ship",
        "/farmer/orders/complete"
})
public class FarmerOrderServlet extends HttpServlet {

    private final FarmerService farmerService = new FarmerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireFarmer(req, resp);
        if (user == null)
            return;

        List<Order> orders = farmerService.getMyOrders(user.getUserId());

        // Tính stats ở Java (tránh lỗi BigDecimal trong JSTL EL)
        int totalCount = orders.size();
        int pendingCount = 0, confirmedCount = 0, shippedCount = 0, completedCount = 0;
        java.math.BigDecimal totalRevenue = java.math.BigDecimal.ZERO;
        for (Order o : orders) {
            switch (o.getStatus() != null ? o.getStatus() : "") {
                case "PENDING":   pendingCount++;   break;
                case "CONFIRMED": confirmedCount++; break;
                case "SHIPPED":   shippedCount++;   break;
                case "COMPLETED":
                    completedCount++;
                    if (o.getTotalAmount() != null) totalRevenue = totalRevenue.add(o.getTotalAmount());
                    break;
            }
        }

        req.setAttribute("orders",         orders);
        req.setAttribute("totalCount",     totalCount);
        req.setAttribute("pendingCount",   pendingCount);
        req.setAttribute("confirmedCount", confirmedCount);
        req.setAttribute("shippedCount",   shippedCount);
        req.setAttribute("completedCount", completedCount);
        req.setAttribute("totalRevenue",   totalRevenue);

        req.getRequestDispatcher("/WEB-INF/views/farmer/farmer-orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireFarmer(req, resp);
        if (user == null)
            return;

        String path = req.getServletPath();
        int orderId = parseIntSafe(req.getParameter("orderId"), -1);

        String newStatus = "PENDING";
        if (path.endsWith("/confirm"))
            newStatus = "CONFIRMED";
        else if (path.endsWith("/ship"))
            newStatus = "SHIPPED";
        else if (path.endsWith("/complete"))
            newStatus = "COMPLETED";

        boolean ok = farmerService.updateOrderStatus(orderId, newStatus, user.getUserId());
        if (ok) {
            // Khi đơn HOÀN THÀNH → cập nhật PaymentStatus = PAID
            // (COD: nhận tiền mặt khi giao; VNPay: đã PAID từ trước, update lại cũng ok)
            if ("COMPLETED".equals(newStatus)) {
                farmerService.markOrderPaid(orderId);
            }
            resp.sendRedirect(req.getContextPath() + "/farmer/orders?success=" + newStatus.toLowerCase());
        } else {
            resp.sendRedirect(req.getContextPath() + "/farmer/orders?error=update_failed");
        }
    }

    private User requireFarmer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private int parseIntSafe(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
