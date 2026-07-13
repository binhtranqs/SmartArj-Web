package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity đại diện cho người dùng trong hệ thống
 */
@Entity
@Table(name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "UserID")
    private Integer userId;

    @Column(name = "Username", unique = true, nullable = false, length = 50)
    private String username;

    @Column(name = "Email", unique = true, nullable = false, length = 100)
    private String email;

    @Column(name = "PasswordHash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "FullName", length = 100)
    private String fullName;

    @Column(name = "AccountType", length = 20)
    private String accountType = "FREE"; // "FREE" hoặc "VIP"

    @Column(name = "VIPExpiryDate")
    private LocalDateTime vipExpiryDate;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    @Column(name = "LastLogin")
    private LocalDateTime lastLogin;

    @Column(name = "IsActive")
    private Boolean isActive = true;

    @Column(name = "CityID")
    private Integer cityId;

    // Constructor
    public User() {
        this.createdAt = LocalDateTime.now();
        this.accountType = "FREE";
        this.isActive = true;
    }

    // Getters và Setters
    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public LocalDateTime getVipExpiryDate() {
        return vipExpiryDate;
    }

    public void setVipExpiryDate(LocalDateTime vipExpiryDate) {
        this.vipExpiryDate = vipExpiryDate;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(LocalDateTime lastLogin) {
        this.lastLogin = lastLogin;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Integer getCityId() {
        return cityId;
    }

    public void setCityId(Integer cityId) {
        this.cityId = cityId;
    }

    // Phương thức tiện ích

    /**
     * Kiểm tra xem user có phải VIP không
     * 
     * @return true nếu là VIP và chưa hết hạn
     */
    public boolean isVIP() {
        if (!"VIP".equals(accountType)) {
            return false;
        }
        if (vipExpiryDate == null) {
            return false;
        }
        return vipExpiryDate.isAfter(LocalDateTime.now());
    }

    /**
     * Kiểm tra xem VIP đã hết hạn chưa
     * 
     * @return true nếu VIP đã hết hạn
     */
    public boolean isVIPExpired() {
        if (!"VIP".equals(accountType)) {
            return false;
        }
        if (vipExpiryDate == null) {
            return true;
        }
        return vipExpiryDate.isBefore(LocalDateTime.now());
    }

    /**
     * Lấy số ngày VIP còn lại
     * 
     * @return số ngày, hoặc 0 nếu không phải VIP
     */
    public long getDaysRemaining() {
        if (!isVIP()) {
            return 0;
        }
        return java.time.temporal.ChronoUnit.DAYS.between(
                LocalDateTime.now(),
                vipExpiryDate);
    }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", accountType='" + accountType + '\'' +
                ", isVIP=" + isVIP() +
                '}';
    }
}
