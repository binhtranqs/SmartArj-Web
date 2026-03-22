-- Script Khôi Phục Dữ Liệu Hà Nội và Đà Nẵng
-- Chạy script này để khôi phục lại dữ liệu đã bị mất

USE SmartArj_PRJSEM;
GO

-- Bước 1: Kiểm tra dữ liệu hiện tại
PRINT '=== KIỂM TRA DỮ LIỆU HIỆN TẠI ===';
SELECT * FROM Cities ORDER BY CityID;
GO

PRINT '';
PRINT '=== KIỂM TRA ZONES LIÊN QUAN ===';
SELECT ZoneID, ZoneName, CityID FROM Zones WHERE CityID IN (1, 2);
GO

PRINT '';
PRINT '=== KIỂM TRA USERS LIÊN QUAN ===';
SELECT UserID, Username, CityID FROM Users WHERE CityID IN (1, 2);
GO

-- Bước 2: Backup dữ liệu Zones và Users liên quan (nếu có)
-- Tạo bảng tạm để lưu zones
IF OBJECT_ID('tempdb..#BackupZones') IS NOT NULL DROP TABLE #BackupZones;
SELECT * INTO #BackupZones FROM Zones WHERE CityID IN (1, 2);

-- Tạo bảng tạm để lưu users
IF OBJECT_ID('tempdb..#BackupUsers') IS NOT NULL DROP TABLE #BackupUsers;
SELECT * INTO #BackupUsers FROM Users WHERE CityID IN (1, 2);

PRINT '';
PRINT '=== ĐÃ BACKUP DỮ LIỆU LIÊN QUAN ===';
SELECT COUNT(*) AS BackupZonesCount FROM #BackupZones;
SELECT COUNT(*) AS BackupUsersCount FROM #BackupUsers;
GO

-- Bước 3: Xóa Cities cũ nếu tồn tại (ID 1 và 2)
DELETE FROM Cities WHERE CityID IN (1, 2);
PRINT 'Đã xóa Cities cũ (nếu có)';
GO

-- Bước 4: Insert lại Đà Nẵng và Hà Nội với đầy đủ thông tin
SET IDENTITY_INSERT Cities ON;
GO

INSERT INTO Cities (CityID, CityName, Region, Latitude, Longitude, CreatedAt)
VALUES 
    (1, N'Đà Nẵng', N'Miền Trung', 16.0544, 108.2022, GETDATE()),
    (2, N'Hà Nội', N'Miền Bắc', 21.0285, 105.8542, GETDATE());
GO

SET IDENTITY_INSERT Cities OFF;
GO

PRINT '';
PRINT '=== ĐÃ KHÔI PHỤC CITIES ===';
SELECT * FROM Cities WHERE CityID IN (1, 2);
GO

-- Bước 5: Restore lại Zones nếu có
IF EXISTS (SELECT 1 FROM #BackupZones)
BEGIN
    -- Zones vẫn còn reference đến CityID, không cần update
    PRINT '';
    PRINT '=== ZONES VẪN CÒN LIÊN KẾT ===';
    SELECT ZoneID, ZoneName, CityID FROM Zones WHERE CityID IN (1, 2);
END
GO

-- Bước 6: Restore lại Users nếu có
IF EXISTS (SELECT 1 FROM #BackupUsers)
BEGIN
    -- Users vẫn còn reference đến CityID, không cần update
    PRINT '';
    PRINT '=== USERS VẪN CÒN LIÊN KẾT ===';
    SELECT UserID, Username, CityID FROM Users WHERE CityID IN (1, 2);
END
GO

-- Bước 7: Verify tất cả dữ liệu
PRINT '';
PRINT '=== KẾT QUẢ CUỐI CÙNG ===';
PRINT 'Cities:';
SELECT CityID, CityName, Region, Latitude, Longitude FROM Cities ORDER BY CityID;

PRINT '';
PRINT 'Zones liên quan:';
SELECT z.ZoneID, z.ZoneName, c.CityName 
FROM Zones z 
LEFT JOIN Cities c ON z.CityID = c.CityID 
WHERE z.CityID IN (1, 2);

PRINT '';
PRINT 'Users liên quan:';
SELECT u.UserID, u.Username, c.CityName 
FROM Users u 
LEFT JOIN Cities c ON u.CityID = c.CityID 
WHERE u.CityID IN (1, 2);

PRINT '';
PRINT '✅ HOÀN TẤT KHÔI PHỤC!';
