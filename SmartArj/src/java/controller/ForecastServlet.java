package controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.User;
import model.WeatherLog;
import model.Zone;
import service.AuthService;
import service.ZoneService;
import dao.ForecastDAO;
import dao.WeatherLogDAO;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.List;
import util.ErrorResponder;
import util.ParamUtil;

@WebServlet("/api/forecast")
public class ForecastServlet extends HttpServlet {

    private static final String AI_URL = "http://localhost:8001/predict-city";

    /** Map: CityID (DB) → folder name dùng trong AI Engine outputs/ */
    private static final java.util.Map<Integer, String> CITY_FOLDER_MAP;
    static {
        CITY_FOLDER_MAP = new java.util.HashMap<>();
        CITY_FOLDER_MAP.put(11, "cantho");
        CITY_FOLDER_MAP.put(14, "daklak");
        CITY_FOLDER_MAP.put(12, "dalat");
        CITY_FOLDER_MAP.put(13, "danang");
        CITY_FOLDER_MAP.put(15, "hanoi");
        CITY_FOLDER_MAP.put(17, "hcm");
    }

    private final AuthService authService = new AuthService();
    private final ZoneService zoneService = new ZoneService();
    private final ForecastDAO forecastDAO = new ForecastDAO();
    private final WeatherLogDAO weatherLogDAO = new WeatherLogDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        System.out.println("[API/FORECAST] Request received. URI: " + req.getRequestURI());

        HttpSession session = req.getSession(false);
        User user = authService.getCurrentUser(session);
        System.out.println("[API/FORECAST] User: " + (user != null ? user.getUsername() : "null"));

        if (user == null) {
            ErrorResponder.sendApiError(resp, 401, "Vui lòng đăng nhập để sử dụng tính năng này");
            return;
        }

        // VIP gate
        if (!user.isVIP() && !user.isAdmin()) {
            JsonObject limited = new JsonObject();
            limited.addProperty("status", "limited");
            limited.addProperty("isVip", false);
            limited.addProperty("message", "Tính năng dự báo 7 ngày dành cho tài khoản VIP hoặc Admin.");
            limited.add("data", new JsonArray());
            resp.getWriter().print(gson.toJson(limited));
            return;
        }

