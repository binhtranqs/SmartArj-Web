package service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import util.JPAUtil;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * Alert rules:
 * 1) Heat streak: daily max temperature > 30C for N consecutive days (history +
 * forecast)
 * 2) Rain streak: daily rainfall >= threshold for 7 consecutive days (history)
 * 3) Crop min/max violation (current + forecast)
 *
 * Dedup policy: ONE alert per (zone + dedupKey) per CALENDAR DAY.
 * DedupKey is embedded at the beginning of Message as "DEDUP=<key>; ..."
 * so it can be matched via LIKE without changing the schema.
 *
 * SQL Server LIKE special characters ([ ] % _) are escaped before matching.
 */
public class AlertService {

    // ===== Rule tuning =====
    private static final double HEAT_TEMP_C = 30.0;
    private static final int HEAT_STREAK_DAYS = 3;

    private static final int RAIN_STREAK_DAYS = 7;
    private static final double RAIN_THRESHOLD_MM = 0.1;

    // How many days of history to fetch for streak detection
    private static final int HISTORY_LOOKBACK_DAYS = 21;

    // How many forecast days ahead to evaluate
    private static final int FORECAST_LOOKAHEAD_DAYS = 14;

    /**
     * Kiểm tra và tạo cảnh báo cho tất cả Zones
     */
    public void checkAndGenerateAlerts() {
        EntityManager em = null;
        try {
            em = JPAUtil.getEntityManager();

            List<Integer> zoneIds = em.createQuery(
                    "SELECT z.zoneId FROM Zone z", Integer.class).getResultList();

            for (Integer zoneId : zoneIds) {
                if (zoneId != null)
                    checkZoneAlert(zoneId.intValue());
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (em != null)
                em.close();
        }
    }

    private void checkZoneAlert(int zoneId) {
        EntityManager em = null;
        try {
            em = JPAUtil.getEntityManager();

            // ===== 0) thresholds by crop =====
            // Returns [CropID, CropName, MinTemp, MaxTemp]
            List<Object[]> crops = getCropsByZone(em, zoneId);
            if (crops == null || crops.isEmpty())
                return;

            // ===== 1) Latest weather (current violations) =====
            Object[] latest = getLatestWeatherRow(em, zoneId);
            if (latest != null) {
                double temp = latest[0] == null ? 0.0 : ((Number) latest[0]).doubleValue();

                for (Object[] c : crops) {
                    int cropId = c[0] == null ? 0 : ((Number) c[0]).intValue();
                    String cropName = (String) c[1];
                    double minTemp = c[2] == null ? Double.NEGATIVE_INFINITY : ((Number) c[2]).doubleValue();
                    double maxTemp = c[3] == null ? Double.POSITIVE_INFINITY : ((Number) c[3]).doubleValue();

                    if (temp > maxTemp) {
                        String dedupKey = "CROP_MAX|" + cropId;
                        String message = "[CROP_MAX] " + cropName
                                + ": Nhiệt độ quá cao (" + round1(temp) + "°C) > Max " + round1(maxTemp) + "°C";
                        createAlertDedup(em, zoneId, message, dedupKey);

                    } else if (temp < minTemp) {
                        String dedupKey = "CROP_MIN|" + cropId;
                        String message = "[CROP_MIN] " + cropName
                                + ": Nhiệt độ quá thấp (" + round1(temp) + "°C) < Min " + round1(minTemp) + "°C";
                        createAlertDedup(em, zoneId, message, dedupKey);
                    }
                }
            }

            // ===== 2) Heat streak (history) =====
            List<DailyRow> history = getDailyHistory(em, zoneId, HISTORY_LOOKBACK_DAYS);
            if (history != null && !history.isEmpty()) {
                int heatStreak = longestStreak(history, "heat");
                if (heatStreak >= HEAT_STREAK_DAYS) {
                    createAlertDedup(em, zoneId,
                            "[HEAT] Nắng nóng > " + round1(HEAT_TEMP_C) + "°C kéo dài " + heatStreak
                                    + " ngày (theo lịch sử)",
                            "HEAT|" + zoneId);
                }

                int rainStreak = longestStreak(history, "rain");
                if (rainStreak >= RAIN_STREAK_DAYS) {
                    createAlertDedup(em, zoneId,
                            "[RAIN] Mưa liên tục " + rainStreak + " ngày (>= " + round1(RAIN_THRESHOLD_MM) + "mm/ngày)",
                            "RAIN|" + zoneId);
                }
            }

            // ===== 3) Forecast-based alerts (Temperature only) =====
            List<DailyRow> fc = getForecastDaily(em, zoneId, FORECAST_LOOKAHEAD_DAYS);
            if (fc != null && !fc.isEmpty()) {
                int heatStreakFc = longestStreak(fc, "heat");
                if (heatStreakFc >= HEAT_STREAK_DAYS) {
                    Date start = streakStartDate(fc, "heat", HEAT_STREAK_DAYS);
                    String when = (start != null) ? (" từ " + start.toString()) : "";
                    createAlertDedup(em, zoneId,
                            "[HEAT_FORECAST] Dự báo nắng nóng > " + round1(HEAT_TEMP_C) + "°C kéo dài " + heatStreakFc
                                    + " ngày" + when,
                            "HEAT_FORECAST|" + zoneId);
                }

                // Crop threshold violations in forecast
                for (Object[] c : crops) {
                    int cropId = c[0] == null ? 0 : ((Number) c[0]).intValue();
                    String cropName = (String) c[1];
                    double minTemp = c[2] == null ? Double.NEGATIVE_INFINITY : ((Number) c[2]).doubleValue();
                    double maxTemp = c[3] == null ? Double.POSITIVE_INFINITY : ((Number) c[3]).doubleValue();

                    DailyRow maxRow = findFirst(fc, "gt", maxTemp);
                    if (maxRow != null) {
                        createAlertDedup(em, zoneId,
                                "[CROP_MAX_FORECAST] " + cropName + ": Dự báo vượt Max " + round1(maxTemp) + "°C vào "
                                        + maxRow.date
                                        + " (" + round1(maxRow.tempMax) + "°C)",
                                "CROP_MAX_FORECAST|" + cropId);
                    }

                    DailyRow minRow = findFirst(fc, "lt", minTemp);
                    if (minRow != null) {
                        createAlertDedup(em, zoneId,
                                "[CROP_MIN_FORECAST] " + cropName + ": Dự báo dưới Min " + round1(minTemp) + "°C vào "
                                        + minRow.date
                                        + " (" + round1(minRow.tempMax) + "°C)",
                                "CROP_MIN_FORECAST|" + cropId);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (em != null)
                em.close();
        }
    }

    // =========================
    // Queries
    // =========================

    /**
     * Returns: [Temperature, Humidity, RecordedAt] or null
     */
    private Object[] getLatestWeatherRow(EntityManager em, int zoneId) {
        String sql = "SELECT Temperature, Humidity, RecordedAt " +
                "FROM WeatherLogs WHERE ZoneID = ? ORDER BY RecordedAt DESC LIMIT 1";

        Query q = em.createNativeQuery(sql);
        q.setParameter(1, zoneId);

        @SuppressWarnings("unchecked")
        List<Object[]> rows = q.getResultList();
        if (rows == null || rows.isEmpty())
            return null;
        return rows.get(0);
    }

    /**
     * Returns list of [CropID, CropName, MinTemp, MaxTemp].
     * CropID is included so dedupKey can be stable and ID-based.
     */
    private List<Object[]> getCropsByZone(EntityManager em, int zoneId) {
        String sql = "SELECT CropID, CropName, MinTemp, MaxTemp FROM Crops WHERE ZoneID = ?";
        Query q = em.createNativeQuery(sql);
        q.setParameter(1, zoneId);

        @SuppressWarnings("unchecked")
        List<Object[]> rows = q.getResultList();
        return rows;
    }

    /**
     * Daily aggregation from WeatherLogs for streak detection.
     */
    private List<DailyRow> getDailyHistory(EntityManager em, int zoneId, int lookbackDays) {
        String sql = "SELECT CAST(RecordedAt AS date) AS d, " +
                "MAX(Temperature) AS tmax, " +
                "SUM(COALESCE(Rainfall,0)) AS rain " +
                "FROM WeatherLogs " +
                "WHERE ZoneID = ? AND RecordedAt >= (CURRENT_TIMESTAMP - (? * INTERVAL '1 day')) " +
                "GROUP BY CAST(RecordedAt AS date) " +
                "ORDER BY d";

        Query q = em.createNativeQuery(sql);
        q.setParameter(1, zoneId);
        q.setParameter(2, lookbackDays);

        @SuppressWarnings("unchecked")
        List<Object[]> rows = q.getResultList();

        List<DailyRow> out = new ArrayList<DailyRow>();
        if (rows == null)
            return out;

        for (Object[] r : rows) {
            Date d = (Date) r[0];
            double tmax = r[1] == null ? Double.NaN : ((Number) r[1]).doubleValue();
            double rain = r[2] == null ? 0.0 : ((Number) r[2]).doubleValue();
            out.add(new DailyRow(d, tmax, rain));
        }
        return out;
    }

    /**
     * Forecast daily from Forecasts table (Temperature only).
     */
    private List<DailyRow> getForecastDaily(EntityManager em, int zoneId, int lookaheadDays) {
        String sql = "SELECT ForecastDate, Temperature " +
                "FROM Forecasts " +
                "WHERE ZoneID = ? " +
                "AND ForecastDate >= CURRENT_DATE " +
                "AND ForecastDate <= CURRENT_DATE + (? * INTERVAL '1 day') " +
                "ORDER BY ForecastDate";

        Query q = em.createNativeQuery(sql);
        q.setParameter(1, zoneId);
        q.setParameter(2, lookaheadDays);

        @SuppressWarnings("unchecked")
        List<Object[]> rows = q.getResultList();

        List<DailyRow> out = new ArrayList<DailyRow>();
        if (rows == null)
            return out;

        for (Object[] r : rows) {
            Date d = (Date) r[0];
            double t = r[1] == null ? Double.NaN : ((Number) r[1]).doubleValue();
            out.add(new DailyRow(d, t, 0.0));
        }
        return out;
    }

    // =========================
    // Alert insert + dedup
    // =========================

    /**
     * Tạo alert nếu chưa có alert cùng dedupKey trong ngày hôm nay (calendar day).
     * Message được lưu với prefix "DEDUP=<key>; " để LIKE matching.
     *
     * @param em       EntityManager (đang mở, không gọi close ở đây)
     * @param zoneId   ID của zone
     * @param message  Nội dung alert hiển thị cho user
     * @param dedupKey Key ổn định, không chứa ký tự đặc biệt LIKE (vd:
     *                 "CROP_MAX|42")
     */
    private void createAlertDedup(EntityManager em, int zoneId, String message, String dedupKey) {
        if (existsAlertToday(em, zoneId, dedupKey))
            return;

        // Embed dedupKey vào đầu message để query LIKE về sau
        String fullMessage = "DEDUP=" + dedupKey + "; " + message;

        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            String sql = "INSERT INTO Alerts (ZoneID, Message, AlertTime, IsRead) VALUES (?, ?, CURRENT_TIMESTAMP, 0)";
            Query q = em.createNativeQuery(sql);
            q.setParameter(1, zoneId);
            q.setParameter(2, fullMessage);
            q.executeUpdate();
            tx.commit();

            System.out.println("⚠️ New Alert Zone=" + zoneId + " key=" + dedupKey + " | " + message);

        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            e.printStackTrace();
        }
    }

    /**
     * Kiểm tra xem ngày HÔM NAY đã có alert với dedupKey này chưa.
     * "Hôm nay" = từ 00:00:00 server time đến hiện tại (calendar day).
     *
     * Sử dụng SQL Server idiom: DATEADD(day, DATEDIFF(day, 0, CURRENT_TIMESTAMP), 0)
     * = start of today (midnight) theo server timezone.
     *
     * LIKE pattern được escape để tránh SQL Server interpret [ ] % _ đặc biệt.
     */
    private boolean existsAlertToday(EntityManager em, int zoneId, String dedupKey) {
        // Escape SQL Server LIKE special chars trước khi dùng trong LIKE pattern
        String escapedKey = escapeLikeSqlServer("DEDUP=" + dedupKey + ";");
        String likePattern = escapedKey + "%";

        String sql = "SELECT COUNT(*) FROM Alerts " +
                "WHERE ZoneID = ? " +
                "AND Message LIKE ? ESCAPE '\\' " +
                "AND AlertTime >= CURRENT_DATE";

        Query q = em.createNativeQuery(sql);
        q.setParameter(1, zoneId);
        q.setParameter(2, likePattern);

        Object o = q.getSingleResult();
        long n = (o == null) ? 0 : ((Number) o).longValue();
        return n > 0;
    }

    /**
     * Escape ký tự đặc biệt trong SQL Server LIKE pattern.
     * SQL Server dùng [ ] % _ làm wildcard.
     * Ta dùng ESCAPE '\' và wrap bằng [...] cho từng ký tự đặc biệt.
     *
     * Thứ tự quan trọng: escape '[' trước để không double-escape.
     */
    private static String escapeLikeSqlServer(String s) {
        if (s == null)
            return "";
        return s
                .replace("[", "[[]") // phải escape trước
                .replace("]", "[]]")
                .replace("%", "[%]")
                .replace("_", "[_]");
    }

    // =========================
    // Streak logic
    // =========================

    private int longestStreak(List<DailyRow> rows, String kind) {
        if (rows == null || rows.isEmpty())
            return 0;

        int best = 0;
        int currentStreak = 0;
        Date prev = null;

        for (int i = 0; i < rows.size(); i++) {
            DailyRow r = rows.get(i);

            boolean ok = false;
            if ("heat".equals(kind)) {
                ok = !Double.isNaN(r.tempMax) && r.tempMax > HEAT_TEMP_C;
            } else if ("rain".equals(kind)) {
                ok = r.rain >= RAIN_THRESHOLD_MM;
            }

            boolean consecutive = true;
            if (prev != null) {
                consecutive = isNextDay(prev, r.date);
            }

            if (ok && consecutive) {
                currentStreak++;
            } else if (ok) { // ok but gap → restart
                currentStreak = 1;
            } else {
                currentStreak = 0;
            }

            if (currentStreak > best)
                best = currentStreak;
            prev = r.date;
        }
        return best;
    }

    private Date streakStartDate(List<DailyRow> rows, String kind, int minDays) {
        if (rows == null || rows.isEmpty())
            return null;

        int currentStreak = 0;
        Date prev = null;
        for (int i = 0; i < rows.size(); i++) {
            DailyRow r = rows.get(i);

            boolean ok = false;
            if ("heat".equals(kind)) {
                ok = !Double.isNaN(r.tempMax) && r.tempMax > HEAT_TEMP_C;
            } else if ("rain".equals(kind)) {
                ok = r.rain >= RAIN_THRESHOLD_MM;
            }

            boolean consecutive = true;
            if (prev != null)
                consecutive = isNextDay(prev, r.date);

            if (ok && consecutive) {
                currentStreak++;
            } else if (ok) {
                currentStreak = 1;
            } else {
                currentStreak = 0;
            }

            if (currentStreak >= minDays) {
                int startIdx = i - currentStreak + 1;
                return rows.get(startIdx).date;
            }
            prev = r.date;
        }
        return null;
    }

    private boolean isNextDay(Date prev, Date next) {
        Calendar c = Calendar.getInstance();
        c.setTime(prev);
        c.add(Calendar.DAY_OF_MONTH, 1);
        Date expected = new Date(c.getTimeInMillis());
        return expected.equals(next);
    }

    private DailyRow findFirst(List<DailyRow> rows, String op, double threshold) {
        if (rows == null)
            return null;
        for (int i = 0; i < rows.size(); i++) {
            DailyRow r = rows.get(i);
            if (Double.isNaN(r.tempMax))
                continue;
            if ("gt".equals(op) && r.tempMax > threshold)
                return r;
            if ("lt".equals(op) && r.tempMax < threshold)
                return r;
        }
        return null;
    }

    private double round1(double v) {
        return Math.round(v * 10.0) / 10.0;
    }

    private static class DailyRow {
        public Date date;
        public double tempMax;
        public double rain;

        public DailyRow(Date date, double tempMax, double rain) {
            this.date = date;
            this.tempMax = tempMax;
            this.rain = rain;
        }
    }
}
