-- ==========================================================
-- CaReTS – Data Freshness & Quality Monitor Queries
-- Dùng để kiểm tra sức khỏe pipeline thời tiết (Module 2)
-- ==========================================================

USE SmartAgri_PRJ301;
GO

-- ──────────────────────────────────────────────────────────
-- 1. TỔNG QUAN: Zone nào "tươi", zone nào "cũ"?
-- ──────────────────────────────────────────────────────────
SELECT *
FROM vw_DataFreshness
ORDER BY FreshnessStatus DESC, HoursSinceLastRecord DESC;

-- ──────────────────────────────────────────────────────────
-- 2. CẢNH BÁO: Zone bị stale > 48 giờ (cần action ngay)
-- ──────────────────────────────────────────────────────────
SELECT CityName, ZoneName, LatestRecord, HoursSinceLastRecord, FreshnessStatus
FROM vw_DataFreshness
WHERE FreshnessStatus IN ('STALE', 'NO_DATA')
ORDER BY HoursSinceLastRecord DESC;

-- ──────────────────────────────────────────────────────────
-- 3. LỊCH SỬ FETCH: 10 lần fetch gần nhất
-- ──────────────────────────────────────────────────────────
SELECT TOP 10 *
FROM vw_FetchSummary;

-- ──────────────────────────────────────────────────────────
-- 4. TỶ LỆ THÀNH CÔNG của pipeline (7 ngày gần nhất)
-- ──────────────────────────────────────────────────────────
SELECT
    Status,
    COUNT(*)                                 AS Count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS Pct
FROM FetchLogs
WHERE FetchTime >= DATEADD(DAY, -7, GETDATE())
GROUP BY Status
ORDER BY Count DESC;

-- ──────────────────────────────────────────────────────────
-- 5. ROWS BỊ REJECT: Zone nào có tỷ lệ cleaning cao?
-- ──────────────────────────────────────────────────────────
SELECT
    c.CityName,
    z.ZoneName,
    SUM(fl.RowsFetched)   AS TotalFetched,
    SUM(fl.RowsInserted)  AS TotalInserted,
    SUM(fl.RowsRejected)  AS TotalRejected,
    CASE
        WHEN SUM(fl.RowsFetched) = 0 THEN NULL
        ELSE CAST(SUM(fl.RowsRejected) * 100.0 / SUM(fl.RowsFetched) AS DECIMAL(5,1))
    END AS RejectRate_Pct
FROM FetchLogs fl
JOIN Zones z  ON fl.ZoneID = z.ZoneID
JOIN Cities c ON z.CityID  = c.CityID
GROUP BY c.CityName, z.ZoneName
ORDER BY RejectRate_Pct DESC;

-- ──────────────────────────────────────────────────────────
-- 6. KIỂM TRA DỮ LIỆU BẤT THƯỜNG TRONG WeatherLogs
-- ──────────────────────────────────────────────────────────
SELECT
    w.LogID,
    c.CityName,
    z.ZoneName,
    w.RecordedAt,
    w.Temperature,
    w.Humidity,
    w.Rainfall,
    w.Wind,
    w.Radiation,
    CASE
        WHEN w.Temperature NOT BETWEEN -30 AND 55 THEN 'TEMP_OUTLIER'
        WHEN w.Humidity    NOT BETWEEN   0 AND 100 THEN 'HUMID_OUTLIER'
        WHEN w.Rainfall < 0                         THEN 'RAIN_NEGATIVE'
        WHEN w.Wind     < 0                         THEN 'WIND_NEGATIVE'
        ELSE '?'
    END AS Issue
FROM WeatherLogs w
JOIN Zones z  ON w.ZoneID = z.ZoneID
JOIN Cities c ON z.CityID = c.CityID
WHERE
    w.Temperature NOT BETWEEN -30 AND 55
    OR w.Humidity NOT BETWEEN 0 AND 100
    OR w.Rainfall < 0
    OR w.Wind < 0
ORDER BY w.RecordedAt DESC;
