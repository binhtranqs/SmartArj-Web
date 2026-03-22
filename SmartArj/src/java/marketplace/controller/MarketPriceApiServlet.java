package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.dao.MarketPriceDAO;
import marketplace.model.MarketPrice;
import marketplace.service.MarketplaceService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * API endpoint trả về giá thị trường dạng JSON
 * URL: /api/market-prices          → trả về 30 giá mới nhất (cho ticker bar)
 * URL: /api/market-prices?q=tên   → tìm kiếm theo tên sản phẩm (cho form đăng SP)
 */
@WebServlet("/api/market-prices")
public class MarketPriceApiServlet extends HttpServlet {

    private final MarketplaceService service = new MarketplaceService();
    private final MarketPriceDAO marketPriceDAO = new MarketPriceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String query = req.getParameter("q");

        List<MarketPrice> prices;
        if (query != null && !query.trim().isEmpty()) {
            // Tìm theo tên sản phẩm (không cache vì dynamic)
            resp.setHeader("Cache-Control", "no-cache");
            prices = marketPriceDAO.findByProductName(query.trim());

            // Nếu không tìm thấy theo tên (lý do: dấu tiếng Việt không khớp)
            // → fallback trả về 5 giá mới nhất làm tham chiếu chung
            if (prices.isEmpty()) {
                prices = service.getLatestMarketPrices();
                if (prices.size() > 5) {
                    prices = prices.subList(0, 5);
                }
            }
        } else {
            // Trả về toàn bộ (cache 1 tiếng)
            resp.setHeader("Cache-Control", "max-age=3600");
            prices = service.getLatestMarketPrices();
        }

        // Build JSON response
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < prices.size(); i++) {
            MarketPrice mp = prices.get(i);
            json.append("{");
            json.append("\"id\":").append(mp.getPriceId()).append(",");
            json.append("\"product\":\"").append(escapeJson(mp.getProductName())).append("\",");
            json.append("\"region\":\"").append(escapeJson(mp.getRegionName())).append("\",");
            json.append("\"price\":").append(mp.getPrice()).append(",");
            json.append("\"unit\":\"").append(escapeJson(mp.getUnit())).append("\",");
            json.append("\"label\":\"").append(escapeJson(mp.getDisplayLabel())).append("\",");
            json.append("\"formattedPrice\":\"").append(escapeJson(mp.getFormattedPrice())).append("\"");
            json.append("}");
            if (i < prices.size() - 1)
                json.append(",");
        }
        json.append("]");

        resp.getWriter().write(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null || "null".equals(s))
            return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}

