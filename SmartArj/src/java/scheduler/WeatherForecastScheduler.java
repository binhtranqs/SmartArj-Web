package scheduler;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.WeatherLogDAO;
import dao.ZoneDAO;
import model.WeatherLog;
import model.Zone;
import service.WeatherSeedService;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.ConnectException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

@WebListener
public class WeatherForecastScheduler implements ServletContextListener {

    private static final Logger logger = Logger.getLogger(WeatherForecastScheduler.class.getName());

    private static final String AI_URL = "http://localhost:8001/predict-city";
    private static final Map<Integer, String> CITY_FOLDER_MAP;
    
    static {
        CITY_FOLDER_MAP = new HashMap<>();
        CITY_FOLDER_MAP.put(11, "cantho");
        CITY_FOLDER_MAP.put(14, "daklak");
        CITY_FOLDER_MAP.put(12, "dalat");
        CITY_FOLDER_MAP.put(13, "danang");
        CITY_FOLDER_MAP.put(15, "hanoi");
        CITY_FOLDER_MAP.put(17, "hcm");
    }

    private ScheduledExecutorService scheduler;
    private final ZoneDAO zoneDAO = new ZoneDAO();
    private final WeatherSeedService weatherSeedService = new WeatherSeedService();
    private final WeatherLogDAO weatherLogDAO = new WeatherLogDAO();
    private final Gson gson = new Gson();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "WeatherForecastSchedulerThread");
            t.setDaemon(true);
            return t;
        });

        // Test running 30 seconds after startup for debugging
        logger.info("[WeatherForecastScheduler] Scheduling immediate background forecast update in 30s...");
        scheduler.schedule(this::runWeatherForecastTask, 30, TimeUnit.SECONDS);

        // Schedule daily at 2:00 AM
        int targetHour = 2;
        int targetMinute = 0;
        long initialDelayMinutes = minutesUntilNextRun(targetHour, targetMinute);

        scheduler.scheduleAtFixedRate(
                this::runWeatherForecastTask,
                initialDelayMinutes,
                24 * 60,
                TimeUnit.MINUTES
        );

        logger.info("[WeatherForecastScheduler] Scheduled daily at " + targetHour + ":00 AM. Next run in " + initialDelayMinutes + " minutes.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            logger.info("[WeatherForecastScheduler] Shutdown complete");
        }
    }

    private long minutesUntilNextRun(int targetHour, int targetMinute) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime next = now.withHour(targetHour).withMinute(targetMinute).withSecond(0).withNano(0);
        if (!now.isBefore(next)) {
            next = next.plusDays(1);
        }
        return ChronoUnit.MINUTES.between(now, next);
    }

    private void runWeatherForecastTask() {
        try {
            logger.info("[WeatherForecastScheduler] Starting daily weather seed and forecast generation...");
            List<Zone> zones = zoneDAO.findAll();
            
            for (Zone zone : zones) {
                // 1. Auto-seed weather history if needed
                try {
                    Double lat = zone.getLatitude();
                    Double lon = zone.getLongitude();
                    if (lat != null && lon != null && lat != 0 && lon != 0) {
                        weatherSeedService.seedIfNeeded(zone.getZoneId(), lat, lon, 7); // update last 7 days
                    }
                } catch (Exception e) {
                    logger.warning("[WeatherForecastScheduler] Failed to seed weather for Zone " + zone.getZoneId() + ": " + e.getMessage());
                }

                // 2. Generate 7-day forecast via AI Pipeline
                String cityFolder = CITY_FOLDER_MAP.get(zone.getCityId());
                if (cityFolder != null) {
                    try {
                        List<WeatherLog> history = weatherLogDAO.findLatestByZone(zone.getZoneId(), 90);
                        if (!history.isEmpty()) {
                            JsonArray historyArr = buildHistoryJson(history);
                            
                            // Trigger AI for Temperature
                            callAI("Temperature", historyArr, cityFolder);
                            
                            // Trigger AI for Humidity
                            callAI("Humidity", historyArr, cityFolder);
                            
                            logger.info("[WeatherForecastScheduler] Forecast generated and saved for city: " + cityFolder + " (Zone " + zone.getZoneId() + ")");
                        } else {
                            logger.warning("[WeatherForecastScheduler] No history data found to forecast for Zone " + zone.getZoneId());
                        }
                    } catch (ConnectException ce) {
                        logger.warning("[WeatherForecastScheduler] AI Engine is unavailable at " + AI_URL);
                    } catch (Exception e) {
                        logger.warning("[WeatherForecastScheduler] Failed to generate forecast for Zone " + zone.getZoneId() + ": " + e.getMessage());
                    }
                } else {
                    logger.info("[WeatherForecastScheduler] Zone " + zone.getZoneId() + " (CityID " + zone.getCityId() + ") bypassed. No AI model mapping available.");
                }
            }
            logger.info("[WeatherForecastScheduler] Finished daily weather seed and forecast generation.");
        } catch (Exception e) {
            logger.severe("[WeatherForecastScheduler] Critical error in forecast scheduler: " + e.getMessage());
        }
    }

    private JsonArray buildHistoryJson(List<WeatherLog> history) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        JsonArray historyArr = new JsonArray();
        for (WeatherLog log : history) {
            JsonObject h = new JsonObject();
            h.addProperty("RecordedAt", sdf.format(log.getRecordedAt()));
            h.addProperty("Temperature", log.getTemperature() != null ? log.getTemperature() : 28.0);
            h.addProperty("Humidity", log.getHumidity() != null ? log.getHumidity() : 70.0);
            h.addProperty("Rainfall", log.getRainfall() != null ? log.getRainfall() : 0.0);
            historyArr.add(h);
        }
        return historyArr;
    }

    private void callAI(String target, JsonArray historyArr, String cityFolder) throws IOException {
        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("target", target);
        requestBody.addProperty("city", cityFolder);
        requestBody.add("history", historyArr);

        String requestJson = gson.toJson(requestBody);

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
        if (status >= 400) {
            InputStream is = conn.getErrorStream();
            throw new IOException("AI Server Error " + status + " for " + target + " - " + readStream(is));
        }
        
        InputStream is = conn.getInputStream();
        readStream(is); // Consume the response stream
    }

    private String readStream(InputStream is) throws IOException {
        if (is == null) return "";
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) sb.append(line);
        reader.close();
        return sb.toString();
    }
}
