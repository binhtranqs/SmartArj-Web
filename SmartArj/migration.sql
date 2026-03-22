-- ============================================================
-- SmartArj DB Migration Script
-- Run this in Azure Data Studio / SSMS against SmartAgri_PRJ301
-- ============================================================

-- 1) Add OwnerID to Zones (nullable for existing data)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Zones') AND name = 'OwnerID')
BEGIN
    ALTER TABLE dbo.Zones ADD OwnerID INT NULL;
    PRINT 'Added OwnerID to Zones';
END
GO

-- FK: Zones.OwnerID -> Users.UserID
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Zones_Users')
BEGIN
    ALTER TABLE dbo.Zones ADD CONSTRAINT FK_Zones_Users FOREIGN KEY (OwnerID) REFERENCES dbo.Users(UserID);
    PRINT 'Added FK_Zones_Users';
END
GO

-- Index on OwnerID
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Zones_OwnerID' AND object_id = OBJECT_ID('dbo.Zones'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Zones_OwnerID ON dbo.Zones (OwnerID);
    PRINT 'Added IX_Zones_OwnerID';
END
GO

-- 2) Add Description column to Zones (if missing)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Zones') AND name = 'Description')
BEGIN
    ALTER TABLE dbo.Zones ADD [Description] NVARCHAR(MAX) NULL;
    PRINT 'Added Description to Zones';
END
GO

-- 3) Create Forecasts table
IF OBJECT_ID('dbo.Forecasts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Forecasts (
        ForecastID INT IDENTITY(1,1) PRIMARY KEY,
        ZoneID INT NOT NULL,
        ForecastDate DATE NOT NULL,
        Temperature FLOAT NULL,
        CreatedAt DATETIME NULL DEFAULT(GETDATE()),
        CONSTRAINT UQ_Forecasts_ZoneDate UNIQUE (ZoneID, ForecastDate),
        CONSTRAINT FK_Forecasts_Zones FOREIGN KEY (ZoneID) REFERENCES dbo.Zones(ZoneID)
    );
    PRINT 'Created Forecasts table';
END
GO

-- 4) Create Alerts table (if not exists)
IF OBJECT_ID('dbo.Alerts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Alerts (
        AlertID INT IDENTITY(1,1) PRIMARY KEY,
        ZoneID INT NOT NULL,
        [Message] NVARCHAR(MAX) NOT NULL,
        AlertTime DATETIME NOT NULL DEFAULT(GETDATE()),
        IsRead BIT NOT NULL DEFAULT(0),
        CONSTRAINT FK_Alerts_Zones FOREIGN KEY (ZoneID) REFERENCES dbo.Zones(ZoneID) ON DELETE CASCADE
    );
    CREATE NONCLUSTERED INDEX IX_Alerts_ZoneID_AlertTime ON dbo.Alerts (ZoneID ASC, AlertTime DESC);
    PRINT 'Created Alerts table';
END
GO

-- 5) Add ProviderTxnRef / ProviderTxnId to Transactions (if not exist)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Transactions') AND name = 'ProviderTxnRef')
BEGIN
    ALTER TABLE dbo.Transactions ADD ProviderTxnRef VARCHAR(64) NULL;
    PRINT 'Added ProviderTxnRef to Transactions';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Transactions') AND name = 'ProviderTxnId')
BEGIN
    ALTER TABLE dbo.Transactions ADD ProviderTxnId VARCHAR(64) NULL;
    PRINT 'Added ProviderTxnId to Transactions';
END
GO

-- Unique index on ProviderTxnRef (filtered, non-null only)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Transactions_ProviderTxnRef' AND object_id = OBJECT_ID('dbo.Transactions'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Transactions_ProviderTxnRef
        ON dbo.Transactions (ProviderTxnRef)
        WHERE ProviderTxnRef IS NOT NULL;
    PRINT 'Added UX_Transactions_ProviderTxnRef';
END
GO

PRINT '=== Migration complete ===';
GO
