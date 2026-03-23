package crawler;

import marketplace.dao.MarketPriceDAO;
import marketplace.model.MarketPrice;
import system.events.EventPublisher;
import system.events.types.CrawlerFinishedEvent;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Logger;

/**
 * Service xử lý việc lưu kết quả crawler vào database
 */
public class CrawlerService {

    private static final Logger logger = Logger.getLogger(CrawlerService.class.getName());

    private final MarketPriceCrawler crawler = new MarketPriceCrawler();
    private final MarketPriceDAO marketPriceDAO = new MarketPriceDAO();

    /**
     * Chạy toàn bộ quy trình crawl + save
     * 
     * @return CrawlerResult chứa thông tin kết quả
     */
    public CrawlerResult runCrawl() {
        long startTime = System.currentTimeMillis();
        CrawlerResult result = new CrawlerResult();

        try {
            logger.info("[CrawlerService] Starting market price crawl at " + LocalDateTime.now());

            // 1. Crawl
            List<MarketPrice> prices = crawler.crawl();
            result.setItemsCrawled(prices.size());

            if (!prices.isEmpty()) {
                // 2a. Xóa data hôm nay trước (tránh trùng lặp khi crawl nhiều lần trong ngày)
                int deleted = marketPriceDAO.deleteTodayPrices();
                logger.info("[CrawlerService] Deleted " + deleted + " old prices for today before re-inserting");

                // 2b. Xóa data cũ hơn 7 ngày
                marketPriceDAO.deleteOlderThan(7);

                // 3. Insert dữ liệu mới
                int inserted = marketPriceDAO.batchInsert(prices);
                result.setItemsInserted(inserted);
                result.setStatus("SUCCESS");
                logger.info("[CrawlerService] Crawl SUCCESS: " + inserted + " items saved for " + java.time.LocalDate.now());

            } else {
                result.setStatus("NO_DATA");
                result.setErrorMsg("Crawler returned 0 results - website may have changed structure");
                logger.warning("[CrawlerService] No data crawled");
            }

        } catch (Exception e) {
            result.setStatus("FAILED");
            result.setErrorMsg(e.getMessage());
            logger.severe("[CrawlerService] Crawl FAILED: " + e.getMessage());
        }

        result.setDurationMs((int) (System.currentTimeMillis() - startTime));
        logCrawlerRun(result);

        // EVENT: notify admin that crawler finished (success or failure)
        EventPublisher.publish(new CrawlerFinishedEvent(
                result.getStatus(), result.getItemsCrawled(), result.getDurationMs()));

        return result;
    }

    /**
     * Lưu kết quả crawl vào CrawlerLogs
     */
    private void logCrawlerRun(CrawlerResult result) {
        String sql = "INSERT INTO CrawlerLogs (Status, ItemsCrawled, Duration, ErrorMsg) VALUES (?,?,?,?)";
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, result.getStatus());
            ps.setInt(2, result.getItemsCrawled());
            ps.setInt(3, result.getDurationMs());
            ps.setString(4, result.getErrorMsg());
            ps.executeUpdate();
        } catch (Exception e) {
            logger.warning("Could not save crawler log: " + e.getMessage());
        }
    }

    /**
     * Lấy lịch sử crawler logs (cho Admin)
     */
    public List<java.util.Map<String, Object>> getCrawlerLogs(int limit) {
        List<java.util.Map<String, Object>> logs = new java.util.ArrayList<>();
        String sql = "SELECT LogID, RunAt, Status, ItemsCrawled, Duration, ErrorMsg " +
                "FROM CrawlerLogs ORDER BY RunAt DESC LIMIT " + limit;
        try (Connection conn = new DBContext().getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
                row.put("logId", rs.getInt("LogID"));
                row.put("runAt", rs.getTimestamp("RunAt"));
                row.put("status", rs.getString("Status"));
                row.put("itemsCrawled", rs.getInt("ItemsCrawled"));
                row.put("duration", rs.getInt("Duration"));
                row.put("errorMsg", rs.getString("ErrorMsg"));
                logs.add(row);
            }
        } catch (SQLException e) {
            logger.warning("getCrawlerLogs error: " + e.getMessage());
        }
        return logs;
    }

    /**
     * Inner class kết quả crawl
     */
    public static class CrawlerResult {
        private String status = "PENDING";
        private int itemsCrawled = 0;
        private int itemsInserted = 0;
        private int durationMs = 0;
        private String errorMsg;

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public int getItemsCrawled() {
            return itemsCrawled;
        }

        public void setItemsCrawled(int itemsCrawled) {
            this.itemsCrawled = itemsCrawled;
        }

        public int getItemsInserted() {
            return itemsInserted;
        }

        public void setItemsInserted(int itemsInserted) {
            this.itemsInserted = itemsInserted;
        }

        public int getDurationMs() {
            return durationMs;
        }

        public void setDurationMs(int durationMs) {
            this.durationMs = durationMs;
        }

        public String getErrorMsg() {
            return errorMsg;
        }

        public void setErrorMsg(String errorMsg) {
            this.errorMsg = errorMsg;
        }

        public boolean isSuccess() {
            return "SUCCESS".equals(status);
        }
    }
}
