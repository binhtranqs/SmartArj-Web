package service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import dto.SeedResult;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import model.Zone;
import model.WeatherLog;
import util.JPAUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;

/**
 * ✅ Single source of truth cho tất cả logic seed WeatherLog từ Open-Meteo.
 *
 * Hai servlet (ZoneServlet và SeedWeatherServlet) chỉ gọi vào đây.
 * ForecastServlet giữ logic fetch riêng vì không lưu DB (chỉ để build AI
 * payload).
 */
public class WeatherSeedService {

    private static final String OPEN_METEO_API = "https://api.open-meteo.com/v1/forecast";
    private static final Gson GSON = new Gson();

    // =====================================================================
    // Public API
    // =====================================================================

    /**
     * Seed WeatherLog cho zone trong khoảng [start, end].
     * Fine-grained dedup: chỉ skip ngày đã tồn tại, không skip cả block.
     *
     * @param zoneId ID của zone
     * @param lat    Latitude (phải hợp lệ)
     * @param lon    Longitude (phải hợp lệ)
     * @param start  Ngày bắt đầu (inclusive)
     * @param end    Ngày kết thúc (inclusive)
     * @return SeedResult chứa inserted/skipped/failed counts
     * @throws IOException nếu Open-Meteo API lỗi mạng
     */
    public SeedResult seedRange(int zoneId, double lat, double lon, LocalDate start, LocalDate end) throws IOException {
       SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
fmt.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));

        Date startDate = toDate(start);
        Date endDate = toDate(end);
        String startStr = fmt.format(startDate);
        String endStr = fmt.format(endDate);

        int requested = (int) (end.toEpochDay() - start.toEpochDay() + 1);

        // 1) Fetch từ Open-Meteo
        List<WeatherLog> apiLogs = fetchOpenMeteoDaily(lat, lon, startStr, endStr);
        if (apiLogs == null || apiLogs.isEmpty()) {
            return new SeedResult(requested, 0, 0, 0, "Open-Meteo returned no data for the given range/coordinates.");
        }

        // 2) Fine-grained dedup: lấy set ngày đã có trong DB
        EntityManager em = JPAUtil.getEntityManager();
        int inserted = 0;
        int skipped = 0;
        int failed = 0;

        try {
            Set<String> existingKeys = getExistingDateKeys(em, zoneId, startDate, endDate, fmt);

            em.getTransaction().begin();

            for (WeatherLog w : apiLogs) {
                if (w == null || w.getRecordedAt() == null)
                    continue;

                String key = fmt.format(w.getRecordedAt());

                if (existingKeys.contains(key)) {
                    skipped++;
                    continue;
                }

                try {
                    w.setZone(em.getReference(Zone.class, zoneId));
                    em.persist(w);
                    existingKeys.add(key); // cập nhật để tránh duplicate trong cùng 1 batch
                    inserted++;
                } catch (Exception e) {
                    System.err.println("[WeatherSeedService] Failed to persist " + key + ": " + e.getMessage());
                    failed++;
                }
            }

            em.getTransaction().commit();

        } catch (Exception ex) {
            if (em.getTransaction().isActive())
                em.getTransaction().rollback();
            throw new IOException("DB persist error: " + ex.getMessage(), ex);
        } finally {
            em.close();
        }

        System.out.printf("[WeatherSeedService] zoneId=%d range=%s→%s inserted=%d skipped=%d failed=%d%n",
                zoneId, startStr, endStr, inserted, skipped, failed);

        return new SeedResult(requested, inserted, skipped, failed, null);
    }

    /**
     * Seed các ngày [today - (daysBack-1), today].
     * Dùng cho auto-seed sau khi tạo zone mới.
     *
     * @param zoneId   ID của zone
     * @param lat      Latitude
     * @param lon      Longitude
     * @param daysBack Số ngày lịch sử cần lấy (ví dụ 372)
     * @return SeedResult
     * @throws IOException nếu lỗi mạng
     */
    public SeedResult seedIfNeeded(int zoneId, double lat, double lon, int daysBack) throws IOException {
        if (daysBack < 1)
            daysBack = 1;
      if (daysBack > 372)
         daysBack = 372;

        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(daysBack - 1);

        return seedRange(zoneId, lat, lon, start, end);
    }

    // =====================================================================
    // Private helpers
    // =====================================================================

    /**
     * Lấy tập hợp các ngày (yyyy-MM-dd) đã có WeatherLog trong DB cho zone.
     */
    private Set<String> getExistingDateKeys(EntityManager em, int zoneId,
            Date start, Date end,
            SimpleDateFormat fmt) {
        TypedQuery<WeatherLog> q = em.createQuery(
                "SELECT w FROM WeatherLog w JOIN w.zone z " +
                        "WHERE z.zoneId = :zid AND w.recordedAt >= :start AND w.recordedAt <= :end",
                WeatherLog.class);
        q.setParameter("zid", zoneId);
        q.setParameter("start", start);
        q.setParameter("end", end);

        List<WeatherLog> rows = q.getResultList();
        Set<String> keys = new HashSet<>();
        for (WeatherLog w : rows) {
            if (w.getRecordedAt() != null) {
                keys.add(fmt.format(w.getRecordedAt()));
            }
        }
        return keys;
    }

    /**
     * Gọi Open-Meteo archive API và parse kết quả thành list WeatherLog.
     * Các field: temperature_2m_mean, relative_humidity_2m_mean,
     * precipitation_sum, wind_speed_10m_mean (m/s → km/h),
     * shortwave_radiation_sum (MJ/m²)
     */
    private List<WeatherLog> fetchOpenMeteoDaily(double lat, double lon,
            String startDate, String endDate) throws IOException {
        String url = OPEN_METEO_API
                + "?latitude=" + lat
                + "&longitude=" + lon
                + "&start_date=" + startDate
                + "&end_date=" + endDate
                + "&daily=temperature_2m_mean,relative_humidity_2m_mean,precipitation_sum,wind_speed_10m_mean,shortwave_radiation_sum"
                + "&timezone=Asia/Ho_Chi_Minh";

        System.out.println("[WeatherSeedService] Fetching: " + url);

        String body = httpGet(url);
        JsonObject json = GSON.fromJson(body, JsonObject.class);

        List<WeatherLog> out = new ArrayList<>();
        if (json == null || !json.has("daily"))
            return out;

        JsonObject daily = json.getAsJsonObject("daily");
        if (!daily.has("time"))
            return out;

        JsonArray time = daily.getAsJsonArray("time");
        JsonArray tmean = jsonArray(daily, "temperature_2m_mean");
        JsonArray rhmean = jsonArray(daily, "relative_humidity_2m_mean");
        JsonArray psum = jsonArray(daily, "precipitation_sum");
        JsonArray windArr = jsonArray(daily, "wind_speed_10m_mean");
        JsonArray radArr = jsonArray(daily, "shortwave_radiation_sum");

       SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
         fmt.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));

        for (int i = 0; i < time.size(); i++) {
            String dStr = time.get(i).getAsString();
            Date d;
            try {
                d = fmt.parse(dStr);
            } catch (Exception e) {
                continue;
            }

            Double temp = doubleAt(tmean, i);
            Double hum = doubleAt(rhmean, i);
            Double rain = doubleAt(psum, i);
            Double windMs = doubleAt(windArr, i); // m/s
            Double radMj = doubleAt(radArr, i); // MJ/m²
            Double windKmh = (windMs == null) ? null : windMs * 3.6;

            WeatherLog w = new WeatherLog();
            w.setRecordedAt(d);
            w.setTemperature(temp == null ? 0.0 : temp);
            w.setHumidity(hum == null ? 0.0 : hum);
            w.setRainfall(rain == null ? 0.0 : rain);
            w.setWind(windKmh == null ? 0.0 : windKmh);
            w.setRadiation(radMj == null ? 0.0 : radMj);

            out.add(w);
        }

        return out;
    }

    /** Null-safe JSON array getter */
    private JsonArray jsonArray(JsonObject obj, String key) {
        return obj.has(key) ? obj.getAsJsonArray(key) : null;
    }

    /** Null-safe double extractor từ một JsonArray tại index idx */
    private Double doubleAt(JsonArray arr, int idx) {
        if (arr == null || idx < 0 || idx >= arr.size())
            return null;
        JsonElement e = arr.get(idx);
        if (e == null || e.isJsonNull())
            return null;
        try {
            return e.getAsDouble();
        } catch (Exception ex) {
            return null;
        }
    }

    /** HTTP GET, trả về body dạng String */
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

    /** Đọc InputStream thành String (UTF-8) */
    private String readStream(InputStream is) throws IOException {
        if (is == null)
            return "";
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null)
            sb.append(line);
        reader.close();
        return sb.toString();
    }

    private Date toDate(LocalDate ld) {
    return Date.from(ld.atStartOfDay(ZoneId.of("Asia/Ho_Chi_Minh")).toInstant());
}
}