package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity yêu cầu nâng cấp VIP
 */
@Entity
@Table(name = "VipRequests")
public class VipRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RequestID")
    private Integer requestId;

    @Column(name = "UserID", nullable = false)
    private Integer userId;

    /** PENDING | APPROVED | REJECTED */
    @Column(name = "Status", nullable = false, length = 20)
    private String status = "PENDING";

    @Column(name = "DurationDays", nullable = false)
    private Integer durationDays = 30;

    @Column(name = "Note", length = 500)
    private String note;

    @Column(name = "ReviewedBy")
    private Integer reviewedBy;

    @Column(name = "ReviewedAt")
    private LocalDateTime reviewedAt;

    @Column(name = "ReviewNote", length = 500)
    private String reviewNote;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    public VipRequest() {
        this.createdAt = LocalDateTime.now();
        this.status = "PENDING";
    }

    public VipRequest(Integer userId, Integer durationDays, String note) {
        this();
        this.userId = userId;
        this.durationDays = durationDays;
        this.note = note;
    }

    // Getters & Setters
    public Integer getRequestId() {
        return requestId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer v) {
        this.userId = v;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String v) {
        this.status = v;
    }

    public Integer getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(Integer v) {
        this.durationDays = v;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String v) {
        this.note = v;
    }

    public Integer getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Integer v) {
        this.reviewedBy = v;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(LocalDateTime v) {
        this.reviewedAt = v;
    }

    public String getReviewNote() {
        return reviewNote;
    }

    public void setReviewNote(String v) {
        this.reviewNote = v;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
