package controller;

import dao.SystemEventDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Admin Events Dashboard Servlet.
 *
 * URL: /admin/events
 *
 * Shows the Admin a feed of all system events (ListingCreated, OrderCreated,
 * PaymentSuccess, VipUpgrade, CrawlerFinished) with filtering by event type
 * and summary KPI counts.
 *
 * Access: ADMIN role only. Non-admins are redirected to /marketplace.
 */
@WebServlet("/admin/events")
public class AdminEventsServlet extends HttpServlet {

    private final SystemEventDAO eventDAO = new SystemEventDAO();

    // Supported event types for filter tabs
    private static final String[] EVENT_TYPES = {
        "LISTING_CREATED",
        "ORDER_CREATED",
        "PAYMENT_SUCCESS",
        "VIP_UPGRADE",
        "CRAWLER_FINISHED"
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireAdmin(req, resp);
        if (user == null) return;

        // ── Filter parameter ──────────────────────────────────────
        String filterType = req.getParameter("type");
        // Validate — reject arbitrary strings
        if (filterType != null && !isValidType(filterType)) {
            filterType = null;
        }

        // ── Load data ─────────────────────────────────────────────
        List<Map<String, Object>> events;
        if (filterType != null && !filterType.isEmpty()) {
            events = eventDAO.getEventsByType(filterType, 200);
        } else {
            events = eventDAO.getRecentEvents(200);
        }

        Map<String, Integer> countByType = eventDAO.countByType();
        int totalEvents = eventDAO.countTotal();

        // ── Bind to request ───────────────────────────────────────
        req.setAttribute("events",       events);
        req.setAttribute("countByType",  countByType);
        req.setAttribute("totalEvents",  totalEvents);
        req.setAttribute("selectedType", filterType != null ? filterType : "ALL");
        req.setAttribute("eventTypes",   EVENT_TYPES);

        // Convenience counts for KPI cards (default to 0 if type never seen)
        req.setAttribute("cntListing",  countByType.getOrDefault("LISTING_CREATED",  0));
        req.setAttribute("cntOrder",    countByType.getOrDefault("ORDER_CREATED",    0));
        req.setAttribute("cntPayment",  countByType.getOrDefault("PAYMENT_SUCCESS",  0));
        req.setAttribute("cntVip",      countByType.getOrDefault("VIP_UPGRADE",      0));
        req.setAttribute("cntCrawler",  countByType.getOrDefault("CRAWLER_FINISHED", 0));

        req.getRequestDispatcher("/WEB-INF/views/admin/events.jsp").forward(req, resp);
    }

    // ──────────────────────────────────────────────────────────────
    // Access guard (same pattern as AdminCrawlerServlet)
    // ──────────────────────────────────────────────────────────────

    private User requireAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/marketplace");
            return null;
        }
        return user;
    }

    private boolean isValidType(String type) {
        for (String t : EVENT_TYPES) {
            if (t.equals(type)) return true;
        }
        return false;
    }
}
