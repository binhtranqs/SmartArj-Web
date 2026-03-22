USE SmartAgri_PRJ301;
GO

-- ==========================================================
-- 1. QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN (Module 1, 4, 7, 8)
-- ==========================================================
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100),
    FullName NVARCHAR(100),
    Role NVARCHAR(20) DEFAULT 'Farmer', -- Admin, Farmer
    IsVIP BIT DEFAULT 0,                -- 0: Free, 1: VIP
    Balance DECIMAL(18, 2) DEFAULT 0    -- Ví tiền hiện tại
);

-- ==========================================================
-- 2. QUẢN LÝ VÙNG TRỒNG & THÀNH PHỐ (Module 1, 3, 9)
-- ==========================================================
CREATE TABLE Cities (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    CityName NVARCHAR(50) NOT NULL UNIQUE -- Bắt buộc khớp tên folder AI
);

CREATE TABLE Zones (
    ZoneID INT IDENTITY(1,1) PRIMARY KEY,
    ZoneName NVARCHAR(100) NOT NULL,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    CityID INT NOT NULL,
    OwnerID INT,
    CONSTRAINT FK_Zones_Cities FOREIGN KEY (CityID) REFERENCES Cities(CityID),
    CONSTRAINT FK_Zones_Users FOREIGN KEY (OwnerID) REFERENCES Users(UserID)
);

-- ==========================================================
-- 3. DỮ LIỆU THỜI TIẾT (Module 2, 9)
-- ==========================================================
CREATE TABLE WeatherLogs (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ZoneID INT NOT NULL,
    RecordedAt DATETIME NOT NULL,
    DataType NVARCHAR(50) DEFAULT N'Quá khứ', -- N'Quá khứ' hoặc N'Dự báo AI'
    Temperature FLOAT,
    Humidity FLOAT,
    Rainfall FLOAT,
    Wind FLOAT,
    Radiation FLOAT,
    CONSTRAINT UC_Weather_Zone_Time UNIQUE (ZoneID, RecordedAt), -- Chống trùng lặp 
    CONSTRAINT FK_Weather_Zones FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID)
);
GO

-- ==========================================================
-- 4. CẤU HÌNH CÂY TRỒNG (Module 5)
-- ==========================================================
CREATE TABLE Crops (
    CropID INT IDENTITY(1,1) PRIMARY KEY,
    CropName NVARCHAR(50) NOT NULL,
    MinTemp FLOAT, MaxTemp FLOAT,     -- Ngưỡng nhiệt độ
    MinHumid FLOAT, MaxHumid FLOAT,   -- Ngưỡng độ ẩm
    ZoneID INT,
    CONSTRAINT FK_Crops_Zones FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID)
);

-- ==========================================================
-- 5. [MỚI] LỊCH SỬ CẢNH BÁO (Module 6)
-- ==========================================================
CREATE TABLE Alerts (
    AlertID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ZoneID INT,
    AlertTime DATETIME DEFAULT GETDATE(),
    Message NVARCHAR(MAX),
    IsRead BIT DEFAULT 0,
    CONSTRAINT FK_Alerts_Zones FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID)
);

-- ==========================================================
-- 6. [MỚI] LỊCH SỬ GIAO DỊCH (Module 8)
-- ==========================================================
CREATE TABLE Transactions (
    TransID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Amount DECIMAL(18, 2),
    TransDate DATETIME DEFAULT GETDATE(),
    Description NVARCHAR(200),
    CONSTRAINT FK_Trans_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- ==========================================================
-- 7. CHATBOT (Module 10)
-- ==========================================================
CREATE TABLE ChatbotGuidelines (
    GuidelineID INT IDENTITY(1,1) PRIMARY KEY,
    ConditionType NVARCHAR(20),
    ThresholdType NVARCHAR(10),
    AdviceText NVARCHAR(MAX)
);

-- ================= DỮ LIỆU MẪU (SEED DATA) =================
INSERT INTO Cities (CityName) VALUES ('DaNang'), ('HaNoi');
INSERT INTO Users (Username, Password, Role, IsVIP) VALUES ('admin', '123', 'Admin', 1), ('farmer1', '123', 'Farmer', 0);
INSERT INTO Zones (ZoneName, Latitude, Longitude, CityID, OwnerID) VALUES (N'Vườn Lan Cẩm Lệ', 16.05, 108.20, 1, 2);
GO

-- ================= DỮ LIỆU THỜI TIẾT MẪU =================
INSERT INTO WeatherLogs (ZoneID, RecordedAt, DataType, Temperature, Humidity, Rainfall, Wind, Radiation) VALUES
(1, '2026-01-20 08:00:00', N'Quá khứ', 24.6, 66, 0, 8.4, 692),
(1, '2026-01-21 08:00:00', N'Quá khứ', 22.9, 68, 0, 10.8, 548),
(1, '2026-01-22 08:00:00', N'Quá khứ', 21.5, 81, 0, 9.2, 465),
(1, '2026-01-23 08:00:00', N'Quá khứ', 20.6, 83, 0, 8.0, 383),
(1, '2026-01-24 08:00:00', N'Quá khứ', 21.9, 73, 0, 7.7, 518),
(1, '2026-01-25 08:00:00', N'Quá khứ', 23.7, 62, 0, 9.9, 692),
(1, '2026-01-26 08:00:00', N'Quá khứ', 24.5, 60, 0, 8.0, 698),
(1, '2026-01-27 08:00:00', N'Quá khứ', 23.8, 66, 0, 7.1, 561);
GO