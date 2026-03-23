package crawler;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * Scheduler tự động chạy crawler mỗi ngày lúc 7:00 sáng
 * Implements ServletContextListener → tự động start khi deploy app
 */
@WebListener
public class CrawlerScheduler implements ServletContextListener {

    private static final Logger logger = Logger.getLogger(CrawlerScheduler.class.getName());

    /** Giờ muốn crawler chạy (7 = 7:00 AM) */
    private static final int CRAWL_HOUR   = 7;
    private static final int CRAWL_MINUTE = 0;

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "MarketPriceCrawlerThread");
            t.setDaemon(true);
            return t;
        });

        // ── Kiểm tra: nếu hôm nay chưa có data → crawl ngay sau 30 giây ──
        boolean hasTodayData = checkTodayDataExists();
        if (!hasTodayData) {
            logger.info("[CrawlerScheduler] No data for today. Scheduling immediate crawl in 30s...");
            scheduler.schedule(this::runCrawler, 30, TimeUnit.SECONDS);
        }

        // ── Lịch crawl cố định 7:00 AM mỗi ngày ──
        long initialDelayMinutes = minutesUntilNextRun(CRAWL_HOUR, CRAWL_MINUTE);

        // 24 * 60 phút = mỗi ngày 1 lần
        scheduler.scheduleAtFixedRate(
                this::runCrawler,
                initialDelayMinutes,
                24 * 60,
                TimeUnit.MINUTES
        );

        LocalDateTime nextRun = LocalDateTime.now()
                .plusMinutes(initialDelayMinutes)
                .truncatedTo(ChronoUnit.MINUTES);

        logger.info("[CrawlerScheduler] Scheduled daily at " + CRAWL_HOUR + ":00 AM. "
                + "Next run: " + nextRun
                + " (in " + initialDelayMinutes + " minutes). "
                + "Has today data: " + hasTodayData);

    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            logger.info("[CrawlerScheduler] Shutdown complete");
        }
    }

    /**
     * Tính số phút từ bây giờ đến lần chạy tiếp theo (targetHour:targetMinute)
     * Nếu giờ đó hôm nay đã qua → tính sang ngày mai
     */
    private long minutesUntilNextRun(int targetHour, int targetMinute) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime next = now
                .withHour(targetHour)
                .withMinute(targetMinute)
                .withSecond(0)
                .withNano(0);

        // Nếu thời điểm hôm nay đã qua → chạy ngày mai
        if (!now.isBefore(next)) {
            next = next.plusDays(1);
        }

        return ChronoUnit.MINUTES.between(now, next);
    }

    /**
     * Chạy crawler (gọi bởi scheduler)
     */
    private void runCrawler() {
        try {
            logger.info("[CrawlerScheduler] Running scheduled crawl at " + LocalDateTime.now());
            CrawlerService service = new CrawlerService();
            CrawlerService.CrawlerResult result = service.runCrawl();
            logger.info("[CrawlerScheduler] Done: status=" + result.getStatus()
                    + ", items=" + result.getItemsCrawled()
                    + ", duration=" + result.getDurationMs() + "ms");
        } catch (Exception e) {
            logger.severe("[CrawlerScheduler] Error: " + e.getMessage());
        }
    }

    /**
     * Trigger crawl thủ công từ Admin panel
     */
    public static CrawlerService.CrawlerResult triggerManualCrawl() {
        CrawlerService service = new CrawlerService();
        return service.runCrawl();
    }

    /**
     * Kiểm tra hôm nay đã có data chưa (để tránh crawl thừa khi restart server)
     */
    private boolean checkTodayDataExists() {
        String sql = "SELECT COUNT(*) FROM MarketPrices WHERE CAST(CrawledAt AS DATE) = CURRENT_DATE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            logger.warning("[CrawlerScheduler] Cannot check today data: " + e.getMessage());
        }
        return false; // Nếu lỗi DB → crawl để an toàn
    }
}
