package controller;

import dao.AdminAuditLogDAO;
import dao.UserDAO;
import dao.VipRequestDAO;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import util.JPAUtil;

import java.io.IOException;
import java.util.*;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final VipRequestDAO vipDAO = new VipRequestDAO();
    private final AdminAuditLogDAO auditDAO = new AdminAuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = (User) req.getSession(false).getAttribute("user");
        if (admin == null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        boolean isAdminUser = false;
        try {
            isAdminUser = admin.isAdmin();
        } catch (Throwable t) {
        }
        if (!isAdminUser) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // --- Thống kê user ---
        List<User> allUsers = userDAO.findAll();
        long totalUsers = allUsers.size();
        long activeUsers = allUsers.stream().filter(u -> Boolean.TRUE.equals(u.getIsActive())).count();
        long vipUsers = userDAO.countVIPUsers();
        long pendingVip = vipDAO.countPending();

        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("activeUsers", activeUsers);
        req.setAttribute("vipUsers", vipUsers);
        req.setAttribute("pendingVip", pendingVip);
        req.setAttribute("recentLogs", auditDAO.findRecent(8));

        // --- Load zones + thời tiết mới nhất mỗi zone ---
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> zones = em.createNativeQuery(
                    "SELECT z.ZoneID, z.ZoneName, c.CityName, c.CityID, "
                    + "  (SELECT TOP 1 Temperature FROM WeatherLogs WHERE ZoneID=z.ZoneID ORDER BY RecordedAt DESC) AS Temp,"
                    + "  (SELECT TOP 1 Humidity    FROM WeatherLogs WHERE ZoneID=z.ZoneID ORDER BY RecordedAt DESC) AS Humid,"
                    + "  (SELECT TOP 1 Rainfall    FROM WeatherLogs WHERE ZoneID=z.ZoneID ORDER BY RecordedAt DESC) AS Rain,"
                    + "  (SELECT TOP 1 Wind        FROM WeatherLogs WHERE ZoneID=z.ZoneID ORDER BY RecordedAt DESC) AS Wind,"
                    + "  (SELECT TOP 1 RecordedAt  FROM WeatherLogs WHERE ZoneID=z.ZoneID ORDER BY RecordedAt DESC) AS UpdatedAt "
                    + "FROM Zones z "
                    + "LEFT JOIN Cities c ON z.CityID = c.CityID "
                    + "ORDER BY z.ZoneID")
                    .getResultList();

            // Convert to list of maps for JSP
            List<Map<String, Object>> zoneData = new ArrayList<>();
            for (Object[] row : zones) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("zoneId", row[0]);
                m.put("zoneName", row[1]);
                m.put("cityName", row[2] != null ? row[2] : row[1]);
                m.put("cityId", row[3]);
                m.put("temp", row[4] != null ? String.format("%.1f", ((Number) row[4]).doubleValue()) : "--");
                m.put("humid", row[5] != null ? String.format("%.0f", ((Number) row[5]).doubleValue()) : "--");
                m.put("rain", row[6] != null ? String.format("%.1f", ((Number) row[6]).doubleValue()) : "--");
                m.put("wind", row[7] != null ? String.format("%.1f", ((Number) row[7]).doubleValue()) : "--");
                m.put("updatedAt",
                        row[8] != null
                                ? row[8].toString().substring(0, Math.min(16, row[8].toString().length())).replace("T",
                                        " ")
                                : "--");
                zoneData.add(m);
            }
            req.setAttribute("zoneData", zoneData);
        } catch (Exception e) {
            req.setAttribute("zoneData", new ArrayList<>());
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
