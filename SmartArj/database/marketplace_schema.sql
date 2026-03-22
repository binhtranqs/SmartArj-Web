-- ============================================================
-- Smart Agriculture Marketplace Schema
-- Database: SmartAgri_PRJ301
-- Chạy script này trong SQL Server Management Studio
-- KHÔNG ảnh hưởng đến các bảng cũ
-- ============================================================

USE SmartAgri_PRJ301;
GO

-- ============================================================
-- 1. Regions (Vùng địa lý trồng trọt)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Regions')
BEGIN
    CREATE TABLE Regions (
        RegionID   INT IDENTITY(1,1) PRIMARY KEY,
        RegionName NVARCHAR(100) NOT NULL,
        Province   NVARCHAR(100) NULL,
        CreatedAt  DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table Regions';
END
ELSE
    PRINT 'Table Regions already exists';
GO

-- Insert sample regions
IF NOT EXISTS (SELECT 1 FROM Regions)
BEGIN
    INSERT INTO Regions (RegionName, Province) VALUES
    (N'Gia Lai', N'Tây Nguyên'),
    (N'Đắk Lắk', N'Tây Nguyên'),
    (N'Lâm Đồng', N'Tây Nguyên'),
    (N'Đắk Nông', N'Tây Nguyên'),
    (N'Kon Tum', N'Tây Nguyên'),
    (N'Đồng Nai', N'Đông Nam Bộ'),
    (N'Bình Phước', N'Đông Nam Bộ'),
    (N'Hậu Giang', N'Đồng bằng sông Cửu Long'),
    (N'An Giang', N'Đồng bằng sông Cửu Long'),
    (N'Tiền Giang', N'Đồng bằng sông Cửu Long'),
    (N'Hà Nội', N'Đồng bằng sông Hồng'),
    (N'Hải Dương', N'Đồng bằng sông Hồng'),
    (N'Đà Nẵng', N'Miền Trung'),
    (N'Nghệ An', N'Miền Trung'),
    (N'Quảng Nam', N'Miền Trung');
    PRINT 'Inserted sample regions';
END
GO

-- ============================================================
-- 2. MarketPrices (Giá thu thập từ crawler)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MarketPrices')
BEGIN
    CREATE TABLE MarketPrices (
        PriceID      INT IDENTITY(1,1) PRIMARY KEY,
        ProductName  NVARCHAR(200) NOT NULL,
        RegionName   NVARCHAR(200) NULL,
        Price        DECIMAL(18,2) NOT NULL,
        Unit         NVARCHAR(50)  NOT NULL DEFAULT N'đ/kg',
        CrawledAt    DATETIME NOT NULL DEFAULT GETDATE(),
        SourceURL    NVARCHAR(500) NULL
    );
    PRINT 'Created table MarketPrices';
END
ELSE
    PRINT 'Table MarketPrices already exists';
GO

-- Insert sample market prices (fallback khi chưa crawl được)
IF NOT EXISTS (SELECT 1 FROM MarketPrices)
BEGIN
    INSERT INTO MarketPrices (ProductName, RegionName, Price, Unit, SourceURL) VALUES
    (N'Cà phê nhân xô', N'Gia Lai', 97100, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Cà phê nhân xô', N'Đắk Lắk', 96900, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Cà phê nhân xô', N'Lâm Đồng', 97000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Hồ tiêu', N'Gia Lai', 155000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Hồ tiêu', N'Đắk Lắk', 154500, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Cao su', N'Bình Phước', 18500, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Sầu riêng', N'Đắk Lắk', 85000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Sầu riêng', N'Tiền Giang', 90000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Thanh long', N'Bình Thuận', 12000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Mít Thái', N'Đồng Nai', 18000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Chanh leo', N'Gia Lai', 25000, N'đ/kg', 'https://nongnghiepmoitruong.vn'),
    (N'Bơ', N'Đắk Lắk', 22000, N'đ/kg', 'https://nongnghiepmoitruong.vn');
    PRINT 'Inserted sample market prices';
END
GO

-- ============================================================
-- 3. Listings (Sản phẩm của Farmer)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Listings')
BEGIN
    CREATE TABLE Listings (
        ListingID    INT IDENTITY(1,1) PRIMARY KEY,
        FarmerID     INT NOT NULL REFERENCES Users(UserID),
        ProductName  NVARCHAR(200) NOT NULL,
        Description  NVARCHAR(MAX) NULL,
        RegionID     INT NULL REFERENCES Regions(RegionID),
        Price        DECIMAL(18,2) NOT NULL,
        Unit         NVARCHAR(50) NOT NULL DEFAULT N'kg',
        Quantity     DECIMAL(18,2) NOT NULL DEFAULT 0,
        ImageURL     NVARCHAR(MAX) NULL,
        Status       NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        CreatedAt    DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt    DATETIME NULL
    );
    PRINT 'Created table Listings';
END
ELSE
    PRINT 'Table Listings already exists';
GO

-- ============================================================
-- 4. Orders
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Orders')
BEGIN
    CREATE TABLE Orders (
        OrderID     INT IDENTITY(1,1) PRIMARY KEY,
        BuyerID     INT NOT NULL REFERENCES Users(UserID),
        FarmerID    INT NOT NULL REFERENCES Users(UserID),
        TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        Status      NVARCHAR(20) NOT NULL DEFAULT 'PENDING',
        Note        NVARCHAR(500) NULL,
        ShipAddress NVARCHAR(500) NULL,
        CreatedAt   DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt   DATETIME NULL
    );
    PRINT 'Created table Orders';
END
ELSE
    PRINT 'Table Orders already exists';
GO

-- ============================================================
-- 5. OrderItems
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'OrderItems')
BEGIN
    CREATE TABLE OrderItems (
        ItemID    INT IDENTITY(1,1) PRIMARY KEY,
        OrderID   INT NOT NULL REFERENCES Orders(OrderID),
        ListingID INT NOT NULL REFERENCES Listings(ListingID),
        Quantity  DECIMAL(18,2) NOT NULL,
        UnitPrice DECIMAL(18,2) NOT NULL
    );
    PRINT 'Created table OrderItems';
