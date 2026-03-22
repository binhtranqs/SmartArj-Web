-- =====================================================
-- HỆ THỐNG ĐĂNG NHẬP & VIP MEMBERSHIP
-- =====================================================

-- Xóa bảng cũ nếu tồn tại (để test)
IF OBJECT_ID('Transactions', 'U') IS NOT NULL DROP TABLE Transactions;
IF OBJECT_ID('Sessions', 'U') IS NOT NULL DROP TABLE Sessions;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- =====================================================
-- BẢNG USERS (Người dùng)
-- =====================================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    AccountType NVARCHAR(20) DEFAULT 'FREE', -- 'FREE' hoặc 'VIP'
    VIPExpiryDate DATETIME NULL, -- Ngày hết hạn VIP
    CreatedAt DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    IsActive BIT DEFAULT 1
);

-- =====================================================
-- BẢNG TRANSACTIONS (Giao dịch nạp tiền)
-- =====================================================
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Amount DECIMAL(10,2) NOT NULL, -- Số tiền (VND)
    TransactionType NVARCHAR(20), -- 'VIP_UPGRADE', 'VIP_RENEWAL'
    Status NVARCHAR(20), -- 'PENDING', 'COMPLETED', 'FAILED'
    PaymentMethod NVARCHAR(50), -- 'MOMO', 'VNPAY', 'BANK_TRANSFER'
    TransactionDate DATETIME DEFAULT GETDATE(),
    VIPDuration INT, -- Số ngày VIP (30, 90, 365)
    Description NVARCHAR(MAX)
);

-- =====================================================
-- BẢNG SESSIONS (Phiên đăng nhập - Optional)
-- =====================================================
CREATE TABLE Sessions (
    SessionID NVARCHAR(255) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    CreatedAt DATETIME DEFAULT GETDATE(),
    ExpiresAt DATETIME NOT NULL,
    IPAddress NVARCHAR(50),
    UserAgent NVARCHAR(500)
);

GO

-- =====================================================
-- DỮ LIỆU MẪU
-- =====================================================

-- Tạo user FREE mẫu
-- Password: "123456" (đã hash bằng BCrypt)
INSERT INTO Users (Username, Email, PasswordHash, FullName, AccountType)
VALUES 
('demo_free', 'free@smartarj.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIxf6q3jm6', N'Người Dùng Miễn Phí', 'FREE'),
('demo_vip', 'vip@smartarj.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIxf6q3jm6', N'Người Dùng VIP', 'VIP');

-- Cập nhật VIP cho user thứ 2 (hết hạn sau 30 ngày)
UPDATE Users 
SET VIPExpiryDate = DATEADD(DAY, 30, GETDATE())
WHERE Username = 'demo_vip';

-- Tạo giao dịch mẫu
INSERT INTO Transactions (UserID, Amount, TransactionType, Status, PaymentMethod, VIPDuration, Description)
VALUES 
(2, 99000, 'VIP_UPGRADE', 'COMPLETED', 'MOMO', 30, N'Nâng cấp VIP 1 tháng');

GO

-- =====================================================
-- KIỂM TRA
-- =====================================================
SELECT * FROM Users;
SELECT * FROM Transactions;

PRINT N'✅ Đã tạo xong database cho hệ thống đăng nhập & VIP!';
PRINT N'';
PRINT N'👤 Tài khoản test:';
PRINT N'   - FREE: demo_free / 123456';
PRINT N'   - VIP:  demo_vip / 123456';
