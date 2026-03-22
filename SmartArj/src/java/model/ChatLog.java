package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity chat log – lưu mỗi message từ chatbot
 */
@Entity
@Table(name = "ChatLogs")
public class ChatLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LogID")
    private Integer logId;

    @Column(name = "UserID")
    private Integer userId;

    @Column(name = "ZoneID")
    private Integer zoneId;

    @Column(name = "Message", columnDefinition = "NVARCHAR(500)")
    private String message;

    /** Intent matched: WEATHER_BY_DATE, CROPS, FALLBACK_AI, GREETING, HELP, v.v. */
    @Column(name = "Intent", columnDefinition = "NVARCHAR(60)")
    private String intent;

    @Column(name = "WasDbAnswer", nullable = false)
    private Boolean wasDbAnswer = false;

    @Column(name = "AiCalled", nullable = false)
    private Boolean aiCalled = false;

    @Column(name = "LatencyMs")
    private Integer latencyMs;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    public ChatLog() {
        this.createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getLogId() {
        return logId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer v) {
        this.userId = v;
    }

    public Integer getZoneId() {
        return zoneId;
    }

    public void setZoneId(Integer v) {
        this.zoneId = v;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String v) {
        this.message = v;
    }

    public String getIntent() {
        return intent;
    }

    public void setIntent(String v) {
        this.intent = v;
    }

    public Boolean getWasDbAnswer() {
        return wasDbAnswer;
    }

    public void setWasDbAnswer(Boolean v) {
        this.wasDbAnswer = v;
    }

    public Boolean getAiCalled() {
        return aiCalled;
    }

    public void setAiCalled(Boolean v) {
        this.aiCalled = v;
    }

    public Integer getLatencyMs() {
        return latencyMs;
    }

    public void setLatencyMs(Integer v) {
        this.latencyMs = v;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
