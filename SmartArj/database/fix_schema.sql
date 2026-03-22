-- Script sửa lỗi thiếu cột PasswordHash
-- Chạy script này nếu bạn gặp lỗi "Invalid column name 'PasswordHash'"

USE SmartAgri_PRJ301;
GO

-- Kiểm tra xem cột PasswordHash có tồn tại không, nếu không thì thêm vào
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Users]') 
         AND name = 'PasswordHash'
)
BEGIN
    PRINT 'Adding missing column PasswordHash...';
    ALTER TABLE Users ADD PasswordHash NVARCHAR(255) NOT NULL DEFAULT '';
    
    -- Xóa default constraint sau khi thêm (optional)
    -- DECLARE @ConstraintName nvarchar(200)
    -- SELECT @ConstraintName = Name FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = OBJECT_ID('Users') AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns WHERE NAME = 'PasswordHash' AND object_id = OBJECT_ID('Users'))
    -- IF @ConstraintName IS NOT NULL EXEC('ALTER TABLE Users DROP CONSTRAINT ' + @ConstraintName)
END
ELSE
BEGIN
    PRINT 'Column PasswordHash already exists.';
END

GO

-- Kiểm tra lại dữ liệu demo
IF EXISTS (SELECT * FROM Users WHERE Username = 'demo_free' AND PasswordHash = '')
BEGIN
    UPDATE Users 
    SET PasswordHash = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIxf6q3jm6' -- '123456'
    WHERE Username IN ('demo_free', 'demo_vip');
    PRINT 'Updated password hash for demo users.';
END
GO
