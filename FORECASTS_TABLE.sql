-- Forecasts table for SmartAgri_PRJ301 (SQL Server)
-- This matches the Java entity model.Forecast and ForecastDAO MERGE.
-- Run this in Azure Data Studio.

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
END
GO
