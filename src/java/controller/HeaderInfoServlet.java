package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import exception.AppException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.AuthService;
import util.JPAUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import util.ErrorResponder;

/**
 * Servlet cung cấp thông tin thời tiết và thành phố cho header widget.
 * Path: GET /api/header-info
 */
@WebServlet("/api/header-info")
public class HeaderInfoServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        EntityManager em = null;
        try {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");

            User user = authService.getCurrentUser(req.getSession(false));
            if (user == null) {
                throw new AppException(HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập");
            }

            if (user.getCityId() == null) {
                user = authService.refreshUser(user);
            }
            Integer cityId = user.getCityId();

            em = JPAUtil.getEntityManager();
            CityInfo cityInfo = getCityInfo(em, cityId);

            if (cityInfo == null) {
                throw new AppException(HttpServletResponse.SC_BAD_REQUEST,
                        "Không tìm thấy thông tin thành phố (thiếu tọa độ)");
            }

            WeatherResult weatherResult = fetchWeather(cityInfo.latitude, cityInfo.longitude);

            if (weatherResult == null) {
                throw new AppException(HttpServletResponse.SC_BAD_GATEWAY,
                        "Không thể lấy dữ liệu thời tiết từ Open-Meteo");
            }

            JsonObject result = new JsonObject();
            result.addProperty("city", cityInfo.cityName);
            result.addProperty("tempC", weatherResult.tempC);
            result.addProperty("weatherCode", weatherResult.weatherCode);
            if (weatherResult.time != null) {
                result.addProperty("fetchedAt", weatherResult.time);
            }

            resp.getWriter().print(gson.toJson(result));

        } catch (Exception e) {
            try {
                if (!(e instanceof AppException)) {
                    e = new AppException(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi server: " + e.getMessage(), e);
                }
                ErrorResponder.handle(req, resp, e);
            } catch (Exception ignored) {
                if (!resp.isCommitted()) {
                    ErrorResponder.sendApiError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal Server Error");
                }
            }
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private CityInfo getCityInfo(EntityManager em, Integer cityId) {
        String sql;
        Query query;

        if (cityId != null) {
            sql = "SELECT CityName, Latitude, Longitude FROM Cities WHERE CityID = ?";
            query = em.createNativeQuery(sql);
            query.setParameter(1, cityId);
        } else {
            // Fallback: lấy thành phố đầu tiên nếu user chưa set default
            sql = "SELECT TOP 1 CityName, Latitude, Longitude FROM Cities ORDER BY CityID ASC";
            query = em.createNativeQuery(sql);
        }

        List<Object[]> results = query.getResultList();
        if (results.isEmpty())
            return null;

        Object[] row = results.get(0);
        String name = (String) row[0];
        Double lat = row[1] != null ? ((Number) row[1]).doubleValue() : null;
        Double lon = row[2] != null ? ((Number) row[2]).doubleValue() : null;

        if (lat == null || lon == null)
            return null;

        return new CityInfo(name, lat, lon);
    }

    private WeatherResult fetchWeather(double lat, double lon) {
        String urlStr = String.format(
                "https://api.open-meteo.com/v1/forecast?latitude=%.6f&longitude=%.6f&current=temperature_2m,weather_code&timezone=Asia/Ho_Chi_Minh",
                lat, lon);

        HttpURLConnection conn = null;
        try {
            URL url = new URL(urlStr);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(8000);
            conn.setReadTimeout(20000);

            int status = conn.getResponseCode();
            if (status != 200) {
                // Đóng error stream để tránh rò rỉ tài nguyên
                try (InputStream es = conn.getErrorStream()) {
                    if (es != null) {
                        while (es.read() != -1)
                            ;
                    }
                }
                return null;
            }

            String body = readStream(conn.getInputStream());
            JsonObject json = gson.fromJson(body, JsonObject.class);

            // 2. JSON parsing null-safe
            if (json != null && json.has("current")) {
                JsonObject current = json.getAsJsonObject("current");
                if (current.has("temperature_2m") && current.has("weather_code")) {
                    double temp = current.get("temperature_2m").getAsDouble();
                    int code = current.get("weather_code").getAsInt();
                    String time = current.has("time") ? current.get("time").getAsString() : null;
                    return new WeatherResult(temp, code, time);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 1. Close/disconnect HttpURLConnection properly
            if (conn != null) {
                conn.disconnect();
            }
        }
        return null;
    }

    private String readStream(InputStream is) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        }
    }

    private static class CityInfo {
        String cityName;
        double latitude;
        double longitude;

        CityInfo(String cityName, double latitude, double longitude) {
            this.cityName = cityName;
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }

    private static class WeatherResult {
        double tempC;
        int weatherCode;
        String time;

        WeatherResult(double tempC, int weatherCode, String time) {
            this.tempC = tempC;
            this.weatherCode = weatherCode;
            this.time = time;
        }
    }
}
