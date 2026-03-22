package marketplace.model;

import java.math.BigDecimal;

/**
 * Model đại diện cho từng item trong đơn hàng
 */
public class OrderItem {

    private Integer itemId;
    private Integer orderId;
    private Integer listingId;
    private String productName; // JOIN
    private BigDecimal quantity;
    private BigDecimal unitPrice;

    public OrderItem() {
    }

    public BigDecimal getSubTotal() {
        if (quantity == null || unitPrice == null)
            return BigDecimal.ZERO;
        return quantity.multiply(unitPrice);
    }

    // Getters & Setters
    public Integer getItemId() {
        return itemId;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
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

    public BigDecimal getQuantity() {
        return quantity;
    }

    public void setQuantity(BigDecimal quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
}
