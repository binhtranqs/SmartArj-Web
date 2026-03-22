USE SmartAgri_PRJ301;
GO

-- Xem cột thực tế của bảng Users
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Users'
ORDER BY ORDINAL_POSITION;
GO

-- Xem tài khoản admin hiện tại (theo IsAdmin cũ)
SELECT UserID, Username, FullName, 
       ISNULL(Role, 'NULL') AS Role,
       ISNULL(CAST(IsAdmin AS VARCHAR), 'no col') AS IsAdmin
FROM Users
WHERE IsAdmin = 1 OR Role = 'ADMIN';
GO

-- FIX: Set cột Role = 'ADMIN' cho tất cả admin cũ
UPDATE Users 
SET Role = 'ADMIN' 
WHERE IsAdmin = 1 AND (Role IS NULL OR Role != 'ADMIN');

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR) + ' admin account(s).';
GO

-- Verify
SELECT UserID, Username, FullName, Role, IsAdmin
FROM Users 
WHERE Role = 'ADMIN';
GO
