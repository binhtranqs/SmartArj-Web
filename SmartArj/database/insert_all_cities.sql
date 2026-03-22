-- Insert All Cities from Python Models
-- This script adds all 10 cities that have weather prediction models
-- IMPORTANT: Run fix_cities_schema.sql FIRST to ensure table has all required columns

USE SmartArj_PRJSEM;
GO

-- Insert/Update all 10 cities with specific CityIDs
-- This preserves existing CityID for Đà Nẵng (1) and Hà Nội (2)

SET IDENTITY_INSERT Cities ON;
GO

MERGE INTO Cities AS target
USING (VALUES
    (1, N'Đà Nẵng', N'Miền Trung', 16.0544, 108.2022),
    (2, N'Hà Nội', N'Miền Bắc', 21.0285, 105.8542),
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

-- Verify the insert
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

-- Show count
SELECT COUNT(*) AS TotalCities FROM Cities;
GO

PRINT 'Successfully inserted/updated all 10 cities from Python models!';
