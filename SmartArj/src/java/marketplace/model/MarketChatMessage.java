package marketplace.model;

import java.time.LocalDateTime;

/**
 * Model đại diện cho tin nhắn chat Buyer <-> Farmer
 */
public class MarketChatMessage {

    private Integer msgId;
    private Integer senderId;
    private String senderName; // JOIN
    private Integer receiverId;
    private String receiverName; // JOIN
    private Integer listingId;
    private String productName; // JOIN
    private String message;
    private boolean isRead;
    private LocalDateTime sentAt;

    public MarketChatMessage() {
        this.isRead = false;
        this.sentAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getMsgId() {
        return msgId;
    }

    public void setMsgId(Integer msgId) {
        this.msgId = msgId;
    }

    public Integer getSenderId() {
        return senderId;
    }

    public void setSenderId(Integer senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public Integer getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(Integer receiverId) {
        this.receiverId = receiverId;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
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

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public LocalDateTime getSentAt() {
        return sentAt;
    }

    public void setSentAt(LocalDateTime sentAt) {
        this.sentAt = sentAt;
    }
}
