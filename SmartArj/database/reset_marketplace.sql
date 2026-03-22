-- ============================================================
-- SMART DROP: Tự động tìm và xóa tất cả FK references
-- trước khi DROP các bảng bị chặn
-- ============================================================

USE SmartAgri_PRJ301;
GO

-- ============================================================
-- BƯỚC 1: Xem toàn bộ bảng + FK đang reference Listings, Orders, Regions
-- (Chạy SELECT này trước để biết FK nào đang block)
-- ============================================================
SELECT 
    fk.name          AS FK_Constraint_Name,
    tp.name          AS Parent_Table,
    tr.name          AS Referenced_Table,
    cp.name          AS Parent_Column,
    cr.name          AS Referenced_Column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables   tp ON fk.parent_object_id      = tp.object_id
JOIN sys.tables   tr ON fk.referenced_object_id  = tr.object_id
JOIN sys.columns  cp ON fkc.parent_object_id     = cp.object_id AND fkc.parent_column_id   = cp.column_id
JOIN sys.columns  cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE tr.name IN ('Listings', 'Orders', 'Regions', 'Users')
ORDER BY tr.name, tp.name;
GO

-- ============================================================
-- BƯỚC 2: Tự động DROP tất cả FK constraints referencing Listings/Orders/Regions
-- ============================================================
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 
    N'ALTER TABLE ' + QUOTENAME(tp.name) + 
    N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N'; ' + CHAR(10)
FROM sys.foreign_keys fk
JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tr.name IN ('Listings', 'Orders', 'Regions');

IF LEN(@sql) > 0
BEGIN
    PRINT 'Dropping FK constraints:';
    PRINT @sql;
    EXEC sp_executesql @sql;
    PRINT 'All blocking FKs dropped.';
END
ELSE
    PRINT 'No blocking FKs found.';
GO

-- ============================================================
-- BƯỚC 3: DROP các bảng theo thứ tự (sau khi đã xóa FKs)
-- ============================================================
IF OBJECT_ID('OrderItems',        'U') IS NOT NULL DROP TABLE OrderItems;
IF OBJECT_ID('CartItems',         'U') IS NOT NULL DROP TABLE CartItems;
IF OBJECT_ID('MarketChatMessages','U') IS NOT NULL DROP TABLE MarketChatMessages;
IF OBJECT_ID('Reviews',           'U') IS NOT NULL DROP TABLE Reviews;
IF OBJECT_ID('Listings',          'U') IS NOT NULL DROP TABLE Listings;
IF OBJECT_ID('Orders',            'U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Regions',           'U') IS NOT NULL DROP TABLE Regions;
PRINT 'All target tables dropped.';
GO

-- ============================================================
-- BƯỚC 4: Kiểm tra lại — các bảng này phải KHÔNG còn tồn tại
-- ============================================================
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Regions','Listings','Orders','OrderItems','CartItems','MarketChatMessages','Reviews')
ORDER BY TABLE_NAME;
-- Nếu SELECT này trả về rỗng → OK, tiếp tục bước 5
-- Nếu vẫn còn bảng → báo lại tên bảng đó
GO

-- ============================================================
-- BƯỚC 5: TẠO LẠI đúng schema
-- ============================================================

-- Regions
CREATE TABLE Regions (
    RegionID   INT IDENTITY(1,1) PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL,
    Province   NVARCHAR(100) NULL,
    CreatedAt  DATETIME NOT NULL DEFAULT GETDATE()
);
PRINT 'Created: Regions';
GO

-- Listings
CREATE TABLE Listings (
    ListingID   INT IDENTITY(1,1) PRIMARY KEY,
    FarmerID    INT NOT NULL REFERENCES Users(UserID),
    ProductName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    RegionID    INT NULL REFERENCES Regions(RegionID),
    Price       DECIMAL(18,2) NOT NULL,
    Unit        NVARCHAR(50)  NOT NULL DEFAULT N'kg',
    Quantity    DECIMAL(18,2) NOT NULL DEFAULT 0,
    ImageURL    NVARCHAR(500) NULL,
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    CreatedAt   DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt   DATETIME NULL
);
PRINT 'Created: Listings';
GO

