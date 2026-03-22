-- Fix Cities Table Schema
-- Add missing columns: Region, Latitude, Longitude

USE SmartArj_PRJSEM;
GO

-- Check if columns exist, if not add them
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Cities') AND name = 'Region')
BEGIN
    ALTER TABLE Cities ADD Region NVARCHAR(100);
    PRINT 'Added Region column';
END
ELSE
BEGIN
    PRINT 'Region column already exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Cities') AND name = 'Latitude')
BEGIN
    ALTER TABLE Cities ADD Latitude DECIMAL(9,6);
    PRINT 'Added Latitude column';
END
ELSE
BEGIN
    PRINT 'Latitude column already exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Cities') AND name = 'Longitude')
BEGIN
    ALTER TABLE Cities ADD Longitude DECIMAL(9,6);
    PRINT 'Added Longitude column';
END
ELSE
BEGIN
    PRINT 'Longitude column already exists';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Cities') AND name = 'CreatedAt')
BEGIN
    ALTER TABLE Cities ADD CreatedAt DATETIME DEFAULT GETDATE();
    PRINT 'Added CreatedAt column';
END
ELSE
BEGIN
    PRINT 'CreatedAt column already exists';
END
GO

-- Verify the structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Cities'
ORDER BY ORDINAL_POSITION;
GO

PRINT 'Cities table schema has been updated successfully!';
