package controller;

import com.google.gson.Gson;
import dao.ChatLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

@WebServlet("/admin/chat-stats")
public class AdminChatStatsServlet extends HttpServlet {

    private final ChatLogDAO chatLogDAO = new ChatLogDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Ép mã hóa UTF-8 cho toàn bộ request & response
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Get today's stats
        long todayMessages = chatLogDAO.getTodayMessageCount();
        long todayActiveUsers = chatLogDAO.getTodayActiveUsers();
        long todayAiResponses = chatLogDAO.getTodayAiResponses();

        // Get 7-day activity data
        List<Object[]> weeklyData = chatLogDAO.getWeeklyChatActivity();
        
        List<String> labels = new ArrayList<>();
        List<Long> messagesData = new ArrayList<>();
        List<Long> aiData = new ArrayList<>();
        
        // 1. Khởi tạo danh sách 7 ngày liên tiếp (từ D-6 đến D-0)
        // và danh sách dữ liệu base toàn 0
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
        
        for (int i = 6; i >= 0; i--) {
            java.time.LocalDate d = today.minusDays(i);
            labels.add(d.format(fmt));
            messagesData.add(0L);
            aiData.add(0L);
        }
        
        // 2. Ghi đè dữ liệu thực tế từ Database vào đúng ngày
        if (weeklyData != null) {
            for (Object[] row : weeklyData) {
                if (row[0] != null) {
                    try {
                        // row[0] định dạng là java.sql.Date yyyy-MM-dd
                        java.time.LocalDate rowDate = ((java.sql.Date) row[0]).toLocalDate();
                        String dateStr = rowDate.format(fmt);
                        
                        int index = labels.indexOf(dateStr);
                        if (index != -1) {
                            long totalMsgs = row[1] != null ? ((Number) row[1]).longValue() : 0;
                            long aiResp = row[2] != null ? ((Number) row[2]).longValue() : 0;
                            
                            messagesData.set(index, totalMsgs);
                            aiData.set(index, aiResp);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        
        // Pass stats to JSP
        req.setAttribute("todayMessages", todayMessages);
        req.setAttribute("todayActiveUsers", todayActiveUsers);
        req.setAttribute("todayAiResponses", todayAiResponses);
        
        // Pass JSON strings for Chart.js
        req.setAttribute("chartLabels", gson.toJson(labels));
        req.setAttribute("chartMessages", gson.toJson(messagesData));
        req.setAttribute("chartAiData", gson.toJson(aiData));

        // Get Recent Questions & Top Questions
        List<Object[]> recentQuestions = chatLogDAO.getRecentQuestionsWithUser(15);
        List<Object[]> topQuestions = chatLogDAO.getTopAskedQuestions(10);
        
        req.setAttribute("recentQuestions", recentQuestions);
        req.setAttribute("topQuestions", topQuestions);

        req.getRequestDispatcher("/WEB-INF/views/admin/chat-stats.jsp").forward(req, resp);
    }
}