        try {
            int zoneId = ParamUtil.requireInt(req, "zoneId", "Missing parameters: zoneId", "zoneId must be a number");
            Zone zone = zoneService.getById(zoneId);
            if (zone == null) {
                throw new AppException(404, "Zone not found");
            }

            // Lấy 90 ngày lịch sử gần nhất
            List<WeatherLog> history = weatherLogDAO.findLatestByZone(zoneId, 90);
            if (history.isEmpty()) {
                throw new AppException(400, "Không có dữ liệu lịch sử thời tiết để dự báo.");
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            // Build history JSON array
            JsonArray historyArr = new JsonArray();
            for (WeatherLog log : history) {
                JsonObject h = new JsonObject();
                h.addProperty("RecordedAt", sdf.format(log.getRecordedAt()));
                h.addProperty("Temperature", log.getTemperature() != null ? log.getTemperature() : 28.0);
                h.addProperty("Humidity", log.getHumidity() != null ? log.getHumidity() : 70.0);
                h.addProperty("Rainfall", log.getRainfall() != null ? log.getRainfall() : 0.0);
                historyArr.add(h);
            }

            // Xác định city từ zone
            String cityFolder = CITY_FOLDER_MAP.getOrDefault(zone.getCityId(), "danang");
            System.out.println("[API/FORECAST] Zone cityId=" + zone.getCityId() + " → city=" + cityFolder);

            // Gọi AI cho Temperature (Python tự lưu DB)
            JsonObject tempResult = callAI("Temperature", historyArr, cityFolder);
            // Gọi AI cho Humidity (Python tự lưu DB)
            JsonObject humidResult = callAI("Humidity", historyArr, cityFolder);

            // Lấy mảng forecast từ mỗi kết quả
            JsonArray tempForecast = tempResult.has("forecast") ? tempResult.getAsJsonArray("forecast")
                    : new JsonArray();
            JsonArray humidForecast = humidResult.has("forecast") ? humidResult.getAsJsonArray("forecast")
                    : new JsonArray();

            // Lấy insights
            String tempInsight = tempResult.has("insight") ? tempResult.get("insight").getAsString() : "";
            String humidInsight = humidResult.has("insight") ? humidResult.get("insight").getAsString() : "";

            // Build final data array (7 ngày)
            JsonArray finalData = new JsonArray();
            int days = Math.min(tempForecast.size(), 7);
            for (int i = 0; i < days; i++) {
                JsonObject day = new JsonObject();

                double t = 28.0, h = 70.0;
                String dateStr = "";

                if (i < tempForecast.size()) {
                    JsonObject tf = tempForecast.get(i).getAsJsonObject();
                    t = tf.has("value") ? tf.get("value").getAsDouble() : 28.0;
                    dateStr = tf.has("date") ? tf.get("date").getAsString() : "";
                }
                if (i < humidForecast.size()) {
                    JsonObject hf = humidForecast.get(i).getAsJsonObject();
                    h = hf.has("value") ? hf.get("value").getAsDouble() : 70.0;
                }

                day.addProperty("date", dateStr);
                day.addProperty("temperature", Math.round(t * 10.0) / 10.0);
                day.addProperty("humidity", Math.round(h * 10.0) / 10.0);
                day.addProperty("rainfall", 0.0); // rainfall chưa có model riêng

                String condition = "Bình thường";
                String icon = "⛅";
                if (t >= 33) {
                    condition = "Trời nóng";
                    icon = "☀️";
                } else if (t <= 20) {
                    condition = "Trời lạnh";
                    icon = "☁️";
                }

                day.addProperty("condition", condition);
                day.addProperty("icon", icon);
                finalData.add(day);
                // DB write handled by Python AI engine via save_forecasts_to_db()
            }

            JsonObject responseBody = new JsonObject();
            responseBody.addProperty("status", "success");
            responseBody.add("data", finalData);
            responseBody.addProperty("tempInsight", tempInsight);
            responseBody.addProperty("humidInsight", humidInsight);
            resp.getWriter().write(gson.toJson(responseBody));

        } catch (java.net.ConnectException ce) {
            ErrorResponder.sendApiError(resp, 503,
                    "AI Service Unavailable - hãy chạy AI Engine (app.py) trên port 8001.");
        } catch (AppException ae) {
            ErrorResponder.sendApiError(resp, ae.getStatus(), ae.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            ErrorResponder.sendApiError(resp, 500, "Lỗi server: " + e.getMessage());
        }
    }

    /**
     * Gọi FastAPI POST /predict-city cho một target và thành phố cụ thể.
     */
    private JsonObject callAI(String target, JsonArray historyArr, String cityFolder) throws IOException {
        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("target", target);
        requestBody.addProperty("city", cityFolder);
        requestBody.add("history", historyArr);

        String requestJson = gson.toJson(requestBody);
        System.out.println("[API/FORECAST] Calling AI for " + target + " -> " + AI_URL);

        URL url = new URL(AI_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Accept", "application/json");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(120000);
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(requestJson.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        System.out.println("[API/FORECAST] AI response status for " + target + ": " + status);

        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
        String response = readStream(is);
        System.out.println("[API/FORECAST] AI response for " + target + ": " + response);

        if (status >= 500) {
            throw new IOException("AI Server Error " + status + " for " + target + " - " + response);
        }

        return gson.fromJson(response, JsonObject.class);
    }

    private String readStream(InputStream is) throws IOException {
        if (is == null)
            return "";
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null)
            sb.append(line);
        reader.close();
        return sb.toString();
    }
}
