-- Đổi tên bảng CityID thành Cities
-- Script này sẽ sửa lỗi "Invalid object name 'Cities'"

USE SmartArj_PRJSEM;
GO

PRINT '=== KIỂM TRA BẢNG HIỆN TẠI ===';

-- Kiểm tra bảng CityID có tồn tại không
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'CityID')
BEGIN
    PRINT '✅ Tìm thấy bảng CityID';
    
    -- Hiển thị dữ liệu hiện tại
    PRINT 'Dữ liệu trong bảng CityID:';
    SELECT TOP 5 * FROM CityID;
    
    PRINT '';
    PRINT '=== ĐANG ĐỔI TÊN BẢNG ===';
    
    -- Đổi tên bảng
    EXEC sp_rename 'dbo.CityID', 'Cities';
    
    PRINT '✅ Đã đổi tên bảng CityID → Cities';
    
    PRINT '';
    PRINT '=== XÁC NHẬN ===';
    
    -- Kiểm tra bảng Cities đã tồn tại
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities')
    BEGIN
        PRINT '✅ Bảng Cities đã tồn tại';
        
        -- Hiển thị dữ liệu
        PRINT 'Dữ liệu trong bảng Cities:';
        SELECT * FROM Cities ORDER BY CityID;
        
        PRINT '';
        SELECT COUNT(*) AS TotalCities FROM Cities;
    END
    ELSE
    BEGIN
        PRINT '❌ Lỗi: Bảng Cities không tồn tại sau khi đổi tên';
    END
END
ELSE
BEGIN
    PRINT '⚠️ Không tìm thấy bảng CityID';
    
    -- Kiểm tra xem bảng Cities đã tồn tại chưa
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities')
    BEGIN
        PRINT '✅ Bảng Cities đã tồn tại (có thể đã được đổi tên trước đó)';
        SELECT * FROM Cities ORDER BY CityID;
    END
    ELSE
    BEGIN
        PRINT '❌ Không tìm thấy cả bảng CityID và Cities';
    END
END
GO

PRINT '';
PRINT '✅✅✅ HOÀN TẤT! Bây giờ code có thể query bảng Cities.';
