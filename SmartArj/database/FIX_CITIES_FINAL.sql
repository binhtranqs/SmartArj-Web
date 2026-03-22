-- SCRIPT CUỐI CÙNG: Sửa Cities một lần dứt điểm
-- Chạy toàn bộ script này trong SSMS (chọn tất cả và Execute)

USE SmartArj_PRJSEM;
GO

PRINT '========================================';
PRINT 'BƯỚC 1: KIỂM TRA DỮ LIỆU HIỆN TẠI';
PRINT '========================================';
SELECT CityID, CityName, Region, Latitude, Longitude FROM Cities ORDER BY CityID;
GO

PRINT '';
PRINT '========================================';
PRINT 'BƯỚC 2: CẬP NHẬT CITYID 1 VÀ 2';
PRINT '========================================';

-- Cập nhật CityID 1
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 1)
BEGIN
    UPDATE Cities
    SET 
        CityName = N'Đà Nẵng',
        Region = N'Miền Trung',
        Latitude = 16.0544,
        Longitude = 108.2022,
        CreatedAt = ISNULL(CreatedAt, GETDATE())
    WHERE CityID = 1;
    PRINT '✅ Đã cập nhật CityID 1 (Đà Nẵng)';
END
ELSE
BEGIN
    SET IDENTITY_INSERT Cities ON;
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude, CreatedAt)
    VALUES (1, N'Đà Nẵng', N'Miền Trung', 16.0544, 108.2022, GETDATE());
    SET IDENTITY_INSERT Cities OFF;
    PRINT '✅ Đã thêm CityID 1 (Đà Nẵng)';
END
GO

-- Cập nhật CityID 2
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 2)
BEGIN
    UPDATE Cities
    SET 
        CityName = N'Hà Nội',
        Region = N'Miền Bắc',
        Latitude = 21.0285,
        Longitude = 105.8542,
        CreatedAt = ISNULL(CreatedAt, GETDATE())
    WHERE CityID = 2;
    PRINT '✅ Đã cập nhật CityID 2 (Hà Nội)';
END
ELSE
BEGIN
    SET IDENTITY_INSERT Cities ON;
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude, CreatedAt)
    VALUES (2, N'Hà Nội', N'Miền Bắc', 21.0285, 105.8542, GETDATE());
    SET IDENTITY_INSERT Cities OFF;
    PRINT '✅ Đã thêm CityID 2 (Hà Nội)';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'BƯỚC 3: THÊM/CẬP NHẬT 8 CITIES CÒN LẠI';
PRINT '========================================';

SET IDENTITY_INSERT Cities ON;
GO

-- CityID 3: Hồ Chí Minh
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 3)
    UPDATE Cities SET CityName = N'Hồ Chí Minh', Region = N'Miền Nam', Latitude = 10.8231, Longitude = 106.6297 WHERE CityID = 3;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (3, N'Hồ Chí Minh', N'Miền Nam', 10.8231, 106.6297);

-- CityID 4: Cần Thơ
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 4)
    UPDATE Cities SET CityName = N'Cần Thơ', Region = N'Miền Nam', Latitude = 10.0452, Longitude = 105.7469 WHERE CityID = 4;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (4, N'Cần Thơ', N'Miền Nam', 10.0452, 105.7469);

-- CityID 5: Đà Lạt
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 5)
    UPDATE Cities SET CityName = N'Đà Lạt', Region = N'Miền Nam', Latitude = 11.9404, Longitude = 108.4583 WHERE CityID = 5;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (5, N'Đà Lạt', N'Miền Nam', 11.9404, 108.4583);

-- CityID 6: Đắk Lắk
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 6)
    UPDATE Cities SET CityName = N'Đắk Lắk', Region = N'Tây Nguyên', Latitude = 12.6667, Longitude = 108.0500 WHERE CityID = 6;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (6, N'Đắk Lắk', N'Tây Nguyên', 12.6667, 108.0500);

-- CityID 7: Hải Phòng
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 7)
    UPDATE Cities SET CityName = N'Hải Phòng', Region = N'Miền Bắc', Latitude = 20.8449, Longitude = 106.6881 WHERE CityID = 7;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (7, N'Hải Phòng', N'Miền Bắc', 20.8449, 106.6881);

-- CityID 8: Huế
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 8)
    UPDATE Cities SET CityName = N'Huế', Region = N'Miền Trung', Latitude = 16.4637, Longitude = 107.5909 WHERE CityID = 8;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (8, N'Huế', N'Miền Trung', 16.4637, 107.5909);

-- CityID 9: Nha Trang
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 9)
    UPDATE Cities SET CityName = N'Nha Trang', Region = N'Miền Trung', Latitude = 12.2388, Longitude = 109.1967 WHERE CityID = 9;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (9, N'Nha Trang', N'Miền Trung', 12.2388, 109.1967);

-- CityID 10: Sapa
IF EXISTS (SELECT 1 FROM Cities WHERE CityID = 10)
    UPDATE Cities SET CityName = N'Sapa', Region = N'Miền Bắc', Latitude = 22.3364, Longitude = 103.8438 WHERE CityID = 10;
ELSE
    INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude) VALUES (10, N'Sapa', N'Miền Bắc', 22.3364, 103.8438);

GO
SET IDENTITY_INSERT Cities OFF;
GO

PRINT '✅ Đã xử lý tất cả 10 cities';

PRINT '';
PRINT '========================================';
PRINT 'KẾT QUẢ CUỐI CÙNG';
PRINT '========================================';
SELECT 
    CityID,
    CityName,
    Region,
    Latitude,
    Longitude,
    CreatedAt
FROM Cities 
ORDER BY CityID;
GO

SELECT COUNT(*) AS TotalCities FROM Cities;
GO

PRINT '';
PRINT '✅✅✅ HOÀN TẤT! TẤT CẢ 10 CITIES ĐÃ CÓ ĐẦY ĐỦ DỮ LIỆU ✅✅✅';
