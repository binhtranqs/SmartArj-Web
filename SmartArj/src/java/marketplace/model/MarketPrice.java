package marketplace.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Model đại diện cho giá thị trường nông sản (từ crawler)
 */
public class MarketPrice {

    private Integer priceId;
    private String productName;
    private String regionName;
    private BigDecimal price;
    private String unit;
    private LocalDateTime crawledAt;
    private String sourceUrl;

    public MarketPrice() {
        this.unit = "đ/kg";
        this.crawledAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getPriceId() { return priceId; }
    public void setPriceId(Integer priceId) { this.priceId = priceId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getRegionName() { return regionName; }
    public void setRegionName(String regionName) { this.regionName = regionName; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public LocalDateTime getCrawledAt() { return crawledAt; }
    public void setCrawledAt(LocalDateTime crawledAt) { this.crawledAt = crawledAt; }

    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }

    /**
     * Hiển thị tên đầy đủ dùng cho ticker bar
     */
    public String getDisplayLabel() {
        if (regionName != null && !regionName.isEmpty()) {
            return productName + " (" + regionName + ")";
        }
        return productName;
    }

    /**
     * Giá định dạng: 97,100 đ/kg
     */
    public String getFormattedPrice() {
        if (price == null) return "N/A";
        java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi", "VN"));
        return nf.format(price) + " " + unit;
    }

    /**
     * Format ngày tháng cho JSTL hiển thị an toàn (tránh lỗi convert LocalDateTime)
     */
    public String getFormattedCrawledAt() {
        if (crawledAt == null) return "";
        return crawledAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM HH:mm"));
    }
}
