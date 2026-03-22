-- Kiểm tra Zones và CityID hiện tại

USE SmartAgri_PRJ301;
GO

PRINT '=== KIỂM TRA ZONES VÀ CITYID ===';
PRINT '';

-- 1. Tất cả Zones với CityID
PRINT '1. Danh sách tất cả Zones:';
SELECT 
    ZoneID,
    ZoneName,
    CityID,
    OwnerID
FROM Zones
ORDER BY ZoneID;
GO

-- 2. Kiểm tra Cities table
PRINT '';
PRINT '2. Danh sách Cities:';
SELECT 
    CityID,
    CityName
FROM Cities
ORDER BY CityID;
GO

-- 3. Zones không có CityID (NULL)
PRINT '';
PRINT '3. Zones có CityID = NULL:';
SELECT 
    ZoneID,
    ZoneName,
    CityID
FROM Zones
WHERE CityID IS NULL;
GO

PRINT '';
PRINT '=== KẾT LUẬN ===';
PRINT 'Nếu không có Zone nào với CityID=1 hoặc CityID=2,';
PRINT 'cần UPDATE Zones để gán CityID cho các zone hiện có.';
