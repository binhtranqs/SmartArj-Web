package controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
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
import dao.WeatherLogDAO;
import dao.ForecastDAO;

// Nếu project mày KHÔNG có CropDAO/Crop thì xóa 2 import này + phần getThresholdsForZone()
import dao.CropDAO;
import model.Crop;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;

import java.net.HttpURLConnection;
import java.net.URL;

import java.nio.charset.Charset;

import java.text.SimpleDateFormat;
import java.util.*;
import util.ErrorResponder;
import util.ParamUtil;

/**
 * VIP forecast -> gọi AI Engine (FastAPI)
 * - AI chỉ dự đoán Temperature
 * - Ưu tiên dữ liệu DB
 * - Nếu DB thiếu => bù lịch sử từ Open-Meteo archive để đủ REQUIRED_DAYS
 * - Densify để luôn đủ requiredDays liên tiếp (AI không còn báo thiếu dữ liệu)
 * - Java 7 compatible: không lambda, không method reference
 */
@WebServlet("/api/forecast")
public class ForecastServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final ZoneService zoneService = new ZoneService();
    private final WeatherLogDAO weatherLogDAO = new WeatherLogDAO();
    private final ForecastDAO forecastDAO = new ForecastDAO();

    // optional
    private final CropDAO cropDAO = new CropDAO();

    private final Gson gson = new Gson();

    // AI Engine
    private static final String AI_PREDICT_URL = "http://localhost:8000/predict";

    // Lịch sử cần gửi cho AI (mày set 90)
    private static final int REQUIRED_DAYS = 372;

    // Open-Meteo archive (free)
    private static final String OPEN_METEO_ARCHIVE =
            "https://archive-api.open-meteo.com/v1/archive";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        // 1) auth
        HttpSession session = req.getSession(false);
        User user = authService.getCurrentUser(session);
        if (user == null) {
            ErrorResponder.sendApiError(resp, 401, "Vui lòng đăng nhập để sử dụng tính năng này");
            return;
        }

        // 2) VIP gate
        if (!user.isVIP()) {
            JsonObject limited = new JsonObject();
            limited.addProperty("status", "limited");
            limited.addProperty("isVip", false);
            limited.addProperty("message", "Tính năng dự báo 7 ngày chỉ dành cho tài khoản VIP.");
            limited.add("data", new JsonArray());
            out.print(gson.toJson(limited));
            return;
        }

        try {
            // 3) params
            int zoneId = ParamUtil.requireInt(req, "zoneId", "Missing parameters: zoneId", "zoneId must be a number");

            // AI chỉ hỗ trợ Temperature
            String target = ParamUtil.getString(req, "target");
            if (target == null || target.trim().isEmpty()) target = "Temperature";
            if (!"Temperature".equalsIgnoreCase(target)) {
                throw new AppException(400, "AI chỉ hỗ trợ dự đoán Temperature.");
            }
            target = "Temperature";

            // 4) ownership
            Zone zone = zoneService.getByIdForOwner(zoneId, user.getUserId());
            if (zone == null) {
                throw new AppException(404, "Zone not found (or you don't have permission)");
            }

            // 5) lấy lịch sử từ DB (có bao nhiêu lấy bấy nhiêu, tối đa REQUIRED_DAYS)
            List<WeatherLog> dbHistory = weatherLogDAO.findHistoryByZoneDays(zoneId, REQUIRED_DAYS, 2000);
            if (dbHistory == null) dbHistory = new ArrayList<WeatherLog>();

            // 6) bù từ Open-Meteo + DENSIFY để đủ REQUIRED_DAYS liên tiếp
            List<WeatherLog> mergedHistory = getMergedHistoryPreferDB(zone, dbHistory, REQUIRED_DAYS);

            if (mergedHistory.size() < REQUIRED_DAYS) {
                throw new AppException(400,
                        "Không đủ dữ liệu lịch sử để dự báo. Hãy kiểm tra Latitude/Longitude của vùng trồng. "
                                + "Hiện có " + mergedHistory.size() + "/" + REQUIRED_DAYS + " ngày.");
            }

            // 7) thresholds
            ThresholdPack th = getThresholdsForZone(zoneId);

            // 8) build payload
            JsonObject payload = buildAiPayload(target, mergedHistory, th);

            // DEBUG: coi payload ở console server Tomcat
            System.out.println("[AI PAYLOAD] " + gson.toJson(payload));

            // 9) call AI
            JsonObject aiResponse = httpPostJson(AI_PREDICT_URL, payload);

            // 10) transform
            JsonObject transformed = transformAiResponse(aiResponse);

            // 11) save forecast to DB (Forecasts)
            try {
                saveForecastsToDb(zoneId, transformed);
            } catch (Exception saveEx) {
                // Do not fail the API if saving forecast fails
                System.err.println("[WARN] Failed to save forecasts: " + saveEx.getMessage());
            }

            out.print(gson.toJson(transformed));

        } catch (java.net.ConnectException ce) {
            ErrorResponder.sendApiError(resp, 503, "AI Service Unavailable (hãy chạy AI_Engine port 8000). " + ce.getMessage());
        } catch (IOException io) {
            ErrorResponder.sendApiError(resp, 502, "AI Service Error: " + io.getMessage());
        } catch (AppException ae) {
            ErrorResponder.sendApiError(resp, ae.getStatus(), ae.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            ErrorResponder.sendApiError(resp, 500, "Lỗi server: " + e.getMessage());
        }
    }

    // =========================
    // Threshold helper
    // =========================
    private static class ThresholdPack {
        Double minTemp, maxTemp, minHum, maxHum;
    }

    private ThresholdPack getThresholdsForZone(int zoneId) {
        ThresholdPack t = new ThresholdPack();
        t.minTemp = 15.0;
        t.maxTemp = 32.0;
        t.minHum = 40.0;
        t.maxHum = 90.0;

        // Nếu project mày không có CropDAO/Crop => xóa try/catch này
        try {
            Crop crop = cropDAO.findLatestByZoneId(zoneId);
            if (crop != null) {
                if (crop.getMinTemp() != null) t.minTemp = crop.getMinTemp();
                if (crop.getMaxTemp() != null) t.maxTemp = crop.getMaxTemp();
                if (crop.getMinHumid() != null) t.minHum = crop.getMinHumid();
                if (crop.getMaxHumid() != null) t.maxHum = crop.getMaxHumid();
            }
        } catch (Exception ignored) {}

        return t;
    }

    // =========================
    // Build payload for FastAPI
    // =========================
    private JsonObject buildAiPayload(String target, List<WeatherLog> history, ThresholdPack th) {
        JsonObject payload = new JsonObject();
        payload.addProperty("target", target);

        JsonObject thresholds = new JsonObject();
        thresholds.addProperty("min_temp", th.minTemp);
        thresholds.addProperty("max_temp", th.maxTemp);
        thresholds.addProperty("min_humidity", th.minHum);
        thresholds.addProperty("max_humidity", th.maxHum);
        payload.add("thresholds", thresholds);

        SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");

        JsonArray rows = new JsonArray();
        for (int i = 0; i < history.size(); i++) {
            WeatherLog w = history.get(i);
            JsonObject r = new JsonObject();

            Date d = w.getRecordedAt();
            r.addProperty("RecordedAt", fmt.format(d));

            r.addProperty("Temperature", w.getTemperature() == null ? 0 : w.getTemperature());
            r.addProperty("Humidity", w.getHumidity() == null ? 0 : w.getHumidity());
            r.addProperty("Rainfall", w.getRainfall() == null ? 0 : w.getRainfall());

            rows.add(r);
        }

        payload.add("history", rows);
        return payload;
    }

    /**
     * Transform AI_Engine response -> frontend friendly.
     */
    private JsonObject transformAiResponse(JsonObject ai) {
        JsonObject result = new JsonObject();

        String status = ai.has("status") ? ai.get("status").getAsString() : "success";
        String target = ai.has("target") ? ai.get("target").getAsString() : "Temperature";

        result.addProperty("status", status);
        result.addProperty("target", target);

        if (ai.has("insight")) {
            result.add("insight", ai.get("insight"));
        }

        JsonArray data = new JsonArray();
        if (ai.has("forecast") && ai.get("forecast").isJsonArray()) {
            JsonArray fc = ai.getAsJsonArray("forecast");
            for (int i = 0; i < fc.size(); i++) {
                JsonObject item = fc.get(i).getAsJsonObject();

                JsonObject row = new JsonObject();
                String date = item.has("date") ? item.get("date").getAsString() : "";
                double value = item.has("value") ? item.get("value").getAsDouble() : 0;

                row.addProperty("date", date);
                row.addProperty("value", value);

                // frontend có thể dùng temperature luôn
                row.addProperty("temperature", value);

                data.add(row);
            }
        }

        result.add("data", data);
        return result;
    }

    // =========================
    // Merge DB + Open-Meteo
    // Prefer DB if same date
    // + Densify để đủ requiredDays liên tiếp
    // =========================
    private List<WeatherLog> getMergedHistoryPreferDB(Zone zone, List<WeatherLog> dbHistory, int requiredDays) throws IOException {
        SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");

        // validate lat/lon
        double lat = zone.getLatitude();
        double lon = zone.getLongitude();
        if (Double.isNaN(lat) || Double.isNaN(lon) || Math.abs(lat) < 0.000001 || Math.abs(lon) < 0.000001) {
            return new ArrayList<WeatherLog>();
        }

        // DB -> map theo yyyy-MM-dd (DB ưu tiên)
        Map<String, WeatherLog> mapByDate = new HashMap<String, WeatherLog>();
        for (int i = 0; i < dbHistory.size(); i++) {
            WeatherLog w = dbHistory.get(i);
            if (w == null || w.getRecordedAt() == null) continue;
            String key = fmt.format(w.getRecordedAt());
            mapByDate.put(key, w);
        }

        // range requiredDays kết thúc hôm nay
        Calendar cal = Calendar.getInstance();
        Date end = cal.getTime();
        cal.add(Calendar.DAY_OF_YEAR, -(requiredDays - 1));
        Date start = cal.getTime();

        String startStr = fmt.format(start);
        String endStr = fmt.format(end);

        // Open-Meteo archive
        List<WeatherLog> apiLogs = fetchOpenMeteoDaily(lat, lon, startStr, endStr);

        // merge: chỉ put nếu DB chưa có
        for (int i = 0; i < apiLogs.size(); i++) {
            WeatherLog w = apiLogs.get(i);
            if (w == null || w.getRecordedAt() == null) continue;
            String key = fmt.format(w.getRecordedAt());
            if (!mapByDate.containsKey(key)) {
                mapByDate.put(key, w);
            }
        }

        // DENSIFY: tạo đúng requiredDays record liên tiếp (nếu thiếu -> fill bằng ngày gần nhất trước đó)
        List<WeatherLog> dense = new ArrayList<WeatherLog>(requiredDays);

        Calendar day = Calendar.getInstance();
        day.setTime(start);

        WeatherLog lastKnown = null;

        for (int i = 0; i < requiredDays; i++) {
            Date d = day.getTime();
            String key = fmt.format(d);

            WeatherLog w = mapByDate.get(key);

            if (w == null) {
                w = new WeatherLog();
                w.setRecordedAt(d);

                if (lastKnown != null) {
                    w.setTemperature(lastKnown.getTemperature());
                    w.setHumidity(lastKnown.getHumidity());
                    w.setRainfall(lastKnown.getRainfall());
                } else {
                    w.setTemperature(0.0);
                    w.setHumidity(0.0);
                    w.setRainfall(0.0);
                }
            }

            dense.add(w);
            lastKnown = w;

            day.add(Calendar.DAY_OF_YEAR, 1);
        }

        return dense;
    }

    /**
     * Open-Meteo archive daily:
     * temperature_2m_mean, relative_humidity_2m_mean, precipitation_sum
     */
    private List<WeatherLog> fetchOpenMeteoDaily(double lat, double lon, String startDate, String endDate) throws IOException {
        String url = OPEN_METEO_ARCHIVE
                + "?latitude=" + lat
                + "&longitude=" + lon
                + "&start_date=" + startDate
                + "&end_date=" + endDate
                + "&daily=temperature_2m_mean,relative_humidity_2m_mean,precipitation_sum"
                + "&timezone=UTC";

        String body = httpGet(url);

        // DEBUG nhanh xem Open-Meteo trả gì
        System.out.println("[OPEN_METEO_URL] " + url);
        System.out.println("[OPEN_METEO_BODY_HEAD] " + (body.length() > 200 ? body.substring(0, 200) : body));

        JsonObject json = gson.fromJson(body, JsonObject.class);

        List<WeatherLog> out = new ArrayList<WeatherLog>();
        if (json == null || !json.has("daily")) return out;

        JsonObject daily = json.getAsJsonObject("daily");
        if (!daily.has("time")) return out;

        JsonArray time = daily.getAsJsonArray("time");
        JsonArray tmean = daily.has("temperature_2m_mean") ? daily.getAsJsonArray("temperature_2m_mean") : null;
        JsonArray rhmean = daily.has("relative_humidity_2m_mean") ? daily.getAsJsonArray("relative_humidity_2m_mean") : null;
        JsonArray psum = daily.has("precipitation_sum") ? daily.getAsJsonArray("precipitation_sum") : null;

        SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");

        for (int i = 0; i < time.size(); i++) {
            String dStr = time.get(i).getAsString();
            Date d;
            try {
                d = fmt.parse(dStr);
            } catch (Exception e) {
                continue;
            }

            Double temp = getDoubleAt(tmean, i);
            Double hum = getDoubleAt(rhmean, i);
            Double rain = getDoubleAt(psum, i);

            WeatherLog w = new WeatherLog();
            w.setRecordedAt(d);
            w.setTemperature(temp == null ? 0 : temp);
            w.setHumidity(hum == null ? 0 : hum);
            w.setRainfall(rain == null ? 0 : rain);

            out.add(w);
        }

        return out;
    }

    private Double getDoubleAt(JsonArray arr, int idx) {
        if (arr == null) return null;
        if (idx < 0 || idx >= arr.size()) return null;
        JsonElement e = arr.get(idx);
        if (e == null || e.isJsonNull()) return null;
        try {
            return e.getAsDouble();
        } catch (Exception ex) {
            return null;
        }
    }

    // =========================
    // HTTP helpers
    // =========================
    private JsonObject httpPostJson(String urlStr, JsonObject payload) throws IOException {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(60000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

        byte[] input = gson.toJson(payload).getBytes(Charset.forName("UTF-8"));
        OutputStream os = conn.getOutputStream();
        os.write(input);
        os.flush();
        os.close();

        int status = conn.getResponseCode();
        if (status != 200) {
            String err = readStream(conn.getErrorStream());
            throw new IOException("HTTP " + status + " - " + err);
        }

        String body = readStream(conn.getInputStream());
        return gson.fromJson(body, JsonObject.class);
    }

    private String httpGet(String urlStr) throws IOException {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(60000);

        int status = conn.getResponseCode();
        if (status != 200) {
            String err = readStream(conn.getErrorStream());
            throw new IOException("Open-Meteo HTTP " + status + " - " + err);
        }

        return readStream(conn.getInputStream());
    }

    private String readStream(InputStream is) throws IOException {
        if (is == null) return "";
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) sb.append(line);
        reader.close();
        return sb.toString();
    }

    // =========================
    // Save AI forecast -> Forecasts table
    // =========================
    private void saveForecastsToDb(int zoneId, JsonObject transformed) throws Exception {
        if (transformed == null) return;
        if (!transformed.has("data") || !transformed.get("data").isJsonArray()) return;

        JsonArray arr = transformed.getAsJsonArray("data");
        if (arr.size() == 0) return;

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        for (int i = 0; i < arr.size(); i++) {
            JsonObject row = arr.get(i).getAsJsonObject();
            if (!row.has("date")) continue;

            String dateStr = row.get("date").getAsString();
            if (dateStr == null || dateStr.trim().isEmpty()) continue;

            java.util.Date d = sdf.parse(dateStr);
            java.sql.Date sqlDate = new java.sql.Date(d.getTime());

            Double temp = null;
            if (row.has("temperature")) {
                try { temp = row.get("temperature").getAsDouble(); } catch (Exception ignore) {}
            } else if (row.has("value")) {
                try { temp = row.get("value").getAsDouble(); } catch (Exception ignore) {}
            }

            forecastDAO.upsertTemperature(zoneId, sqlDate, temp);
        }
    }

}
