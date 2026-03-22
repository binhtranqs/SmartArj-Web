-- ============================================================
-- FIX: Tạo và seed dữ liệu cho Marketplace
-- Chạy script này trong SSMS hoặc Azure Data Studio
-- Database: SmartAgri_PRJ301
-- ============================================================

USE SmartAgri_PRJ301;
GO

-- ============================================================
-- 1. Regions
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Regions')
BEGIN
    CREATE TABLE Regions (
        RegionID   INT IDENTITY(1,1) PRIMARY KEY,
        RegionName NVARCHAR(100) NOT NULL,
        Province   NVARCHAR(100) NULL,
        CreatedAt  DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created: Regions';
END
GO

IF NOT EXISTS (SELECT 1 FROM Regions)
BEGIN
    INSERT INTO Regions (RegionName, Province) VALUES
    (N'Gia Lai',   N'Tây Nguyên'),
    (N'Đắk Lắk',  N'Tây Nguyên'),
    (N'Lâm Đồng', N'Tây Nguyên'),
    (N'Đắk Nông', N'Tây Nguyên'),
    (N'Kon Tum',  N'Tây Nguyên'),
    (N'Đồng Nai', N'Đông Nam Bộ'),
    (N'Bình Phước',N'Đông Nam Bộ'),
    (N'Bình Thuận',N'Đông Nam Bộ'),
    (N'Hậu Giang', N'Đồng bằng sông Cửu Long'),
    (N'An Giang',  N'Đồng bằng sông Cửu Long'),
    (N'Tiền Giang',N'Đồng bằng sông Cửu Long'),
    (N'Hà Nội',   N'Đồng bằng sông Hồng'),
    (N'Hải Dương', N'Đồng bằng sông Hồng'),
    (N'Đà Nẵng',  N'Miền Trung'),
    (N'Nghệ An',  N'Miền Trung');
    PRINT 'Seeded: Regions (15 records)';
END
GO

-- ============================================================
-- 2. MarketPrices
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MarketPrices')
BEGIN
    CREATE TABLE MarketPrices (
        PriceID     INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(200) NOT NULL,
        RegionName  NVARCHAR(200) NULL,
        Price       DECIMAL(18,2) NOT NULL,
        Unit        NVARCHAR(50)  NOT NULL DEFAULT N'đ/kg',
        CrawledAt   DATETIME NOT NULL DEFAULT GETDATE(),
        SourceURL   NVARCHAR(500) NULL
    );
    PRINT 'Created: MarketPrices';
END
GO

-- Xóa data cũ và insert mới (để đảm bảo có data)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MarketPrices')
BEGIN
    -- Chỉ insert nếu bảng đang rỗng
    IF NOT EXISTS (SELECT 1 FROM MarketPrices)
    BEGIN
        INSERT INTO MarketPrices (ProductName, RegionName, Price, Unit, SourceURL) VALUES
        (N'Cà phê nhân xô',  N'Gia Lai',    97100,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Cà phê nhân xô',  N'Đắk Lắk',   96900,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Cà phê nhân xô',  N'Lâm Đồng',   97000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Hồ tiêu',         N'Gia Lai',    155000, N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Hồ tiêu',         N'Đắk Lắk',   154500, N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Hồ tiêu',         N'Đắk Nông',   154000, N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Cao su',          N'Bình Phước',  18500,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Cao su',          N'Đồng Nai',    18200,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Sầu riêng',       N'Đắk Lắk',    85000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Sầu riêng',       N'Tiền Giang',  90000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Sầu riêng',       N'Lâm Đồng',    82000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Thanh long',      N'Bình Thuận',  12000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Thanh long',      N'Long An',     11500,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Mít Thái',        N'Đồng Nai',    18000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Chanh leo',       N'Gia Lai',     25000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Bơ',              N'Đắk Lắk',    22000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Bơ',              N'Lâm Đồng',    20000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Xoài cát Hòa Lộc',N'Tiền Giang', 45000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Xoài',            N'An Giang',    28000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Lúa gạo',         N'An Giang',     8200,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Lúa gạo',         N'Hậu Giang',    8000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Dừa khô',         N'Tiền Giang',  11500,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Ớt đỏ',           N'Gia Lai',     35000,  N'đ/kg', N'https://nongnghiepmoitruong.vn'),
        (N'Chuối tiêu',      N'Đồng Nai',    18000,  N'đ/kg', N'https://nongnghiepmoitruong.vn');
        PRINT 'Seeded: MarketPrices (24 records)';
    END
    ELSE
        PRINT 'MarketPrices already has data - skipped';
END
GO

-- ============================================================
-- 3. CrawlerLogs
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CrawlerLogs')
BEGIN
    CREATE TABLE CrawlerLogs (
        LogID        INT IDENTITY(1,1) PRIMARY KEY,
        RunAt        DATETIME NOT NULL DEFAULT GETDATE(),
        Status       NVARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
        ItemsCrawled INT NULL DEFAULT 0,
        Duration     INT NULL,
        ErrorMsg     NVARCHAR(MAX) NULL
    );
    PRINT 'Created: CrawlerLogs';
END
GO

-- ============================================================
-- 4. Listings (Sản phẩm của Farmer)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Listings')
BEGIN
    CREATE TABLE Listings (
        ListingID   INT IDENTITY(1,1) PRIMARY KEY,
        FarmerID    INT NOT NULL REFERENCES Users(UserID),
        ProductName NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        RegionID    INT NULL REFERENCES Regions(RegionID),
        Price       DECIMAL(18,2) NOT NULL,
        Unit        NVARCHAR(50) NOT NULL DEFAULT N'kg',
        Quantity    DECIMAL(18,2) NOT NULL DEFAULT 0,
        ImageURL    NVARCHAR(500) NULL,
        Status      NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        CreatedAt   DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt   DATETIME NULL
    );
    PRINT 'Created: Listings';
END
GO

-- ============================================================
-- 5. Orders
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
    PRINT 'Created: Orders';
END
GO

-- ============================================================
-- 6. OrderItems
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
    PRINT 'Created: OrderItems';
END
GO

-- ============================================================
-- 7. CartItems
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
    PRINT 'Created: CartItems';
END
GO

-- ============================================================
-- 8. MarketChatMessages
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
    PRINT 'Created: MarketChatMessages';
END
GO

-- ============================================================
-- VERIFY
-- ============================================================
SELECT 'MarketPrices' AS [Table], COUNT(*) AS [Rows] FROM MarketPrices
UNION ALL
SELECT 'Regions',  COUNT(*) FROM Regions
UNION ALL
SELECT 'Listings', COUNT(*) FROM Listings
UNION ALL
SELECT 'CrawlerLogs', COUNT(*) FROM CrawlerLogs;

PRINT '=== fix_marketplace_data.sql DONE ===';
GO
