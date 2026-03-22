package marketplace.controller;

import crawler.CrawlerScheduler;
import crawler.CrawlerService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.dao.MarketPriceDAO;
import marketplace.model.MarketPrice;
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Admin Crawler Dashboard Servlet
 * URL: /admin/crawler
 */
@WebServlet("/admin/crawler")
public class AdminCrawlerServlet extends HttpServlet {

    private final CrawlerService crawlerService = new CrawlerService();
    private final MarketPriceDAO marketPriceDAO = new MarketPriceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireAdmin(req, resp);
        if (user == null)
            return;

        List<Map<String, Object>> logs = crawlerService.getCrawlerLogs(20);
        List<MarketPrice> latestPrices = marketPriceDAO.getLatestPrices();

        req.setAttribute("crawlerLogs", logs);
        req.setAttribute("latestPrices", latestPrices);
        req.setAttribute("success", req.getParameter("success"));
        req.setAttribute("error", req.getParameter("error"));

        req.getRequestDispatcher("/WEB-INF/views/admin/crawler.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireAdmin(req, resp);
        if (user == null)
            return;

        String action = req.getParameter("action");
        if ("crawl".equals(action)) {
            try {
                CrawlerService.CrawlerResult result = CrawlerScheduler.triggerManualCrawl();
                if (result.isSuccess()) {
                    resp.sendRedirect(
                            req.getContextPath() + "/admin/crawler?success=crawled_" + result.getItemsCrawled());
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/crawler?error=" + result.getStatus());
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/crawler?error=" + e.getMessage());
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/crawler");
        }
    }

    private User requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
}
