package marketplace.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Model đại diện cho một listing (sản phẩm nông sản) của Farmer
 */
public class Listing {

    private Integer listingId;
    private Integer farmerId;
    private String farmerName;      // JOIN từ Users
    private String farmerEmail;     // JOIN từ Users
    private String productName;
    private String description;
    private Integer regionId;
    private String regionName;      // JOIN từ Regions
    private BigDecimal price;
    private String unit;
    private BigDecimal quantity;
    private String imageUrl;
    private String status;          // ACTIVE | SOLD_OUT | HIDDEN
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Market price reference (JOIN từ MarketPrices)
    private BigDecimal marketPrice;

    public Listing() {
        this.status = "ACTIVE";
        this.unit = "kg";
        this.createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getListingId() { return listingId; }
    public void setListingId(Integer listingId) { this.listingId = listingId; }

    public Integer getFarmerId() { return farmerId; }
    public void setFarmerId(Integer farmerId) { this.farmerId = farmerId; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public String getFarmerEmail() { return farmerEmail; }
    public void setFarmerEmail(String farmerEmail) { this.farmerEmail = farmerEmail; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getRegionId() { return regionId; }
    public void setRegionId(Integer regionId) { this.regionId = regionId; }

    public String getRegionName() { return regionName; }
    public void setRegionName(String regionName) { this.regionName = regionName; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public BigDecimal getMarketPrice() { return marketPrice; }
    public void setMarketPrice(BigDecimal marketPrice) { this.marketPrice = marketPrice; }

    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isSoldOut() { return "SOLD_OUT".equals(status); }
}
