-- ============================================================
-- CHECK: Cấu trúc thực tế của các bảng trong database
-- Chạy script này để tôi biết cột nào đang tồn tại
-- ============================================================

USE SmartAgri_PRJ301;
GO

-- 1. Liệt kê TẤT CẢ bảng đang tồn tại
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

-- 2. Cấu trúc bảng Regions (nếu tồn tại)
IF OBJECT_ID('Regions','U') IS NOT NULL
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Regions'
    ORDER BY ORDINAL_POSITION;
GO

-- 3. Cấu trúc bảng MarketPrices (nếu tồn tại)
IF OBJECT_ID('MarketPrices','U') IS NOT NULL
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'MarketPrices'
    ORDER BY ORDINAL_POSITION;
GO

-- 4. Cấu trúc bảng Listings (nếu tồn tại)
IF OBJECT_ID('Listings','U') IS NOT NULL
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Listings'
    ORDER BY ORDINAL_POSITION;
GO

-- 5. Sample data trong MarketPrices (nếu có)
IF OBJECT_ID('MarketPrices','U') IS NOT NULL
BEGIN
    SELECT TOP 3 * FROM MarketPrices;
    SELECT COUNT(*) AS TotalMarketPrices FROM MarketPrices;
END
GO

-- 6. Sample data trong Regions (nếu có)
IF OBJECT_ID('Regions','U') IS NOT NULL
BEGIN
    SELECT TOP 3 * FROM Regions;
    SELECT COUNT(*) AS TotalRegions FROM Regions;
END
GO
