package marketplace.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Model đại diện cho item trong giỏ hàng
 */
public class CartItem {

    private Integer cartId;
    private Integer buyerId;
    private Integer listingId;
    private String productName; // JOIN
    private String farmerName; // JOIN
    private Integer farmerId; // JOIN
    private String regionName; // JOIN
    private BigDecimal unitPrice; // JOIN
    private String unit; // JOIN
    private String imageUrl; // JOIN
    private BigDecimal quantity;
    private LocalDateTime addedAt;
    // Trạng thái listing lúc đọc từ DB (ACTIVE | SOLD_OUT | HIDDEN | null nếu listing đã bị xóa)
    private String listingStatus;
    // Số lượng tồn kho hiện tại của listing
    private java.math.BigDecimal availableQty;

    public CartItem() {
        this.quantity = BigDecimal.ONE;
        this.addedAt = LocalDateTime.now();
    }

    public BigDecimal getSubTotal() {
        if (quantity == null || unitPrice == null)
            return BigDecimal.ZERO;
        return quantity.multiply(unitPrice);
    }

    // Getters & Setters
    public Integer getCartId() {
        return cartId;
    }

    public void setCartId(Integer cartId) {
        this.cartId = cartId;
    }

    public Integer getBuyerId() {
        return buyerId;
    }

    public void setBuyerId(Integer buyerId) {
        this.buyerId = buyerId;
    }

    public Integer getListingId() {
        return listingId;
    }

    public void setListingId(Integer listingId) {
        this.listingId = listingId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
    }

    public Integer getFarmerId() {
        return farmerId;
    }

    public void setFarmerId(Integer farmerId) {
        this.farmerId = farmerId;
    }

    public String getRegionName() {
        return regionName;
    }

    public void setRegionName(String regionName) {
        this.regionName = regionName;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public BigDecimal getQuantity() {
        return quantity;
    }

    public void setQuantity(BigDecimal quantity) {
        this.quantity = quantity;
    }

    public LocalDateTime getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(LocalDateTime addedAt) {
        this.addedAt = addedAt;
    }

    public String getListingStatus() {
        return listingStatus;
    }

    public void setListingStatus(String listingStatus) {
        this.listingStatus = listingStatus;
    }

    public java.math.BigDecimal getAvailableQty() {
        return availableQty;
    }

    public void setAvailableQty(java.math.BigDecimal availableQty) {
        this.availableQty = availableQty;
    }

    /**
     * Kiểm tra listing có cón khả dụng không (ACTIVE và còn hàng).
     * Dùng trong JSP để disable nút checkout và hiển thị badge hết hàng.
     */
    public boolean isAvailable() {
        return "ACTIVE".equals(listingStatus)
                && availableQty != null
                && availableQty.compareTo(BigDecimal.ZERO) > 0;
    }

    /**
     * Kiểm tra listing đã bị xóa (LEFT JOIN trả null).
     */
    public boolean isListingDeleted() {
        return listingStatus == null;
    }
}
