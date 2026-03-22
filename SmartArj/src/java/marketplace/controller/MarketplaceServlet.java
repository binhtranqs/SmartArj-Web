package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.model.*;
import marketplace.service.MarketplaceService;
import model.User;

import java.io.IOException;
import java.util.List;

/**
 * Servlet chính của Marketplace - Browse sản phẩm nông sản
 * URL: /marketplace
 */
@WebServlet("/marketplace")
public class MarketplaceServlet extends HttpServlet {

    private final MarketplaceService service = new MarketplaceService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy params lọc
        String keyword = req.getParameter("keyword");
        String regionIdStr = req.getParameter("regionId");
        String minPriceStr = req.getParameter("minPrice");
        String maxPriceStr = req.getParameter("maxPrice");

        Integer regionId = parseIntSafe(regionIdStr);
        double minPrice = parseDoubleSafe(minPriceStr);
        double maxPrice = parseDoubleSafe(maxPriceStr);

        // Lấy listings + regions + market prices
        List<Listing> listings;
        if (keyword != null || regionId != null || minPrice > 0 || maxPrice > 0) {
            listings = service.searchListings(keyword, regionId, minPrice, maxPrice);
        } else {
            listings = service.getAllActiveListings();
        }

        List<MarketPrice> marketPrices = service.getLatestMarketPrices();
        List<Region> regions = service.getAllRegions();

        // Current user (nếu đã đăng nhập)
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Set attributes
        req.setAttribute("listings", listings);
        req.setAttribute("marketPrices", marketPrices);
        req.setAttribute("regions", regions);
        req.setAttribute("keyword", keyword);
        req.setAttribute("selectedRegionId", regionId);
        req.setAttribute("minPrice", minPrice > 0 ? minPrice : null);
        req.setAttribute("maxPrice", maxPrice > 0 ? maxPrice : null);
        req.setAttribute("totalListings", listings.size());

        // Cart count nếu đã login
        if (user != null) {
            marketplace.dao.CartDAO cartDAO = new marketplace.dao.CartDAO();
            req.setAttribute("cartCount", cartDAO.countByBuyer(user.getUserId()));

            // === GỢI Ý THÔNG MINH: lấy sản phẩm dựa theo lịch sử mua ===
            java.util.List<Listing> recommended = service.getRecommendedListings(user.getUserId(), 8);
            java.util.List<String> boughtNames  = service.getBoughtProductNames(user.getUserId());
            req.setAttribute("recommendedListings", recommended);
            req.setAttribute("boughtProductNames", boughtNames);
        }

        req.getRequestDispatcher("/WEB-INF/views/marketplace/index.jsp").forward(req, resp);
    }

    private Integer parseIntSafe(String s) {
        if (s == null || s.trim().isEmpty())
            return null;
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private double parseDoubleSafe(String s) {
        if (s == null || s.trim().isEmpty())
            return 0;
        try {
            return Double.parseDouble(s.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
