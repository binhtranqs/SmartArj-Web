-- Script An Toàn: Cập nhật Cities thay vì xóa
-- Giải pháp: UPDATE dữ liệu NULL thành dữ liệu đầy đủ

USE SmartArj_PRJSEM;
GO

PRINT '=== TRƯỚC KHI CẬP NHẬT ===';
SELECT CityID, CityName, Region, Latitude, Longitude FROM Cities WHERE CityID IN (1, 2);
GO

-- Cập nhật CityID 1 (Đà Nẵng)
UPDATE Cities
SET 
    CityName = N'Đà Nẵng',
    Region = N'Miền Trung',
    Latitude = 16.0544,
    Longitude = 108.2022,
    CreatedAt = CASE WHEN CreatedAt IS NULL THEN GETDATE() ELSE CreatedAt END
WHERE CityID = 1;

PRINT '✅ Đã cập nhật CityID 1 (Đà Nẵng)';
GO

-- Cập nhật CityID 2 (Hà Nội)
UPDATE Cities
SET 
    CityName = N'Hà Nội',
    Region = N'Miền Bắc',
    Latitude = 21.0285,
    Longitude = 105.8542,
    CreatedAt = CASE WHEN CreatedAt IS NULL THEN GETDATE() ELSE CreatedAt END
WHERE CityID = 2;

PRINT '✅ Đã cập nhật CityID 2 (Hà Nội)';
GO

PRINT '';
PRINT '=== SAU KHI CẬP NHẬT ===';
SELECT CityID, CityName, Region, Latitude, Longitude FROM Cities WHERE CityID IN (1, 2);
GO

-- Bây giờ insert các cities còn lại (3-10) nếu chưa có
PRINT '';
PRINT '=== THÊM CÁC CITIES CÒN LẠI ===';

SET IDENTITY_INSERT Cities ON;
GO

MERGE INTO Cities AS target
USING (VALUES
    (3, N'Hồ Chí Minh', N'Miền Nam', 10.8231, 106.6297),
    (4, N'Cần Thơ', N'Miền Nam', 10.0452, 105.7469),
    (5, N'Đà Lạt', N'Miền Nam', 11.9404, 108.4583),
    (6, N'Đắk Lắk', N'Tây Nguyên', 12.6667, 108.0500),
    (7, N'Hải Phòng', N'Miền Bắc', 20.8449, 106.6881),
    (8, N'Huế', N'Miền Trung', 16.4637, 107.5909),
    (9, N'Nha Trang', N'Miền Trung', 12.2388, 109.1967),
    (10, N'Sapa', N'Miền Bắc', 22.3364, 103.8438)
) AS source (CityID, CityName, Region, Latitude, Longitude)
ON target.CityID = source.CityID
WHEN MATCHED THEN
    UPDATE SET 
        CityName = source.CityName,
        Region = source.Region,
        Latitude = source.Latitude,
        Longitude = source.Longitude
WHEN NOT MATCHED THEN
    INSERT (CityID, CityName, Region, Latitude, Longitude)
    VALUES (source.CityID, source.CityName, source.Region, source.Latitude, source.Longitude);
GO

SET IDENTITY_INSERT Cities OFF;
GO

PRINT '';
PRINT '=== KẾT QUẢ CUỐI CÙNG ===';
SELECT CityID, CityName, Region, Latitude, Longitude, CreatedAt 
FROM Cities 
ORDER BY CityID;
GO

SELECT COUNT(*) AS TotalCities FROM Cities;
GO

PRINT '';
PRINT '✅ HOÀN TẤT! Tất cả 10 cities đã có đầy đủ dữ liệu.';
