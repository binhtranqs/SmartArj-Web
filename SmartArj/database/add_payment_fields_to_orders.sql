-- ============================================================
-- Migration: Thêm PaymentMethod + PaymentStatus vào Orders
-- Chạy file này 1 lần trong SQL Server Management Studio
-- ============================================================
USE SmartAgri_PRJ301;
GO

-- Thêm cột PaymentMethod (COD / VNPAY)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PaymentMethod'
)
BEGIN
    ALTER TABLE Orders ADD PaymentMethod NVARCHAR(20) NOT NULL DEFAULT 'COD';
    PRINT 'Added column: Orders.PaymentMethod';
END
ELSE
    PRINT 'Column already exists: Orders.PaymentMethod';
GO

-- Thêm cột PaymentStatus (UNPAID / PAID / FAILED)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PaymentStatus'
)
BEGIN
    ALTER TABLE Orders ADD PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'UNPAID';
    PRINT 'Added column: Orders.PaymentStatus';
END
ELSE
    PRINT 'Column already exists: Orders.PaymentStatus';
GO

-- Thêm cột VnpTxnRef để track giao dịch VNPay (optional, tiện tra cứu)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'VnpTxnRef'
)
BEGIN
    ALTER TABLE Orders ADD VnpTxnRef NVARCHAR(100) NULL;
    PRINT 'Added column: Orders.VnpTxnRef';
END
ELSE
    PRINT 'Column already exists: Orders.VnpTxnRef';
GO

-- Verify
SELECT COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;
GO

PRINT '=== Migration completed: Orders now has PaymentMethod + PaymentStatus ===';
GO
