-- Fix Zone CityID Assignments
-- Gán CityID đúng cho các Zones hiện có

USE SmartAgri_PRJ301;
GO

PRINT '=== FIX ZONE CITYID ASSIGNMENTS ===';
PRINT '';

-- Hiển thị trạng thái hiện tại
PRINT 'Trạng thái TRƯỚC khi fix:';
SELECT 
    z.ZoneID,
    z.ZoneName,
    z.CityID AS Old_CityID,
    c.CityName AS Old_CityName
FROM Zones z
LEFT JOIN Cities c ON z.CityID = c.CityID
ORDER BY z.ZoneID;
GO

PRINT '';
PRINT '=== ĐANG CẬP NHẬT CITYID ===';

-- Giả sử:
-- Zone 1 "Vườn Lan Cẩm Lệ" nằm ở Đà Nẵng → CityID = 1
-- Zone 5 "Vườn Rau Đông Anh" nằm ở Hà Nội (Đông Anh là quận của Hà Nội) → CityID = 2

-- Update Zone 1 → Đà Nẵng
UPDATE Zones 
SET CityID = 1 
WHERE ZoneID = 1;
PRINT '✅ Updated Zone 1 (Vườn Lan Cẩm Lệ) → CityID = 1 (Đà Nẵng)';

-- Update Zone 5 → Hà Nội
UPDATE Zones 
SET CityID = 2 
WHERE ZoneID = 5;
PRINT '✅ Updated Zone 5 (Vườn Rau Đông Anh) → CityID = 2 (Hà Nội)';

GO

PRINT '';
PRINT 'Trạng thái SAU khi fix:';
SELECT 
    z.ZoneID,
    z.ZoneName,
    z.CityID AS New_CityID,
    c.CityName AS New_CityName
FROM Zones z
LEFT JOIN Cities c ON z.CityID = c.CityID
ORDER BY z.ZoneID;
GO

PRINT '';
PRINT '=== HOÀN TẤT ===';
PRINT 'Bây giờ Python service có thể tìm thấy Zone với CityID=1 và CityID=2';
PRINT 'Test lại forecast API: http://localhost:5001/predict?city=DaNang';
