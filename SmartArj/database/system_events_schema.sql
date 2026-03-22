-- ============================================================
-- SmartAgri Event System — SystemEvents Table
-- Database: SmartAgri_PRJ301
-- Run this script in SQL Server Management Studio
-- Safe to run multiple times (IF NOT EXISTS guards)
-- ============================================================

USE SmartAgri_PRJ301;
GO

-- ============================================================
-- 1. Create SystemEvents table
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SystemEvents')
BEGIN
    CREATE TABLE SystemEvents (
        EventId     INT IDENTITY(1,1) PRIMARY KEY,
        EventType   NVARCHAR(50)  NOT NULL,
        UserId      INT           NULL,     -- FK to Users, nullable for system-generated events
        EntityId    INT           NULL,     -- e.g. ListingID, OrderID — depends on event type
        Description NVARCHAR(500) NOT NULL,
        CreatedAt   DATETIME      NOT NULL  DEFAULT GETDATE()
    );
    PRINT 'Created table SystemEvents';
END
ELSE
    PRINT 'Table SystemEvents already exists — skipping creation';
GO

-- ============================================================
-- 2. Indexes for fast dashboard queries
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('SystemEvents') AND name = 'IX_SystemEvents_CreatedAt'
)
BEGIN
    CREATE INDEX IX_SystemEvents_CreatedAt
        ON SystemEvents (CreatedAt DESC);
    PRINT 'Created index IX_SystemEvents_CreatedAt';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('SystemEvents') AND name = 'IX_SystemEvents_EventType'
)
BEGIN
    CREATE INDEX IX_SystemEvents_EventType
        ON SystemEvents (EventType);
    PRINT 'Created index IX_SystemEvents_EventType';
END
GO

-- ============================================================
-- 3. Optional: seed a few demo rows so the dashboard isn't empty
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM SystemEvents)
BEGIN
    INSERT INTO SystemEvents (EventType, UserId, EntityId, Description) VALUES
    ('LISTING_CREATED',  NULL, NULL, N'Farmer đăng sản phẩm "Cà phê Gia Lai" — dữ liệu mẫu'),
    ('ORDER_CREATED',    NULL, NULL, N'Buyer đặt đơn hàng #101 — dữ liệu mẫu'),
    ('PAYMENT_SUCCESS',  NULL, NULL, N'Thanh toán VNPay thành công — dữ liệu mẫu'),
    ('VIP_UPGRADE',      NULL, NULL, N'User nâng cấp VIP (1 tháng) — dữ liệu mẫu'),
    ('CRAWLER_FINISHED', NULL, NULL, N'Crawler giá thị trường: SUCCESS — 12 mục — dữ liệu mẫu');
    PRINT 'Inserted 5 demo SystemEvents rows';
END
GO

PRINT 'SystemEvents schema migration DONE!';
GO
