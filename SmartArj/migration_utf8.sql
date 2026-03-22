-- =================================================================================
-- SCRIPT MIGRATION: CẬP NHẬT KIỂU DỮ LIỆU SANG NVARCHAR ĐỂ HỖ TRỢ HIỂN THỊ TIẾNG VIỆT
-- Chạy script này trong SQL Server Management Studio (SSMS) trên database SmartAgri_PRJ301
-- =================================================================================

-- 1. Bảng ChatLogs: Chuyển Message và Intent sang NVARCHAR để lưu Unicode chuẩn
ALTER TABLE ChatLogs 
ALTER COLUMN Message NVARCHAR(500);

ALTER TABLE ChatLogs 
ALTER COLUMN Intent NVARCHAR(60);

-- 2. Bảng Users: Chuyển FullName, Username sang NVARCHAR (nếu đang là VARCHAR)
ALTER TABLE Users 
ALTER COLUMN FullName NVARCHAR(100);

ALTER TABLE Users 
ALTER COLUMN Username NVARCHAR(50);

ALTER TABLE Users 
ALTER COLUMN Email NVARCHAR(100);

-- Lưu ý: Nếu database báo lỗi khóa ngoại/khóa chính khi ALTER COLUMN, 
-- bạn cần DROP CONSTRAINT trước, ALTER COLUMN xong rồi ADD CONSTRAINT lại.
