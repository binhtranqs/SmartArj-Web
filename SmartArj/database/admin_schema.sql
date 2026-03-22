-- ============================================================
-- SmartArj Admin Features Schema
-- Chạy script này trong SQL Server Management Studio (SSMS)
-- Database: SmartAgri_PRJ301
-- ============================================================

USE SmartAgri_PRJ301;
GO

-- ============================================================
-- 1. Thêm cột vào bảng Users (bỏ qua nếu đã tồn tại)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'LockReason')
    ALTER TABLE Users ADD LockReason NVARCHAR(255) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'LockedUntil')
    ALTER TABLE Users ADD LockedUntil DATETIME NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'Role')
    ALTER TABLE Users ADD Role NVARCHAR(20) NOT NULL DEFAULT 'USER';
GO

-- ============================================================
-- 2. Bảng nhật ký hành động admin
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AdminAuditLog')
BEGIN
    CREATE TABLE AdminAuditLog (
        LogID        INT IDENTITY(1,1) PRIMARY KEY,
        AdminID      INT NULL REFERENCES Users(UserID),
        TargetUserID INT NULL REFERENCES Users(UserID),
        Action       NVARCHAR(50)  NOT NULL,  -- LOCK_USER, UNLOCK_USER, APPROVE_VIP, REJECT_VIP, LOGIN_FAIL, CHANGE_ROLE
        Note         NVARCHAR(500) NULL,
        IpAddress    NVARCHAR(50)  NULL,
        CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table AdminAuditLog';
END
ELSE
    PRINT 'Table AdminAuditLog already exists';
GO

-- ============================================================
-- 3. Bảng yêu cầu nâng cấp VIP
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'VipRequests')
BEGIN
    CREATE TABLE VipRequests (
        RequestID    INT IDENTITY(1,1) PRIMARY KEY,
        UserID       INT NOT NULL REFERENCES Users(UserID),
        Status       NVARCHAR(20)  NOT NULL DEFAULT 'PENDING',  -- PENDING | APPROVED | REJECTED
        DurationDays INT           NOT NULL DEFAULT 30,
        Note         NVARCHAR(500) NULL,
        ReviewedBy   INT NULL REFERENCES Users(UserID),
        ReviewedAt   DATETIME NULL,
        ReviewNote   NVARCHAR(500) NULL,
        CreatedAt    DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table VipRequests';
END
ELSE
    PRINT 'Table VipRequests already exists';
GO

-- ============================================================
-- 4. Bảng chat log
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ChatLogs')
BEGIN
    CREATE TABLE ChatLogs (
        LogID        INT IDENTITY(1,1) PRIMARY KEY,
        UserID       INT NULL REFERENCES Users(UserID),
        ZoneID       INT NULL,
        Message      NVARCHAR(500) NULL,
        Intent       NVARCHAR(60)  NULL,   -- WEATHER_BY_DATE, CROPS, FALLBACK_AI, GREETING, ...
        WasDbAnswer  BIT           NOT NULL DEFAULT 0,
        AiCalled     BIT           NOT NULL DEFAULT 0,
        LatencyMs    INT           NULL,
        CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table ChatLogs';
END
ELSE
    PRINT 'Table ChatLogs already exists';
GO

-- ============================================================
-- 5. Tạo tài khoản ADMIN mặc định (nếu chưa có)
-- Đặt user đầu tiên thành ADMIN để test
-- ============================================================
-- Bạn có thể thay 'your_username' bằng username thực của bạn
-- UPDATE Users SET Role = 'ADMIN' WHERE Username = 'your_username';

PRINT 'Admin schema migration DONE!';
GO
