package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.dao.MarketChatDAO;
import marketplace.model.MarketChatMessage;
import model.User;

import java.io.IOException;
import java.util.List;

/**
 * Chat Servlet cho Buyer ↔ Farmer
 * URL: /market-chat
 */
@WebServlet(urlPatterns = { "/market-chat", "/market-chat/send" })
public class MarketChatServlet extends HttpServlet {

    private final MarketChatDAO chatDAO = new MarketChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireLogin(req, resp);
        if (user == null)
            return;

        int partnerId = parseIntSafe(req.getParameter("partner"), -1);
        Integer listingId = parseIntSafe(req.getParameter("listing"), 0) > 0
                ? parseIntSafe(req.getParameter("listing"), 0)
                : null;

        if (partnerId <= 0) {
            // Show inbox (danh sách partner đã chat)
            java.util.List<java.util.Map<String, Object>> partners =
                    chatDAO.findChatPartnersWithInfo(user.getUserId());
            req.setAttribute("chatPartners", partners);
            req.getRequestDispatcher("/WEB-INF/views/chat/market-chat.jsp").forward(req, resp);
            return;
        }

        // Không cho chat với chính mình
        if (partnerId == user.getUserId()) {
            resp.sendRedirect(req.getContextPath() + "/market-chat");
            return;
        }

        // Require listingId to identify the specific private conversation
        if (listingId == null) {
            System.out.println("Warning: Attempted to open chat with partner " + partnerId + " but no listingId provided. Redirecting to inbox.");
            resp.sendRedirect(req.getContextPath() + "/market-chat");
            return;
        }

        // Load conversation scoped to the specific listing
        System.out.println("Loading chat between user " + user.getUserId() + " and partner " + partnerId + " for listing " + listingId);
        List<MarketChatMessage> messages = chatDAO.findConversation(user.getUserId(), partnerId, listingId);
        System.out.println("Loaded " + messages.size() + " messages for this private conversation.");

        // Mark as read specifically for this listing
        chatDAO.markRead(user.getUserId(), partnerId, listingId);

        // Lấy tên partner: ưu tiên từ DB Users (đảm bảo đúng kể cả khi chưa có tin nhắn)
        String partnerName = chatDAO.findUserName(partnerId);

        req.setAttribute("messages", messages);
        req.setAttribute("partnerId", partnerId);
        req.setAttribute("listingId", listingId);
        req.setAttribute("partnerName", partnerName);
        req.getRequestDispatcher("/WEB-INF/views/chat/market-chat.jsp").forward(req, resp);

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = requireLogin(req, resp);
        if (user == null) {
            if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.setStatus(401);
                resp.getWriter().write("{\"success\":false,\"error\":\"Unauthorized\"}");
            }
            return;
        }

        int receiverId = parseIntSafe(req.getParameter("receiverId"), -1);
        String message = req.getParameter("message");
        Integer listingId = parseIntSafe(req.getParameter("listingId"), 0) > 0
                ? parseIntSafe(req.getParameter("listingId"), 0)
                : null;

        boolean success = false;
        String errorMsg = "";

        if (receiverId > 0 && listingId != null && message != null && !message.trim().isEmpty()) {
            MarketChatMessage msg = new MarketChatMessage();
            msg.setSenderId(user.getUserId());
            msg.setReceiverId(receiverId);
            msg.setListingId(listingId);
            msg.setMessage(message.trim());
            success = chatDAO.send(msg);
            if(!success) {
                errorMsg = "Database insert failed.";
            }
            System.out.println("User " + user.getUserId() + " sent message to partner " + receiverId + " for listing " + listingId + ". Insert success: " + success);
        } else {
            errorMsg = "Thiếu thông tin người nhận, listingId, hoặc lời nhắn trống.";
            System.out.println("MarketChatServlet POST validation failed. Receiver=" + receiverId + ", Listing=" + listingId + ", Msg length=" + (message==null?0:message.length()));
        }

        // Handle AJAX response
        if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (success) {
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.setStatus(400);
                // escape quotes for simple json
                errorMsg = errorMsg.replace("\"", "\\\""); 
                resp.getWriter().write("{\"success\":false,\"error\":\"" + errorMsg + "\"}");
            }
            return;
        }

        // Standard Form Submit fallback
        String redirectUrl = req.getContextPath() + "/market-chat?partner=" + receiverId;
        if (listingId != null)
            redirectUrl += "&listing=" + listingId;
        resp.sendRedirect(redirectUrl);
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
