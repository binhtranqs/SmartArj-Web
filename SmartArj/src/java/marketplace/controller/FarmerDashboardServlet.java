package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.model.*;
import marketplace.service.FarmerService;
import marketplace.service.MarketplaceService;
import model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Farmer Dashboard Servlet
 * URL: /farmer/dashboard
 */
@WebServlet("/farmer/dashboard")
public class FarmerDashboardServlet extends HttpServlet {

    private final FarmerService farmerService = new FarmerService();
    private final MarketplaceService marketplaceService = new MarketplaceService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireFarmer(req, resp);
        if (user == null)
            return;

        // Dashboard stats
        Map<String, Object> stats = farmerService.getDashboardStats(user.getUserId());
        List<Listing> listings = farmerService.getMyListings(user.getUserId());
        List<Order> orders = farmerService.getMyOrders(user.getUserId());
        List<Review> reviews = farmerService.getMyReviews(user.getUserId());
        List<MarketPrice> marketPrices = marketplaceService.getLatestMarketPrices();

        req.setAttribute("stats", stats);
        req.setAttribute("listings", listings);
        req.setAttribute("recentOrders", orders.subList(0, Math.min(5, orders.size())));
        req.setAttribute("reviews", reviews);
        req.setAttribute("marketPrices", marketPrices.subList(0, Math.min(8, marketPrices.size())));

        req.getRequestDispatcher("/WEB-INF/views/farmer/dashboard.jsp").forward(req, resp);
    }

    /**
     * Kiểm tra user có quyền Farmer (VIP) không
     */
    private User requireFarmer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirect=farmer/dashboard");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!user.isVIP() && !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/marketplace?error=vip_required");
            return null;
        }
        return user;
    }
}
