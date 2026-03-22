package marketplace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.service.MarketplaceService;

import java.io.IOException;
import java.util.*;

/**
 * Crop Recommendation Servlet
 * Gợi ý cây trồng dựa theo vùng địa lý / thời tiết
 * URL: /crop-recommend
 */
@WebServlet("/crop-recommend")
public class CropRecommendServlet extends HttpServlet {

    private final MarketplaceService marketplaceService = new MarketplaceService();

    // Crop recommendation database (region → recommended crops)
    private static final Map<String, List<CropInfo>> CROP_DB = new LinkedHashMap<>();

    static {
        // Tây Nguyên (Gia Lai, Đắk Lắk, Lâm Đồng)
        List<CropInfo> tayNguyen = Arrays.asList(
                new CropInfo("Cà phê Robusta", "☕", "#6D4C41", "Thổ nhưỡng basalt, cao nguyên, phù hợp khí hậu mát"),
                new CropInfo("Hồ tiêu", "🌿", "#2E7D32", "Độ ẩm cao, đất tốt, giá trị kinh tế cao"),
                new CropInfo("Sầu riêng", "🍈", "#F9A825", "Tây Nguyên có điều kiện lý tưởng cho sầu riêng"),
                new CropInfo("Chanh leo", "💛", "#FDD835", "Thích nghi tốt với khí hậu Tây Nguyên"),
                new CropInfo("Bơ", "🥑", "#558B2F", "Cho trái quanh năm ở Tây Nguyên"),
                new CropInfo("Điều", "🌰", "#8D6E63", "Chịu hạn tốt, phù hợp vùng đất đỏ"));
        CROP_DB.put("Gia Lai", tayNguyen);
        CROP_DB.put("Đắk Lắk", tayNguyen);
        CROP_DB.put("Lâm Đồng", Arrays.asList(
                new CropInfo("Rau ôn đới", "🥦", "#43A047", "Đà Lạt - thủ phủ rau sạch Việt Nam"),
                new CropInfo("Hoa cúc", "🌼", "#FFD740", "Xuất khẩu hoa Đà Lạt toàn quốc"),
                new CropInfo("Cà phê Arabica", "☕", "#795548", "Cà phê Arabica chất lượng cao"),
                new CropInfo("Dâu tây", "🍓", "#E53935", "Đặc sản Đà Lạt"),
                new CropInfo("Khoai lang Nhật", "🍠", "#FF8F00", "Xuất khẩu, giá trị cao")));
        CROP_DB.put("Kon Tum", tayNguyen);
        CROP_DB.put("Đắk Nông", tayNguyen);

        // Đồng bằng sông Cửu Long
        List<CropInfo> mekong = Arrays.asList(
                new CropInfo("Lúa gạo", "🌾", "#FDD835", "Vựa lúa lớn nhất Việt Nam"),
                new CropInfo("Xoài cát Hòa Lộc", "🥭", "#FF8F00", "Đặc sản ĐBSCL xuất khẩu"),
                new CropInfo("Dừa", "🥥", "#8D6E63", "Bến Tre, Trà Vinh nổi tiếng dừa"),
                new CropInfo("Nhãn", "🍇", "#7E57C2", "Nhãn Ido Vĩnh Long, Bến Tre"),
                new CropInfo("Sầu riêng", "🍈", "#F9A825", "Cái Mơn, Cái Răng nổi tiếng"),
                new CropInfo("Tôm sú", "🦐", "#FF7043", "Nuôi trồng thủy sản"));
        CROP_DB.put("Tiền Giang", mekong);
        CROP_DB.put("Hậu Giang", mekong);
        CROP_DB.put("An Giang", mekong);
        CROP_DB.put("Bến Tre", mekong);

        // Đông Nam Bộ
        List<CropInfo> dongNamBo = Arrays.asList(
                new CropInfo("Cao su", "🌳", "#A5D6A7", "Vùng chuyên canh cao su lớn nhất nước"),
                new CropInfo("Điều", "🌰", "#8D6E63", "Xuất khẩu hàng đầu thế giới"),
                new CropInfo("Tiêu đen", "🌶️", "#212121", "Chất lượng cao, xuất khẩu"),
                new CropInfo("Mít Thái", "🍊", "#FF8F00", "Xuất khẩu sang Trung Quốc"),
                new CropInfo("Cacao", "🍫", "#6D4C41", "Phát triển mạnh ở Bình Phước"));
        CROP_DB.put("Bình Phước", dongNamBo);
        CROP_DB.put("Đồng Nai", dongNamBo);

        // Đồng bằng sông Hồng
        List<CropInfo> songHong = Arrays.asList(
                new CropInfo("Lúa nếp", "🌾", "#FDD835", "Lúa nếp thơm đặc sản miền Bắc"),
                new CropInfo("Rau sạch", "🥬", "#43A047", "Rau an toàn VietGAP"),
                new CropInfo("Hành tỏi", "🧅", "#C8E6C9", "Hải Dương, Hải Phòng"),
                new CropInfo("Cà rốt", "🥕", "#FF7043", "Hải Dương nổi tiếng cà rốt"),
                new CropInfo("Vải thiều", "🍒", "#E53935", "Bắc Giang, Hải Dương"));
        CROP_DB.put("Hà Nội", songHong);
        CROP_DB.put("Hải Dương", songHong);

        // Default
        CROP_DB.put("default", Arrays.asList(
                new CropInfo("Lúa", "🌾", "#FDD835", "Cây lương thực chủ lực Việt Nam"),
                new CropInfo("Ngô", "🌽", "#FFEB3B", "Thức ăn chăn nuôi, lương thực"),
                new CropInfo("Sắn", "🌿", "#66BB6A", "Chịu hạn tốt, nhiều vùng trồng được"),
                new CropInfo("Đậu tương", "🫘", "#A5D6A7", "Cung cấp đạm thực vật")));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String zone = req.getParameter("zone");
        String region = req.getParameter("region");

        // Tìm gợi ý dựa theo region hoặc zone
        String searchKey = region != null ? region : (zone != null ? zone : "");
        List<CropInfo> recommendations = findRecommendations(searchKey);

        // Lấy danh sách regions từ DB
        List<marketplace.model.Region> regions = marketplaceService.getAllRegions();

        req.setAttribute("recommendations", recommendations);
        req.setAttribute("selectedZone", searchKey);
        req.setAttribute("regions", regions);

        req.getRequestDispatcher("/WEB-INF/views/crop/recommend.jsp").forward(req, resp);
    }

    private List<CropInfo> findRecommendations(String key) {
        if (key == null || key.trim().isEmpty()) {
            return CROP_DB.get("default");
        }
        // Tìm chính xác
        if (CROP_DB.containsKey(key)) {
            return CROP_DB.get(key);
        }
        // Tìm gần đúng (LIKE)
        for (Map.Entry<String, List<CropInfo>> entry : CROP_DB.entrySet()) {
            if (key.contains(entry.getKey()) || entry.getKey().contains(key)) {
                return entry.getValue();
            }
        }
        return CROP_DB.get("default");
    }

    /**
     * Inner class thông tin cây trồng
     */
    public static class CropInfo {
        private final String name;
        private final String emoji;
        private final String color;
        private final String description;

        public CropInfo(String name, String emoji, String color, String description) {
            this.name = name;
            this.emoji = emoji;
            this.color = color;
            this.description = description;
        }

        public String getName() {
            return name;
        }

        public String getEmoji() {
            return emoji;
        }

        public String getColor() {
            return color;
        }

        public String getDescription() {
            return description;
        }
    }
}
