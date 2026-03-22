-- =====================================================
-- SmartArj Sample Data Script
-- Tạo dữ liệu mẫu cho Zones và WeatherLogs
-- =====================================================

USE SmartAgri_PRJ301;
GO

-- Xóa dữ liệu cũ (nếu có)
DELETE FROM WeatherLogs;
DELETE FROM Crops;
DELETE FROM Zones;
GO

-- Thêm Zones mẫu
INSERT INTO Zones (ZoneName, CityName, Latitude, Longitude, Area) VALUES
('Vùng A', 'Hà Nội', 21.0285, 105.8542, 1500.00),
('Vùng B', 'Hồ Chí Minh', 10.8231, 106.6297, 2000.00),
('Vùng C', 'Đà Nẵng', 16.0544, 108.2022, 1200.00),
('Vùng D', 'Cần Thơ', 10.0452, 105.7469, 1800.00);
GO

-- Thêm WeatherLogs mẫu cho Vùng A (30 ngày gần đây)
DECLARE @i INT = 0;
DECLARE @zoneId INT = (SELECT TOP 1 ZoneID FROM Zones WHERE ZoneName = 'Vùng A');

WHILE @i < 30
BEGIN
    INSERT INTO WeatherLogs (ZoneID, RecordedAt, Temperature, Humidity, Rainfall, Wind, Radiation)
    VALUES (
        @zoneId,
        DATEADD(DAY, -@i, GETDATE()),
        25 + (RAND() * 10),  -- Nhiệt độ 25-35°C
        60 + (RAND() * 30),  -- Độ ẩm 60-90%
        RAND() * 50,         -- Lượng mưa 0-50mm
        5 + (RAND() * 15),   -- Gió 5-20 km/h
        200 + (RAND() * 600) -- Bức xạ 200-800 W/m²
    );
    SET @i = @i + 1;
END
GO

-- Thêm WeatherLogs mẫu cho Vùng B (30 ngày gần đây)
DECLARE @j INT = 0;
DECLARE @zoneIdB INT = (SELECT TOP 1 ZoneID FROM Zones WHERE ZoneName = 'Vùng B');

WHILE @j < 30
BEGIN
    INSERT INTO WeatherLogs (ZoneID, RecordedAt, Temperature, Humidity, Rainfall, Wind, Radiation)
    VALUES (
        @zoneIdB,
        DATEADD(DAY, -@j, GETDATE()),
        28 + (RAND() * 8),   -- Nhiệt độ 28-36°C
        70 + (RAND() * 20),  -- Độ ẩm 70-90%
        RAND() * 40,         -- Lượng mưa 0-40mm
        3 + (RAND() * 12),   -- Gió 3-15 km/h
        300 + (RAND() * 500) -- Bức xạ 300-800 W/m²
    );
    SET @j = @j + 1;
END
GO

-- Thêm WeatherLogs mẫu cho Vùng C (30 ngày gần đây)
DECLARE @k INT = 0;
DECLARE @zoneIdC INT = (SELECT TOP 1 ZoneID FROM Zones WHERE ZoneName = 'Vùng C');

WHILE @k < 30
BEGIN
    INSERT INTO WeatherLogs (ZoneID, RecordedAt, Temperature, Humidity, Rainfall, Wind, Radiation)
    VALUES (
        @zoneIdC,
        DATEADD(DAY, -@k, GETDATE()),
        26 + (RAND() * 9),   -- Nhiệt độ 26-35°C
        65 + (RAND() * 25),  -- Độ ẩm 65-90%
        RAND() * 45,         -- Lượng mưa 0-45mm
        8 + (RAND() * 17),   -- Gió 8-25 km/h
        250 + (RAND() * 550) -- Bức xạ 250-800 W/m²
    );
    SET @k = @k + 1;
END
GO

-- Kiểm tra dữ liệu đã insert
SELECT 'Zones' AS TableName, COUNT(*) AS RecordCount FROM Zones
UNION ALL
SELECT 'WeatherLogs', COUNT(*) FROM WeatherLogs;
GO

PRINT 'Sample data inserted successfully!';
GO
