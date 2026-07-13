package controller;

import com.google.gson.Gson;
import exception.AppException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.AuthService;
import util.ErrorResponder;
import util.JPAUtil;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

@WebServlet("/api/current-weather")
public class CurrentWeatherServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");

            User user = authService.getCurrentUser(req.getSession(false));
            if (user == null) {
                throw new AppException(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            }

            user = authService.refreshUser(user);

            Integer cityId = user.getCityId();
            if (cityId == null) {
                cityId = 1; // Default to DaNang if not set
            }

            try (PrintWriter out = resp.getWriter()) {
                Map<String, Object> data = getCurrentWeatherData(cityId);
                if (data == null) {
                    data = new HashMap<>();
                    data.put("temperature", 25.0);
                    data.put("humidity", 70.0);
                    data.put("condition", "Nắng ấm");
                    data.put("city", cityId == 1 ? "Đà Nẵng" : "Hà Nội");
                }

                data.put("currentTime",
                        java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm dd/MM")));

                out.print(gson.toJson(data));
            }
        } catch (Exception e) {
            try {
                ErrorResponder.handle(req, resp, e);
            } catch (Exception ignored) {
                if (!resp.isCommitted()) {
                    ErrorResponder.sendApiError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal Server Error");
                }
            }
        }
    }

    private Map<String, Object> getCurrentWeatherData(int cityId) {
        // Latest weather log for any zone in this city
        String sql =
                "SELECT TOP 1 w.Temperature, w.Humidity, w.Rainfall, c.CityName " +
                "FROM WeatherLogs w " +
                "JOIN Zones z ON w.ZoneID = z.ZoneID " +
                "JOIN Cities c ON z.CityID = c.CityID " +
                "WHERE c.CityID = ? " +
                "ORDER BY w.RecordedAt DESC";

        EntityManager em = null;
        try {
            em = JPAUtil.getEntityManager();
            Query q = em.createNativeQuery(sql);
            q.setParameter(1, cityId);

            @SuppressWarnings("unchecked")
            List<Object[]> rows = q.getResultList();

            if (rows == null || rows.isEmpty()) return null;

            Object[] r = rows.get(0);

            double temperature = r[0] == null ? 0.0 : ((Number) r[0]).doubleValue();
            double humidity    = r[1] == null ? 0.0 : ((Number) r[1]).doubleValue();
            double rainfall    = r[2] == null ? 0.0 : ((Number) r[2]).doubleValue();
            String cityName    = (String) r[3];

            Map<String, Object> map = new HashMap<>();
            map.put("temperature", temperature);
            map.put("humidity", humidity);

            if (rainfall > 5.0) map.put("condition", "Mưa rào");
            else if (rainfall > 0.0) map.put("condition", "Mưa nhỏ");
            else map.put("condition", "Nắng đẹp");

            map.put("city", cityName);
            return map;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (em != null) em.close();
        }
    }
}
