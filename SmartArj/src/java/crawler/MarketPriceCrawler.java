package crawler;

import marketplace.model.MarketPrice;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

/**
 * Crawler chính - Fetch HTML từ web và parse thành MarketPrice
 * Nguồn: https://nongnghiepmoitruong.vn/gia-nong-san-hom-nay-tag111220/
 */
public class MarketPriceCrawler {

    private static final Logger logger = Logger.getLogger(MarketPriceCrawler.class.getName());

    private static final String[] TARGET_URLS = {
            // Nguồn 1: Nông nghiệp Môi Trường (nhiều bài giá nhất)
            "https://nongnghiepmoitruong.vn/gia-nong-san-hom-nay-tag111220/",
            "https://nongnghiepmoitruong.vn/gia-nong-san/",
            // Nguồn 2: Báo Nông nghiệp Việt Nam
            "https://nongnghiep.vn/gia-nong-san.html",
            // Nguồn 3: Giá sản phẩm.vn
            "https://giasanpham.vn/gia-nong-san/",
            // Nguồn 4: Agroviet Bộ NN&PTNT
            "https://www.agroviet.gov.vn/gia-nong-san"
    };

    private static final int TIMEOUT_MS = 15000;
    private static final String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0 Safari/537.36";

    private final CrawlerParser parser = new CrawlerParser();

    /**
     * Chạy crawler và trả về list giá crawl được
     * 
     * @return List MarketPrice, hoặc empty list nếu lỗi
     */
    public List<MarketPrice> crawl() {
        List<MarketPrice> allPrices = new ArrayList<>();

        for (String targetUrl : TARGET_URLS) {
            try {
                logger.info("Crawling: " + targetUrl);
                String html = fetchHtml(targetUrl);
                if (html != null && !html.isEmpty()) {
                    List<MarketPrice> prices = parser.parse(html);
                    allPrices.addAll(prices);
                    logger.info("Got " + prices.size() + " prices from " + targetUrl);
                    if (!prices.isEmpty())
                        break; // Nếu crawl được rồi thì không cần crawl URL khác
                }
            } catch (Exception e) {
                logger.warning("Failed to crawl " + targetUrl + ": " + e.getMessage());
            }
        }

        // Nếu không crawl được gì, trả về empty list
        if (allPrices.isEmpty()) {
            logger.warning("Crawler returned 0 results. Will use existing DB data.");
        }

        return Collections.unmodifiableList(allPrices);
    }

    /**
     * Fetch HTML từ URL
     */
    private String fetchHtml(String urlStr) throws Exception {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(TIMEOUT_MS);
        conn.setReadTimeout(TIMEOUT_MS);
        conn.setRequestProperty("User-Agent", USER_AGENT);
        conn.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
        conn.setRequestProperty("Accept-Language", "vi-VN,vi;q=0.9,en;q=0.8");
        conn.setRequestProperty("Accept-Charset", "UTF-8");
        conn.setRequestProperty("Referer", "https://google.com");
        conn.setRequestProperty("Cache-Control", "no-cache");
        conn.setInstanceFollowRedirects(true);

        int responseCode = conn.getResponseCode();
        if (responseCode != 200) {
            throw new Exception("HTTP response: " + responseCode);
        }

        // Read response
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line).append("\n");
            }
        } finally {
            conn.disconnect();
        }

        return sb.toString();
    }
}
