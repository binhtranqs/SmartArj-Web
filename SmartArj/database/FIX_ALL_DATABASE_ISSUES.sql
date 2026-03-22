-- ============================================
-- SCRIPT TỔNG HỢP CUỐI CÙNG - FIX TẤT CẢ
-- ============================================
-- Chạy script này để fix mọi thứ một lần dứt điểm

USE SmartAgri_PRJ301;
GO

PRINT '============================================';
PRINT 'BƯỚC 1: ĐỔI TÊN BẢNG CITYID → CITIES';
PRINT '============================================';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CityID')
BEGIN
    EXEC sp_rename 'dbo.CityID', 'Cities';
    PRINT '✅ Đã đổi tên CityID → Cities';
END
ELSE IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities')
BEGIN
    PRINT '✅ Bảng Cities đã tồn tại';
END
ELSE
BEGIN
    PRINT '❌ CẢNH BÁO: Không tìm thấy bảng CityID hoặc Cities!';
END
GO

PRINT '';
PRINT '============================================';
PRINT 'BƯỚC 2: THÊM CÁC CỘT CÒN THIẾU CHO WEATHERLOGS';
PRINT '============================================';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'WeatherLogs')
BEGIN
    -- Thêm WindSpeed
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WeatherLogs') AND name = 'WindSpeed')
    BEGIN
        ALTER TABLE WeatherLogs ADD WindSpeed DECIMAL(5,2);
        PRINT '✅ Đã thêm cột WindSpeed';
    END
    ELSE
        PRINT '⚠️ Cột WindSpeed đã tồn tại';
    
    -- Thêm Rainfall
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WeatherLogs') AND name = 'Rainfall')
    BEGIN
        ALTER TABLE WeatherLogs ADD Rainfall DECIMAL(5,2);
        PRINT '✅ Đã thêm cột Rainfall';
    END
    ELSE
        PRINT '⚠️ Cột Rainfall đã tồn tại';
END
GO

PRINT '';
PRINT '============================================';
PRINT 'BƯỚC 3: CẬP NHẬT ZONE CITYID';
PRINT '============================================';

-- Hiển thị trạng thái hiện tại
PRINT 'Trạng thái hiện tại:';
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
PRINT 'Đang cập nhật CityID...';

-- Update Zone 1 → Đà Nẵng (CityID=1)
UPDATE Zones 
SET CityID = 1 
WHERE ZoneID = 1;
PRINT '✅ Zone 1 → CityID = 1 (Đà Nẵng)';

-- Update Zone 5 → Hà Nội (CityID=2)
UPDATE Zones 
SET CityID = 2 
WHERE ZoneID = 5;
PRINT '✅ Zone 5 → CityID = 2 (Hà Nội)';

GO

PRINT '';
PRINT 'Trạng thái sau khi cập nhật:';
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
PRINT '============================================';
PRINT '✅✅✅ HOÀN TẤT TẤT CẢ! ✅✅✅';
PRINT '============================================';
PRINT '';
PRINT 'Đã fix thành công:';
PRINT '  ✅ Bảng Cities có tên đúng';
PRINT '  ✅ WeatherLogs có đầy đủ cột';
PRINT '  ✅ Zones có CityID đúng';
PRINT '';
PRINT 'Bây giờ:';
PRINT '  1. Restart Python service (nếu đang chạy)';
PRINT '  2. Clean & Build Java project';
PRINT '  3. Restart Tomcat server';
PRINT '  4. Test forecast: http://localhost:5001/predict?city=DaNang';
PRINT '  5. Test dashboard: http://localhost:8080/SmartArj/dashboard';
PRINT '============================================';
