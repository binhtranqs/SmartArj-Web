package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity nhật ký hành động của Admin
 */
@Entity
@Table(name = "AdminAuditLog")
public class AdminAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LogID")
    private Integer logId;

    @Column(name = "AdminID")
    private Integer adminId;

    @Column(name = "TargetUserID")
    private Integer targetUserId;

    /**
     * Loại hành động: LOCK_USER, UNLOCK_USER, APPROVE_VIP, REJECT_VIP, LOGIN_FAIL,
     * CHANGE_ROLE
     */
    @Column(name = "Action", nullable = false, length = 50)
    private String action;

    @Column(name = "Note", length = 500)
    private String note;

    @Column(name = "IpAddress", length = 50)
    private String ipAddress;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    public AdminAuditLog() {
        this.createdAt = LocalDateTime.now();
    }

    public AdminAuditLog(Integer adminId, Integer targetUserId, String action, String note) {
        this();
        this.adminId = adminId;
        this.targetUserId = targetUserId;
        this.action = action;
        this.note = note;
    }

    // Getters & Setters
    public Integer getLogId() {
        return logId;
    }

    public Integer getAdminId() {
        return adminId;
    }

    public void setAdminId(Integer v) {
        this.adminId = v;
    }

    public Integer getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(Integer v) {
        this.targetUserId = v;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String v) {
        this.action = v;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String v) {
        this.note = v;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String v) {
        this.ipAddress = v;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime v) {
        this.createdAt = v;
    }
}
