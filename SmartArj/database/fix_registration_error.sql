-- Script sửa lỗi đăng ký: Xóa cột 'Password' thừa
-- Lỗi "Cannot insert the value NULL into column 'Password'" xảy ra do bảng Users có cột 'Password' (cũ) nhưng code lại dùng 'PasswordHash' (mới).

USE SmartAgri_PRJ301;
GO

-- 1. Kiểm tra xem cột 'Password' có tồn tại không
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = 'Password')
BEGIN
    PRINT 'Found legacy column [Password]. Dropping it...';
    
    -- Trước khi drop, phải drop constraint (nếu có) liên quan đến cột này (ví dụ Default constraint)
    DECLARE @ConstraintName nvarchar(200)
    SELECT @ConstraintName = Name FROM SYS.DEFAULT_CONSTRAINTS 
    WHERE PARENT_OBJECT_ID = OBJECT_ID('Users') 
    AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns WHERE NAME = 'Password' AND object_id = OBJECT_ID('Users'))
    
    IF @ConstraintName IS NOT NULL
    BEGIN
        EXEC('ALTER TABLE Users DROP CONSTRAINT ' + @ConstraintName)
        PRINT 'Dropped constraint: ' + @ConstraintName
    END

    -- Drop cột Password
    ALTER TABLE Users DROP COLUMN Password;
    PRINT 'Dropped column [Password] successfully.';
END
ELSE
BEGIN
    PRINT 'Column [Password] does not exist. No action needed.';
END

-- 2. Đảm bảo cột PasswordHash tồn tại (phòng trường hợp script trước chưa chạy)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = 'PasswordHash')
BEGIN
    PRINT 'Adding missing column [PasswordHash]...';
    ALTER TABLE Users ADD PasswordHash NVARCHAR(255) NOT NULL DEFAULT '';
END

GO

PRINT '✅ Database fix applied successfully. Registration should work now.';
