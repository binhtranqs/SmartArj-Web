-- Tạo bảng Cities nếu chưa tồn tại
-- Script này an toàn, chỉ tạo nếu bảng chưa có

USE SmartArj_PRJSEM;
GO

PRINT '=== KIỂM TRA VÀ TẠO BẢNG CITIES ===';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities')
BEGIN
    PRINT 'Đang tạo bảng Cities...';
    
    CREATE TABLE Cities (
        CityID INT PRIMARY KEY IDENTITY(1,1),
        CityName NVARCHAR(100) NOT NULL,
        Region NVARCHAR(100),
        Latitude DECIMAL(9,6),
        Longitude DECIMAL(9,6),
        CreatedAt DATETIME DEFAULT GETDATE()
    );
    
    PRINT '✅ Đã tạo bảng Cities';
END
ELSE
BEGIN
    PRINT '⚠️ Bảng Cities đã tồn tại';
END
GO

-- Kiểm tra cấu trúc bảng
PRINT '';
PRINT '=== CẤU TRÚC BẢNG CITIES ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Cities'
ORDER BY ORDINAL_POSITION;
GO

-- Insert dữ liệu 10 cities nếu bảng trống
PRINT '';
PRINT '=== THÊM DỮ LIỆU 10 CITIES ===';

IF NOT EXISTS (SELECT 1 FROM Cities)
BEGIN
    PRINT 'Bảng Cities trống, đang thêm dữ liệu...';
    
    SET IDENTITY_INSERT Cities ON;
    
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude)
    VALUES 
        (1, N'Đà Nẵng', N'Miền Trung', 16.0544, 108.2022),
        (2, N'Hà Nội', N'Miền Bắc', 21.0285, 105.8542),
        (3, N'Hồ Chí Minh', N'Miền Nam', 10.8231, 106.6297),
        (4, N'Cần Thơ', N'Miền Nam', 10.0452, 105.7469),
        (5, N'Đà Lạt', N'Miền Nam', 11.9404, 108.4583),
        (6, N'Đắk Lắk', N'Tây Nguyên', 12.6667, 108.0500),
        (7, N'Hải Phòng', N'Miền Bắc', 20.8449, 106.6881),
        (8, N'Huế', N'Miền Trung', 16.4637, 107.5909),
        (9, N'Nha Trang', N'Miền Trung', 12.2388, 109.1967),
        (10, N'Sapa', N'Miền Bắc', 22.3364, 103.8438);
    
    SET IDENTITY_INSERT Cities OFF;
    
    PRINT '✅ Đã thêm 10 cities';
END
ELSE
BEGIN
    PRINT '⚠️ Bảng Cities đã có dữ liệu:';
    SELECT CityID, CityName, Region FROM Cities ORDER BY CityID;
END
GO

PRINT '';
PRINT '✅ HOÀN TẤT! Bảng Cities đã sẵn sàng.';
