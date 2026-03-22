-- Fix Foreign Key Constraint Issue
-- Vấn đề: Foreign key vẫn trỏ đến bảng CityID cũ thay vì Cities

USE SmartAgri_PRJ301;
GO

PRINT '=== KIỂM TRA TÌNH TRẠNG HIỆN TẠI ===';
PRINT '';

-- Kiểm tra các bảng tồn tại
PRINT '1. Các bảng liên quan:';
SELECT 
    name AS TableName,
    create_date
FROM sys.tables 
WHERE name IN ('Cities', 'CityID', 'Zones')
ORDER BY name;
GO

-- Kiểm tra foreign key constraints
PRINT '';
PRINT '2. Foreign key constraints của Zones:';
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc 
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'Zones';
GO

PRINT '';
PRINT '=== FIX FOREIGN KEY ===';
PRINT '';

-- Drop foreign key constraint cũ
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Zones_Cities')
BEGIN
    ALTER TABLE Zones DROP CONSTRAINT FK_Zones_Cities;
    PRINT '✅ Đã xóa foreign key constraint cũ';
END
GO

-- Nếu có bảng CityID cũ, copy data sang Cities rồi xóa
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CityID')
BEGIN
    PRINT 'Tìm thấy bảng CityID cũ, đang xử lý...';
    
    -- Kiểm tra xem Cities có data chưa
    DECLARE @citiesCount INT;
    SELECT @citiesCount = COUNT(*) FROM Cities;
    
    IF @citiesCount = 0
    BEGIN
        -- Copy data từ CityID sang Cities
        INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude, CreatedAt)
        SELECT CityID, CityName, Region, Latitude, Longitude, CreatedAt
        FROM CityID;
        PRINT '✅ Đã copy data từ CityID sang Cities';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Bảng Cities đã có data, bỏ qua copy';
    END
    
    -- Drop bảng CityID cũ
    DROP TABLE CityID;
    PRINT '✅ Đã xóa bảng CityID cũ';
END
ELSE
BEGIN
    PRINT '⚠️ Không tìm thấy bảng CityID cũ';
END
GO

-- Tạo lại foreign key constraint mới trỏ đến Cities
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Zones_Cities')
BEGIN
    ALTER TABLE Zones
    ADD CONSTRAINT FK_Zones_Cities
    FOREIGN KEY (CityID) REFERENCES Cities(CityID);
    PRINT '✅ Đã tạo foreign key constraint mới trỏ đến Cities';
END
GO

PRINT '';
PRINT '=== BÂY GIỜ CẬP NHẬT ZONE CITYID ===';
PRINT '';

-- Update Zone 1 → Đà Nẵng
UPDATE Zones SET CityID = 1 WHERE ZoneID = 1;
PRINT '✅ Zone 1 → CityID = 1 (Đà Nẵng)';

-- Update Zone 5 → Hà Nội  
UPDATE Zones SET CityID = 2 WHERE ZoneID = 5;
PRINT '✅ Zone 5 → CityID = 2 (Hà Nội)';
GO

PRINT '';
PRINT '=== KẾT QUẢ CUỐI CÙNG ===';
SELECT 
    z.ZoneID,
    z.ZoneName,
    z.CityID,
    c.CityName
FROM Zones z
LEFT JOIN Cities c ON z.CityID = c.CityID
ORDER BY z.ZoneID;
GO

PRINT '';
PRINT '✅✅✅ HOÀN TẤT! ✅✅✅';
PRINT 'Bây giờ có thể test forecast API!';
