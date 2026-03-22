-- Xóa 2 hàng Cities có dữ liệu NULL (CityID 1 và 2)
-- Chạy script này để dọn dẹp dữ liệu

USE SmartArj_PRJSEM;
GO

PRINT '=== TRƯỚC KHI XÓA ===';
SELECT * FROM Cities WHERE CityID IN (1, 2);
GO

-- Xóa 2 hàng có NULL data
DELETE FROM Cities WHERE CityID IN (1, 2);
GO

PRINT '';
PRINT '✅ Đã xóa CityID 1 và 2';
PRINT '';
PRINT '=== DỮ LIỆU SAU KHI XÓA ===';
SELECT * FROM Cities ORDER BY CityID;
GO

-- Show count
SELECT COUNT(*) AS TotalCities FROM Cities;
GO

PRINT '';
PRINT '✅ Hoàn tất! Bây giờ bạn có thể chạy insert_all_cities.sql để thêm lại đầy đủ 10 cities.';
