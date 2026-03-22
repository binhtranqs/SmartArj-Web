-- SAFE script to create Alerts table and insert data dynamically (Fixed Schema)
USE SmartAgri_PRJ301;
GO

-- 1. Drop table if exists
IF OBJECT_ID('Alerts', 'U') IS NOT NULL
    DROP TABLE Alerts;
GO

-- 2. Create Alerts table
CREATE TABLE Alerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    ZoneID INT NOT NULL,
    Message NVARCHAR(500) NOT NULL,
    AlertTime DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID) ON DELETE CASCADE
);
GO

-- 3. Get valid ZoneIDs (handle case where IDs are not 1, 2, 3)
DECLARE @Zone1 INT, @Zone2 INT, @Zone3 INT;

-- Get first 3 available ZoneIDs
SELECT TOP 1 @Zone1 = ZoneID FROM Zones ORDER BY ZoneID ASC;
SELECT TOP 1 @Zone2 = ZoneID FROM Zones WHERE ZoneID > @Zone1 ORDER BY ZoneID ASC;
SELECT TOP 1 @Zone3 = ZoneID FROM Zones WHERE ZoneID > @Zone2 ORDER BY ZoneID ASC;

-- If no zones exist, create one temp zone
IF @Zone1 IS NULL
BEGIN
    PRINT 'No zones found! Creating a default zone...';
    
    -- Check for valid CityID
    DECLARE @CityID INT;
    SELECT TOP 1 @CityID = CityID FROM Cities;
    
    IF @CityID IS NULL 
    BEGIN
        PRINT 'No cities found! Creating default city...';
        INSERT INTO Cities (CityName, Latitude, Longitude) VALUES ('Hanoi', 21.0285, 105.8542);
        SET @CityID = SCOPE_IDENTITY();
    END

    -- Insert Zone using CityID (Removed invalid columns: CityName, Area)
    INSERT INTO Zones (ZoneName, CityID, Latitude, Longitude)
    VALUES ('Default Zone', @CityID, 21.0, 105.8);
    
    SET @Zone1 = SCOPE_IDENTITY();
    SET @Zone2 = @Zone1;
    SET @Zone3 = @Zone1;
END

-- Fallback if only 1 or 2 zones exist
IF @Zone2 IS NULL SET @Zone2 = @Zone1;
IF @Zone3 IS NULL SET @Zone3 = @Zone1;

PRINT 'Inserting alerts for Zone IDs: ' + CAST(@Zone1 AS VARCHAR) + ', ' + CAST(@Zone2 AS VARCHAR) + ', ' + CAST(@Zone3 AS VARCHAR);

-- 4. Insert sample alerts using VALID ZoneIDs
INSERT INTO Alerts (ZoneID, Message, AlertTime, IsRead) VALUES
(@Zone1, N'Cảnh báo nhiệt độ cao: Nhiệt độ vượt ngưỡng 35°C', DATEADD(MINUTE, -5, GETDATE()), 0),
(@Zone2, N'Dự báo mưa: Có mưa trong 2 giờ tới', DATEADD(MINUTE, -15, GETDATE()), 0),
(@Zone1, N'Cập nhật dữ liệu: Dữ liệu mới đã được đồng bộ', DATEADD(HOUR, -1, GETDATE()), 0),
(@Zone3, N'Cảnh báo độ ẩm thấp: Cần tưới nước cho cây trồng', DATEADD(HOUR, -2, GETDATE()), 0),
(@Zone2, N'Nhiệt độ tối ưu: Điều kiện thời tiết thuận lợi cho cây trồng', DATEADD(HOUR, -3, GETDATE()), 1);
GO

-- 5. Verify data
SELECT A.AlertID, A.Message, A.AlertTime, Z.ZoneName
FROM Alerts A
JOIN Zones Z ON A.ZoneID = Z.ZoneID
ORDER BY A.AlertTime DESC;
GO