END
ELSE
    PRINT 'Table OrderItems already exists';
GO

-- ============================================================
-- 6. CartItems
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CartItems')
BEGIN
    CREATE TABLE CartItems (
        CartID    INT IDENTITY(1,1) PRIMARY KEY,
        BuyerID   INT NOT NULL REFERENCES Users(UserID),
        ListingID INT NOT NULL REFERENCES Listings(ListingID),
        Quantity  DECIMAL(18,2) NOT NULL DEFAULT 1,
        AddedAt   DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table CartItems';
END
ELSE
    PRINT 'Table CartItems already exists';
GO

-- ============================================================
-- 7. Reviews
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Reviews')
BEGIN
    CREATE TABLE Reviews (
        ReviewID  INT IDENTITY(1,1) PRIMARY KEY,
        BuyerID   INT NOT NULL REFERENCES Users(UserID),
        FarmerID  INT NOT NULL REFERENCES Users(UserID),
        ListingID INT NULL REFERENCES Listings(ListingID),
        OrderID   INT NULL REFERENCES Orders(OrderID),
        Rating    INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
        Comment   NVARCHAR(MAX) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table Reviews';
END
ELSE
    PRINT 'Table Reviews already exists';
GO

-- ============================================================
-- 8. MarketChatMessages (Buyer <-> Farmer chat)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MarketChatMessages')
BEGIN
    CREATE TABLE MarketChatMessages (
        MsgID      INT IDENTITY(1,1) PRIMARY KEY,
        SenderID   INT NOT NULL REFERENCES Users(UserID),
        ReceiverID INT NOT NULL REFERENCES Users(UserID),
        ListingID  INT NULL REFERENCES Listings(ListingID),
        Message    NVARCHAR(MAX) NOT NULL,
        IsRead     BIT NOT NULL DEFAULT 0,
        SentAt     DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created table MarketChatMessages';
END
ELSE
    PRINT 'Table MarketChatMessages already exists';
GO

-- ============================================================
-- 9. CrawlerLogs (Log cho admin)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CrawlerLogs')
BEGIN
    CREATE TABLE CrawlerLogs (
        LogID       INT IDENTITY(1,1) PRIMARY KEY,
        RunAt       DATETIME NOT NULL DEFAULT GETDATE(),
        Status      NVARCHAR(20) NOT NULL DEFAULT 'SUCCESS', -- SUCCESS|FAILED
        ItemsCrawled INT NULL DEFAULT 0,
        Duration    INT NULL,  -- milliseconds
        ErrorMsg    NVARCHAR(MAX) NULL
    );
    PRINT 'Created table CrawlerLogs';
END
ELSE
    PRINT 'Table CrawlerLogs already exists';
GO

PRINT 'Marketplace schema migration DONE!';
GO
