-- Create Alerts table for notification system
USE SmartAgri_PRJ301;
GO

-- Drop table if exists
IF OBJECT_ID('Alerts', 'U') IS NOT NULL
    DROP TABLE Alerts;
GO

-- Create Alerts table
CREATE TABLE Alerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    ZoneID INT NOT NULL,
    Message NVARCHAR(500) NOT NULL,
    AlertTime DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID) ON DELETE CASCADE
);
GO

-- Insert sample alerts for testing
INSERT INTO Alerts (ZoneID, Message, AlertTime, IsRead) VALUES
(1, 'Cảnh báo nhiệt độ cao: Nhiệt độ vượt ngưỡng 35°C', DATEADD(MINUTE, -5, GETDATE()), 0),
(2, 'Dự báo mưa: Có mưa trong 2 giờ tới', DATEADD(MINUTE, -15, GETDATE()), 0),
(1, 'Cập nhật dữ liệu: Dữ liệu mới đã được đồng bộ', DATEADD(HOUR, -1, GETDATE()), 0),
(3, 'Cảnh báo độ ẩm thấp: Cần tưới nước cho cây trồng', DATEADD(HOUR, -2, GETDATE()), 0),
(2, 'Nhiệt độ tối ưu: Điều kiện thời tiết thuận lợi cho cây trồng', DATEADD(HOUR, -3, GETDATE()), 1);
GO

-- Verify data
SELECT A.AlertID, A.Message, A.AlertTime, Z.ZoneName
FROM Alerts A
JOIN Zones Z ON A.ZoneID = Z.ZoneID
ORDER BY A.AlertTime DESC;
GO