-- Orders
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    BuyerID     INT NOT NULL REFERENCES Users(UserID),
    FarmerID    INT NOT NULL REFERENCES Users(UserID),
    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    Note        NVARCHAR(500) NULL,
    ShipAddress NVARCHAR(500) NULL,
    CreatedAt   DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt   DATETIME NULL
);
PRINT 'Created: Orders';
GO

-- OrderItems
CREATE TABLE OrderItems (
    ItemID    INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT NOT NULL REFERENCES Orders(OrderID),
    ListingID INT NOT NULL REFERENCES Listings(ListingID),
    Quantity  DECIMAL(18,2) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL
);
PRINT 'Created: OrderItems';
GO

-- CartItems
CREATE TABLE CartItems (
    CartID    INT IDENTITY(1,1) PRIMARY KEY,
    BuyerID   INT NOT NULL REFERENCES Users(UserID),
    ListingID INT NOT NULL REFERENCES Listings(ListingID),
    Quantity  DECIMAL(18,2) NOT NULL DEFAULT 1,
    AddedAt   DATETIME NOT NULL DEFAULT GETDATE()
);
PRINT 'Created: CartItems';
GO

-- Reviews
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
PRINT 'Created: Reviews';
GO

-- MarketChatMessages
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
GO

-- ============================================================
-- BƯỚC 6: SEED DATA
-- ============================================================

INSERT INTO Regions (RegionName, Province) VALUES
(N'Gia Lai',     N'Tây Nguyên'),
(N'Đắk Lắk',    N'Tây Nguyên'),
(N'Lâm Đồng',   N'Tây Nguyên'),
(N'Đắk Nông',   N'Tây Nguyên'),
(N'Kon Tum',    N'Tây Nguyên'),
(N'Đồng Nai',   N'Đông Nam Bộ'),
(N'Bình Phước', N'Đông Nam Bộ'),
(N'Bình Thuận', N'Đông Nam Bộ'),
(N'Hậu Giang',  N'Đồng bằng sông Cửu Long'),
(N'An Giang',   N'Đồng bằng sông Cửu Long'),
(N'Tiền Giang', N'Đồng bằng sông Cửu Long'),
(N'Long An',    N'Đồng bằng sông Cửu Long'),
(N'Hà Nội',     N'Đồng bằng sông Hồng'),
(N'Hải Dương',  N'Đồng bằng sông Hồng'),
(N'Đà Nẵng',    N'Miền Trung'),
(N'Nghệ An',    N'Miền Trung');
PRINT 'Seeded: Regions (16 records)';
GO

-- MarketPrices đã có rồi, chỉ bổ sung nếu chưa đủ
IF (SELECT COUNT(*) FROM MarketPrices) < 10
BEGIN
    INSERT INTO MarketPrices (ProductName, RegionName, Price, Unit, SourceURL) VALUES
    (N'Cà phê nhân xô',   N'Gia Lai',     97100, N'đ/kg', N'static-seed'),
    (N'Cà phê nhân xô',   N'Đắk Lắk',    96900, N'đ/kg', N'static-seed'),
    (N'Hồ tiêu',          N'Gia Lai',    155000, N'đ/kg', N'static-seed'),
    (N'Hồ tiêu',          N'Đắk Lắk',   154500, N'đ/kg', N'static-seed'),
    (N'Sầu riêng',        N'Đắk Lắk',    85000, N'đ/kg', N'static-seed'),
    (N'Thanh long',       N'Bình Thuận',  12000, N'đ/kg', N'static-seed'),
    (N'Cao su',           N'Bình Phước',  18500, N'đ/kg', N'static-seed'),
    (N'Bơ',               N'Đắk Lắk',    22000, N'đ/kg', N'static-seed');
    PRINT 'Seeded: MarketPrices (extra)';
END
ELSE
    PRINT 'MarketPrices already has enough data.';
GO

-- ============================================================
-- BƯỚC 7: VERIFY CUỐI
-- ============================================================
SELECT TABLE_NAME,
       (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c 
        WHERE c.TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_NAME IN ('Regions','MarketPrices','Listings','Orders','CartItems','CrawlerLogs')
ORDER BY TABLE_NAME;

SELECT 'MarketPrices' AS [Table], COUNT(*) AS [Rows] FROM MarketPrices
UNION ALL SELECT 'Regions', COUNT(*) FROM Regions
UNION ALL SELECT 'Listings', COUNT(*) FROM Listings;

PRINT '=== SUCCESS: All marketplace tables ready! ===';
GO
