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

/**
 * Farmer Listing CRUD Servlet
 * URL mapping: /farmer/listing/*
 */
@WebServlet(urlPatterns = {
        "/farmer/listing",
        "/farmer/listing/new",
        "/farmer/listing/create",
        "/farmer/listing/edit",
        "/farmer/listing/update",
        "/farmer/listing/delete",
        "/farmer/listing/toggle-status"
})
public class FarmerListingServlet extends HttpServlet {

    private final FarmerService farmerService = new FarmerService();
    private final MarketplaceService marketplaceService = new MarketplaceService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireFarmer(req, resp);
        if (user == null)
            return;

        String path = req.getServletPath();

        if (path.endsWith("/new")) {
            // Form tạo listing mới
            List<Region> regions = marketplaceService.getAllRegions();
            req.setAttribute("regions", regions);
            req.setAttribute("listing", new Listing());
            req.setAttribute("action", "create");
            req.getRequestDispatcher("/WEB-INF/views/farmer/listing-form.jsp").forward(req, resp);

        } else if (path.endsWith("/edit")) {
            // Form edit listing
            int listingId = parseIntSafe(req.getParameter("id"), -1);
            Listing listing = farmerService.getMyListing(listingId, user.getUserId());
            if (listing == null) {
                resp.sendRedirect(req.getContextPath() + "/farmer/dashboard?error=not_found");
                return;
            }
            List<Region> regions = marketplaceService.getAllRegions();
            req.setAttribute("regions", regions);
            req.setAttribute("listing", listing);
            req.setAttribute("action", "update");
            req.getRequestDispatcher("/WEB-INF/views/farmer/listing-form.jsp").forward(req, resp);

        } else {
            // Danh sách listings
            List<Listing> listings = farmerService.getMyListings(user.getUserId());
            req.setAttribute("listings", listings);
            req.getRequestDispatcher("/WEB-INF/views/farmer/listing-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = requireFarmer(req, resp);
        if (user == null)
            return;

        String path = req.getServletPath();

        if (path.endsWith("/create")) {
            handleCreate(req, resp, user);
        } else if (path.endsWith("/update")) {
            handleUpdate(req, resp, user);
        } else if (path.endsWith("/delete")) {
            handleDelete(req, resp, user);
        } else if (path.endsWith("/toggle-status")) {
            handleToggleStatus(req, resp, user);
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, ServletException {
        try {
            Listing listing = buildListingFromRequest(req);
            listing.setFarmerId(user.getUserId());
            int newId = farmerService.createListing(listing);
            if (newId > 0) {
                resp.sendRedirect(req.getContextPath() + "/farmer/listing?success=created");
            } else {
                req.setAttribute("error", "Không thể tạo listing");
                doGet(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            List<Region> regions = marketplaceService.getAllRegions();
            req.setAttribute("regions", regions);
            req.setAttribute("action", "create");
            req.getRequestDispatcher("/WEB-INF/views/farmer/listing-form.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, ServletException {
        try {
            int listingId = parseIntSafe(req.getParameter("listingId"), -1);
            Listing listing = buildListingFromRequest(req);
            listing.setListingId(listingId);
            listing.setFarmerId(user.getUserId());
            boolean ok = farmerService.updateListing(listing);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/farmer/listing?success=updated");
            } else {
                resp.sendRedirect(req.getContextPath() + "/farmer/listing?error=update_failed");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/farmer/listing?error=" + e.getMessage());
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        int listingId = parseIntSafe(req.getParameter("listingId"), -1);
        boolean ok = farmerService.deleteListing(listingId, user.getUserId());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/farmer/listing?success=deleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/farmer/listing?error=delete_failed");
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        int listingId = parseIntSafe(req.getParameter("listingId"), -1);
        String newStatus = req.getParameter("status"); // ACTIVE or SOLD_OUT
        if (listingId <= 0 || newStatus == null) {
            resp.sendRedirect(req.getContextPath() + "/farmer/listing?error=invalid");
            return;
        }
        boolean ok = farmerService.toggleListingStatus(listingId, user.getUserId(), newStatus);
        if (ok) {
            String msg = "ACTIVE".equals(newStatus) ? "reopened" : "paused";
            resp.sendRedirect(req.getContextPath() + "/farmer/listing?success=" + msg);
        } else {
            resp.sendRedirect(req.getContextPath() + "/farmer/listing?error=toggle_failed");
        }
    }

    private Listing buildListingFromRequest(HttpServletRequest req) {
        Listing l = new Listing();
        l.setProductName(req.getParameter("productName"));
        l.setDescription(req.getParameter("description"));
        l.setRegionId(parseIntSafe(req.getParameter("regionId"), 0) > 0 ? parseIntSafe(req.getParameter("regionId"), 0)
                : null);
        l.setPrice(parseDecimalSafe(req.getParameter("price")));
        l.setUnit(req.getParameter("unit") != null ? req.getParameter("unit") : "kg");
        l.setQuantity(parseDecimalSafe(req.getParameter("quantity")));
        l.setImageUrl(req.getParameter("imageUrl"));
        l.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "ACTIVE");

        if (l.getProductName() == null || l.getProductName().trim().isEmpty()) {
            throw new RuntimeException("Tên sản phẩm không được để trống");
        }
        if (l.getPrice() == null || l.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Giá phải lớn hơn 0");
        }
        return l;
    }

    private User requireFarmer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!user.isVIP() && !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/marketplace?error=vip_required");
            return null;
        }
        return user;
    }

    private int parseIntSafe(String s, int defaultVal) {
        if (s == null || s.trim().isEmpty())
            return defaultVal;
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }

    private BigDecimal parseDecimalSafe(String s) {
        if (s == null || s.trim().isEmpty())
            return BigDecimal.ZERO;
        try {
            return new BigDecimal(s.trim().replace(",", "."));
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }
}
