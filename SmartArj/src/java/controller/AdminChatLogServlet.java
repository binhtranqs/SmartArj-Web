package controller;

import dao.ChatLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.util.List;

/**
 * Admin Chat Log Stats
 * GET /admin/chatlogs → thống kê chat: top intents, AI call rate, recent
 * messages
 */
@WebServlet("/admin/chatlogs")
public class AdminChatLogServlet extends HttpServlet {

    private final ChatLogDAO chatLogDAO = new ChatLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        List<Object[]> topIntents = chatLogDAO.getTopIntents(10);
        Object[] stats = chatLogDAO.getStats();

        long totalChats = stats[0] != null ? ((Number) stats[0]).longValue() : 0;
        long aiCalled = stats[1] != null ? ((Number) stats[1]).longValue() : 0;
        long dbAnswered = stats[2] != null ? ((Number) stats[2]).longValue() : 0;
        double avgLatency = stats[3] != null ? ((Number) stats[3]).doubleValue() : 0;

        req.setAttribute("topIntents", topIntents);
        req.setAttribute("totalChats", totalChats);
        req.setAttribute("aiCalled", aiCalled);
        req.setAttribute("dbAnswered", dbAnswered);
        req.setAttribute("avgLatency", Math.round(avgLatency));
        req.setAttribute("recentChats", chatLogDAO.findRecent(50));

        req.getRequestDispatcher("/WEB-INF/views/admin/chat_stats.jsp").forward(req, resp);
    }
}
