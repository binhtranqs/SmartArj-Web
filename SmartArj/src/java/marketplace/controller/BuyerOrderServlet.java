package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.model.Order;
import marketplace.service.BuyerService;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

/**
 * Buyer Order History Servlet
 * URL: /buyer/orders, /buyer/orders/cancel, /buyer/orders/review
 */
@WebServlet(urlPatterns = {
        "/buyer/orders",
        "/buyer/orders/cancel",
        "/buyer/orders/review"
})
public class BuyerOrderServlet extends HttpServlet {

    private final BuyerService buyerService = new BuyerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireLogin(req, resp);
        if (user == null)
            return;

        List<Order> orders = buyerService.getMyOrders(user.getUserId());
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/WEB-INF/views/marketplace/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = requireLogin(req, resp);
        if (user == null)
            return;

        String path = req.getServletPath();

        if (path.endsWith("/cancel")) {
            int orderId = parseIntSafe(req.getParameter("orderId"), -1);
            try {
                boolean ok = buyerService.cancelOrder(orderId, user.getUserId());
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/buyer/orders?success=cancelled");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/buyer/orders?error=" + URLEncoder.encode("Không tìm thấy đơn hàng", "UTF-8"));
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/buyer/orders?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
            }

        } else if (path.endsWith("/review")) {
            int farmerId = parseIntSafe(req.getParameter("farmerId"), -1);
            int orderId = parseIntSafe(req.getParameter("orderId"), -1);
            int listingId = parseIntSafe(req.getParameter("listingId"), -1);
            int rating = parseIntSafe(req.getParameter("rating"), 5);
            String comment = req.getParameter("comment");

            try {
                boolean ok = buyerService.submitReview(
                        user.getUserId(),
                        farmerId,
                        listingId > 0 ? listingId : null,
                        orderId > 0 ? orderId : null,
                        rating, comment);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/buyer/orders?success=reviewed");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/buyer/orders?error=" + URLEncoder.encode("Không thể gửi đánh giá, bạn có thể đã đánh giá hoặc đơn hàng không tồn tại", "UTF-8"));
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/buyer/orders?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }

    private User requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
