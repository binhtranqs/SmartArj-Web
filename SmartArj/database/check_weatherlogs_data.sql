-- Kiểm tra dữ liệu WeatherLogs để debug Forecast Error 502

USE SmartAgri_PRJ301;
GO

PRINT '=== KIỂM TRA DỮ LIỆU WEATHERLOGS ===';
PRINT '';

-- 1. Kiểm tra tổng số records
PRINT '1. Tổng số records trong WeatherLogs:';
SELECT COUNT(*) AS TotalRecords FROM WeatherLogs;
GO

-- 2. Kiểm tra records theo ZoneID
PRINT '';
PRINT '2. Số lượng records theo ZoneID:';
SELECT 
    ZoneID,
    COUNT(*) AS RecordCount
FROM WeatherLogs
GROUP BY ZoneID
ORDER BY ZoneID;
GO

-- 3. Kiểm tra records tại mốc 12h (Python service cần 30 records tại mốc 12h)
PRINT '';
PRINT '3. Số lượng records tại mốc 12:00 (cần >= 30 để forecast):';
SELECT 
    ZoneID,
    COUNT(*) AS Records_At_12PM
FROM WeatherLogs
WHERE DATEPART(HOUR, RecordedAt) = 12
GROUP BY ZoneID
ORDER BY ZoneID;
GO

-- 4. Kiểm tra Zones có CityID
PRINT '';
PRINT '4. Danh sách Zones với CityID:';
SELECT 
    z.ZoneID,
    z.ZoneName,
    z.CityID,
    c.CityName
FROM Zones z
LEFT JOIN Cities c ON z.CityID = c.CityID
ORDER BY z.ZoneID;
GO

-- 5. Kiểm tra sample data từ WeatherLogs
PRINT '';
PRINT '5. Sample 5 records gần nhất:';
SELECT TOP 5
    ZoneID,
    Temperature,
    Humidity,
    Rainfall,
    WindSpeed,
    RecordedAt
FROM WeatherLogs
ORDER BY RecordedAt DESC;
GO

-- 6. Kiểm tra NULL values
PRINT '';
PRINT '6. Kiểm tra NULL values (Python service sẽ lỗi nếu có NULL):';
SELECT 
    ZoneID,
    SUM(CASE WHEN Temperature IS NULL THEN 1 ELSE 0 END) AS Null_Temperature,
    SUM(CASE WHEN Humidity IS NULL THEN 1 ELSE 0 END) AS Null_Humidity,
    SUM(CASE WHEN Rainfall IS NULL THEN 1 ELSE 0 END) AS Null_Rainfall,
    SUM(CASE WHEN WindSpeed IS NULL THEN 1 ELSE 0 END) AS Null_WindSpeed
FROM WeatherLogs
WHERE DATEPART(HOUR, RecordedAt) = 12
GROUP BY ZoneID;
GO

PRINT '';
PRINT '=== KẾT LUẬN ===';
PRINT 'Để forecast hoạt động, cần:';
PRINT '  - Ít nhất 1 Zone có CityID = 1 (Đà Nẵng) hoặc 2 (Hà Nội)';
PRINT '  - Zone đó phải có >= 30 records tại mốc 12:00';
PRINT '  - Không có NULL values trong Temperature, Humidity, Rainfall, WindSpeed';
PRINT '';
PRINT 'Nếu thiếu dữ liệu, cần insert sample data vào WeatherLogs.';
