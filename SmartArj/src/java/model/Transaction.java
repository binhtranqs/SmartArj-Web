package model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity đại diện cho giao dịch nạp tiền VIP
 */
@Entity
@Table(name = "Transactions")
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TransactionID")
    private Integer transactionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "UserID", nullable = false)
    private User user;

    @Column(name = "Amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(name = "TransactionType", length = 20)
    private String transactionType; // "VIP_UPGRADE", "VIP_RENEWAL"

    @Column(name = "Status", length = 20)
    private String status; // "PENDING", "COMPLETED", "FAILED"

    @Column(name = "PaymentMethod", length = 50)
    private String paymentMethod; // "MOMO", "VNPAY", "BANK_TRANSFER"

    @Column(name = "TransactionDate")
    private LocalDateTime transactionDate;

    @Column(name = "VIPDuration")
    private Integer vipDuration; // Số ngày VIP (30, 90, 365)

    @Column(name = "Description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "ProviderTxnRef", length = 64)
    private String providerTxnRef;

    @Column(name = "ProviderTxnId", length = 64)
    private String providerTxnId;

    // Constructor
    public Transaction() {
        this.transactionDate = LocalDateTime.now();
        this.status = "PENDING";
    }

    // Getters và Setters
    public Integer getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Integer transactionId) {
        this.transactionId = transactionId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public LocalDateTime getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDateTime transactionDate) {
        this.transactionDate = transactionDate;
    }

    public Integer getVipDuration() {
        return vipDuration;
    }

    public void setVipDuration(Integer vipDuration) {
        this.vipDuration = vipDuration;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getProviderTxnRef() {
        return providerTxnRef;
    }

    public void setProviderTxnRef(String providerTxnRef) {
        this.providerTxnRef = providerTxnRef;
    }

    public String getProviderTxnId() {
        return providerTxnId;
    }

    public void setProviderTxnId(String providerTxnId) {
        this.providerTxnId = providerTxnId;
    }

    @Override
    public String toString() {
        return "Transaction{" +
                "transactionId=" + transactionId +
                ", amount=" + amount +
                ", transactionType='" + transactionType + '\'' +
                ", status='" + status + '\'' +
                ", vipDuration=" + vipDuration +
                '}';
    }
}
