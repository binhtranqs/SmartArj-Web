package marketplace.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Model đại diện cho đơn hàng
 */
public class Order {

    private Integer orderId;
    private Integer buyerId;
    private String buyerName;       // JOIN
    private Integer farmerId;
    private String farmerName;      // JOIN
    private BigDecimal totalAmount;
    private String status;          // PENDING | CONFIRMED | SHIPPED | COMPLETED | CANCELLED
    private String paymentMethod;   // COD | VNPAY
    private String paymentStatus;   // UNPAID | PAID | FAILED
    private String vnpTxnRef;       // VNPay transaction ref
    private String note;
    private String shipAddress;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private List<OrderItem> items;  // JOIN

    public Order() {
        this.status = "PENDING";
        this.totalAmount = BigDecimal.ZERO;
        this.createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Integer getBuyerId() { return buyerId; }
    public void setBuyerId(Integer buyerId) { this.buyerId = buyerId; }

    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }

    public Integer getFarmerId() { return farmerId; }
    public void setFarmerId(Integer farmerId) { this.farmerId = farmerId; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getShipAddress() { return shipAddress; }
    public void setShipAddress(String shipAddress) { this.shipAddress = shipAddress; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }

    public boolean isPending() { return "PENDING".equals(status); }
    public boolean isCompleted() { return "COMPLETED".equals(status); }
    public boolean isCancelled() { return "CANCELLED".equals(status); }
    public boolean isPaid() { return "PAID".equals(paymentStatus); }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getVnpTxnRef() { return vnpTxnRef; }
    public void setVnpTxnRef(String vnpTxnRef) { this.vnpTxnRef = vnpTxnRef; }

    public String getPaymentStatusLabel() {
        if (paymentStatus == null) return "Chưa thanh toán";
        switch (paymentStatus) {
            case "PAID":   return "Đã thanh toán";
            case "FAILED": return "Thanh toán thất bại";
            default:       return "Chưa thanh toán";
        }
    }

    public String getPaymentMethodLabel() {
        if ("VNPAY".equals(paymentMethod)) return "VNPay Online";
        return "Tiền mặt (COD)";
    }

    public String getStatusBadgeClass() {
        switch (status) {
            case "PENDING":   return "badge-warning";
            case "CONFIRMED": return "badge-info";
            case "SHIPPED":   return "badge-primary";
            case "COMPLETED": return "badge-success";
            case "CANCELLED": return "badge-danger";
            default:          return "badge-secondary";
        }
    }

    public String getStatusLabel() {
        switch (status) {
            case "PENDING":   return "Chờ xác nhận";
            case "CONFIRMED": return "Đã xác nhận";
            case "SHIPPED":   return "Đang giao";
            case "COMPLETED": return "Hoàn thành";
            case "CANCELLED": return "Đã hủy";
            default:          return status;
        }
    }
}
