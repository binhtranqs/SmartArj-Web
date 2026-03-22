-- Verify và Fix Zone CityID - Script Đơn Giản

USE SmartAgri_PRJ301;
GO

PRINT '=== KIỂM TRA HIỆN TẠI ===';
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
PRINT '=== UPDATE ZONE CITYID (FORCE) ===';

-- Force update Zone 1 → CityID = 1
UPDATE Zones SET CityID = 1 WHERE ZoneID = 1;
SELECT @@ROWCOUNT AS 'Rows Updated for Zone 1';

-- Force update Zone 5 → CityID = 2  
UPDATE Zones SET CityID = 2 WHERE ZoneID = 5;
SELECT @@ROWCOUNT AS 'Rows Updated for Zone 5';

GO

PRINT '';
PRINT '=== KẾT QUẢ SAU UPDATE ===';
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
PRINT 'Nếu vẫn lỗi foreign key, chạy script sau:';
PRINT 'ALTER TABLE Zones NOCHECK CONSTRAINT FK_Zones_Cities;';
PRINT 'UPDATE Zones SET CityID = 1 WHERE ZoneID = 1;';
PRINT 'UPDATE Zones SET CityID = 2 WHERE ZoneID = 5;';
PRINT 'ALTER TABLE Zones CHECK CONSTRAINT FK_Zones_Cities;';
