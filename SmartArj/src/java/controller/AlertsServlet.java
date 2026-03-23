package controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import exception.AppException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import util.JPAUtil;
import util.ErrorResponder;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/alerts")
public class AlertsServlet extends HttpServlet {

    private final Gson gson = new Gson();

    private static boolean toBoolean(Object v) {
        if (v == null)
            return false;
        if (v instanceof Boolean)
            return (Boolean) v;
        if (v instanceof Number)
            return ((Number) v).intValue() != 0;
        String s = String.valueOf(v).trim();
        return "1".equals(s) || "true".equalsIgnoreCase(s) || "yes".equalsIgnoreCase(s);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        EntityManager em = null;
        try {
            User user = getCurrentUser(req);
            int ownerId = user.getUserId();
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");

            em = JPAUtil.getEntityManager();

            String sql = "SELECT A.AlertID, A.ZoneID, A.Message, A.AlertTime, A.IsRead " +
                    "FROM Alerts A " +
                    "JOIN Zones Z ON A.ZoneID = Z.ZoneID ";

            // Admins see all alerts, regular users only their own
            if (!user.isAdmin()) {
                sql += "WHERE Z.OwnerID = :ownerId ";
            }
            sql += "ORDER BY A.AlertTime DESC LIMIT 10";

            Query query = em.createNativeQuery(sql);
            if (!user.isAdmin()) {
                query.setParameter("ownerId", ownerId);
            }

            List<Object[]> rows = query.getResultList();

            JsonArray arr = new JsonArray();
            for (Object[] r : rows) {
                JsonObject a = new JsonObject();
                a.addProperty("alertId", r[0] == null ? 0 : ((Number) r[0]).longValue());
                a.addProperty("zoneId", r[1] == null ? 0 : ((Number) r[1]).intValue());
                a.addProperty("message", r[2] == null ? "" : String.valueOf(r[2]));
                a.addProperty("alertTime", r[3] == null ? "" : String.valueOf(r[3]));
                a.addProperty("isRead", toBoolean(r[4]));
                arr.add(a);
            }

            JsonObject ok = new JsonObject();
            ok.addProperty("status", "success");
            ok.add("data", arr);
            resp.getWriter().print(gson.toJson(ok));
        } catch (Exception e) {
            try {
                ErrorResponder.handle(req, resp, e);
            } catch (Exception ignored) {
                if (!resp.isCommitted()) {
                    ErrorResponder.sendApiError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "Internal Server Error");
                }
            }
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private User getCurrentUser(HttpServletRequest req) throws AppException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            throw new AppException(401, "Unauthorized");
        }
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new AppException(401, "Unauthorized");
        }
        return user;
    }
}
