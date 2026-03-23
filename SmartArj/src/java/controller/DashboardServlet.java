package controller;

import jakarta.persistence.EntityManager;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import model.User;
import util.JPAUtil;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = { "/dashboard", "/DashboardServlet" })
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // --- Lấy thống kê thời tiết mới nhất từ DB ---
        EntityManager em = JPAUtil.getEntityManager();
        try {
            // Lấy record mới nhất
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT Temperature, Humidity, Rainfall, Wind, RecordedAt FROM WeatherLogs  LIMIT 1" +
                            (user != null && user.getCityId() != null ? "" : "") +
                            "ORDER BY RecordedAt DESC")
                    .getResultList();

            if (!rows.isEmpty()) {
                Object[] r = rows.get(0);
                req.setAttribute("currentTemp",
                        r[0] != null ? String.format(java.util.Locale.US, "%.1f", ((Number) r[0]).doubleValue()) : "--");
                req.setAttribute("currentHumid",
                        r[1] != null ? String.format(java.util.Locale.US, "%.0f", ((Number) r[1]).doubleValue()) : "--");
                req.setAttribute("currentRain",
                        r[2] != null ? String.format(java.util.Locale.US, "%.1f", ((Number) r[2]).doubleValue()) : "--");
                req.setAttribute("currentWind",
                        r[3] != null ? String.format(java.util.Locale.US, "%.1f", ((Number) r[3]).doubleValue()) : "--");
                req.setAttribute("lastUpdated",
                        r[4] != null ? r[4].toString().substring(0, 16).replace("T", " ") : "--");
            } else {
                req.setAttribute("currentTemp", "--");
                req.setAttribute("currentHumid", "--");
                req.setAttribute("currentRain", "--");
                req.setAttribute("currentWind", "--");
                req.setAttribute("lastUpdated", "Chưa có dữ liệu");
            }
        } catch (Exception e) {
            req.setAttribute("currentTemp", "--");
            req.setAttribute("currentHumid", "--");
            req.setAttribute("currentRain", "--");
            req.setAttribute("currentWind", "--");
            req.setAttribute("lastUpdated", "Lỗi DB");
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard/index.jsp").forward(req, resp);
    }
}

