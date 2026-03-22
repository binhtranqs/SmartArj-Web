package controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/zones")
public class ZoneApiServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("[]");
            return;
        }

        model.User user = (model.User) session.getAttribute("user");
        int ownerId = user.getUserId() != null ? user.getUserId() : -1;
        boolean isAdmin = user.isAdmin();

        // JOIN Zones với Cities trong 1 query duy nhất
        String sql = "SELECT z.ZoneID, z.ZoneName, z.Description, z.Latitude, z.Longitude, "
                + "z.CityID, c.CityName "
                + "FROM Zones z LEFT JOIN Cities c ON z.CityID = c.CityID ";

        if (!isAdmin && !user.isVIP()) {
            sql += "WHERE z.OwnerID = " + ownerId + " ";
        }

        sql += "ORDER BY z.ZoneID";

        JsonArray result = new JsonArray();

        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createNativeQuery(sql).getResultList();
            for (Object[] row : rows) {
                JsonObject obj = new JsonObject();
                obj.addProperty("zoneId", row[0] != null ? ((Number) row[0]).intValue() : null);
                obj.addProperty("zoneName", (String) row[1]);
                obj.addProperty("description", (String) row[2]);
                obj.addProperty("latitude", row[3] != null ? ((Number) row[3]).doubleValue() : null);
                obj.addProperty("longitude", row[4] != null ? ((Number) row[4]).doubleValue() : null);
                obj.addProperty("cityId", row[5] != null ? ((Number) row[5]).intValue() : null);
                obj.addProperty("cityName", (String) row[6]); // ← bổ sung cityName
                result.add(obj);
            }
        } finally {
            em.close();
        }

        resp.getWriter().write(gson.toJson(result));
    }
}
