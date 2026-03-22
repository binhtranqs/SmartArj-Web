-- Fix WeatherLogs Table - Thêm các cột còn thiếu
-- Script này sẽ sửa lỗi "Invalid column name 'WindSpeed'"

USE SmartArj_PRJSEM;
GO

PRINT '=== KIỂM TRA VÀ SỬA BẢNG WEATHERLOGS ===';

-- Kiểm tra bảng WeatherLogs có tồn tại không
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'WeatherLogs')
BEGIN
    PRINT '✅ Bảng WeatherLogs tồn tại';
    
    PRINT '';
    PRINT '=== THÊM CÁC CỘT CÒN THIẾU ===';
    
    -- Thêm cột WindSpeed nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WeatherLogs') AND name = 'WindSpeed')
    BEGIN
        ALTER TABLE WeatherLogs ADD WindSpeed DECIMAL(5,2);
        PRINT '✅ Đã thêm cột WindSpeed';
    END
    ELSE
        PRINT '⚠️ Cột WindSpeed đã tồn tại';
    
    -- Thêm cột Rainfall nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('WeatherLogs') AND name = 'Rainfall')
    BEGIN
        ALTER TABLE WeatherLogs ADD Rainfall DECIMAL(5,2);
        PRINT '✅ Đã thêm cột Rainfall';
    END
    ELSE
        PRINT '⚠️ Cột Rainfall đã tồn tại';
    
    PRINT '';
    PRINT '=== CẤU TRÚC BẢNG WEATHERLOGS SAU KHI SỬA ===';
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH,
        NUMERIC_PRECISION,
        NUMERIC_SCALE,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'WeatherLogs'
    ORDER BY ORDINAL_POSITION;
    
END
ELSE
BEGIN
    PRINT '❌ Bảng WeatherLogs không tồn tại - cần tạo bảng này!';
END
GO

PRINT '';
PRINT '✅ HOÀN TẤT! Bảng WeatherLogs đã có đầy đủ các cột.';
