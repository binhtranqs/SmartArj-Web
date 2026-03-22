package controller;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import service.AuthService;
import util.DBContext;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/current-weather")
public class CurrentWeatherServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        User user = authService.getCurrentUser(req.getSession(false));
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Refresh user to get latest CityID if changed
        user = authService.refreshUser(user);

        Integer cityId = user.getCityId();
        if (cityId == null) {
            cityId = 1; // Default to DaNang if not set
        }

        try (PrintWriter out = resp.getWriter()) {
            Map<String, Object> data = getCurrentWeatherData(cityId);
            if (data == null) {
                // Return dummy data if no weather logs found for city
                data = new HashMap<>();
                data.put("temperature", 25.0);
                data.put("humidity", 70.0);
                data.put("condition", "Nắng ấm");
                data.put("city", getCityName(cityId));
            }
            // Add current timestamp
            data.put("currentTime", java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm dd/MM")));

            out.print(gson.toJson(data));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private Map<String, Object> getCurrentWeatherData(int cityId) {
        // Fetch latest weather log for any zone in this city
        String sql = "SELECT TOP 1 w.Temperature, w.Humidity, w.Rainfall, c.CityName " +
                "FROM WeatherLogs w " +
                "JOIN Zones z ON w.ZoneID = z.ZoneID " +
                "JOIN Cities c ON z.CityID = c.CityID " +
                "WHERE c.CityID = ? " +
                "ORDER BY w.RecordedAt DESC";

        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cityId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("temperature", rs.getDouble("Temperature"));
                    map.put("humidity", rs.getDouble("Humidity"));

                    double rain = rs.getDouble("Rainfall");
                    if (rain > 5.0)
                        map.put("condition", "Mưa rào");
                    else if (rain > 0.0)
                        map.put("condition", "Mưa nhỏ");
                    else
                        map.put("condition", "Nắng đẹp");

                    map.put("city", rs.getString("CityName"));
                    return map;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getCityName(int cityId) {
        switch (cityId) {
            case 1:
                return "Đà Nẵng";
            case 2:
                return "Hà Nội";
            case 3:
                return "Hồ Chí Minh";
            case 4:
                return "Cần Thơ";
            case 5:
                return "Đà Lạt";
            case 6:
                return "Đắk Lắk";
            case 7:
                return "Hải Phòng";
            case 8:
                return "Huế";
            case 9:
                return "Nha Trang";
            case 10:
                return "Sapa";
            default:
                return "Thành phố " + cityId;
        }
    }
}
