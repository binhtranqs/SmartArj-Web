-- ==========================================================
-- THÊM VÀO SmartAgri_Setup.sql
-- Bảng FetchLogs – Audit Trail cho Data Engineer (Module 2)
-- ==========================================================

USE SmartAgri_PRJ301;
GO

-- Tạo bảng FetchLogs nếu chưa có
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'FetchLogs'
)
BEGIN
    CREATE TABLE FetchLogs (
        LogID        BIGINT IDENTITY(1,1) PRIMARY KEY,
        FetchTime    DATETIME NOT NULL DEFAULT GETDATE(), -- Thời điểm fetch
        ZoneID       INT NULL,                            -- NULL nếu lỗi toàn hệ thống
        Status       NVARCHAR(20) NOT NULL,               -- SUCCESS | FAILED | EMPTY | ALL_REJECTED
        RowsFetched  INT DEFAULT 0,                       -- Số rows API trả về
        RowsInserted INT DEFAULT 0,                       -- Số rows thực sự vào DB
        RowsRejected INT DEFAULT 0,                       -- Số rows bị cleaning loại
        ErrorMsg     NVARCHAR(MAX) NULL,                  -- Chi tiết lỗi nếu FAILED

        CONSTRAINT FK_FetchLogs_Zones FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID)
    );
    PRINT 'Da tao bang FetchLogs.';
END
ELSE
    PRINT 'Bang FetchLogs da ton tai.';
GO

-- ==========================================================
-- VIEW: Data Freshness Monitor
-- Kiểm tra zone nào bị "cũ data" quá 2 ngày
-- ==========================================================
CREATE OR ALTER VIEW vw_DataFreshness AS
SELECT
    z.ZoneID,
    c.CityName,
    z.ZoneName,
    MAX(w.RecordedAt)                                      AS LatestRecord,
    DATEDIFF(HOUR, MAX(w.RecordedAt), GETDATE())           AS HoursSinceLastRecord,
    CASE
        WHEN MAX(w.RecordedAt) IS NULL                          THEN 'NO_DATA'
        WHEN DATEDIFF(HOUR, MAX(w.RecordedAt), GETDATE()) > 48 THEN 'STALE'   -- Quá 2 ngày
        WHEN DATEDIFF(HOUR, MAX(w.RecordedAt), GETDATE()) > 24 THEN 'WARNING' -- Quá 1 ngày
        ELSE 'FRESH'
    END AS FreshnessStatus
FROM Zones z
JOIN Cities c ON z.CityID = c.CityID
LEFT JOIN WeatherLogs w ON z.ZoneID = w.ZoneID
GROUP BY z.ZoneID, c.CityName, z.ZoneName;
GO

-- VIEW: Lịch sử fetch gần đây (để monitor pipeline)
CREATE OR ALTER VIEW vw_FetchSummary AS
SELECT TOP 50
    fl.LogID,
    fl.FetchTime,
    c.CityName,
    z.ZoneName,
    fl.Status,
    fl.RowsFetched,
    fl.RowsInserted,
    fl.RowsRejected,
    fl.ErrorMsg
FROM FetchLogs fl
LEFT JOIN Zones z   ON fl.ZoneID = z.ZoneID
LEFT JOIN Cities c  ON z.CityID  = c.CityID
ORDER BY fl.FetchTime DESC;
GO
