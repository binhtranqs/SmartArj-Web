-- ============================================================
-- Fix: Xóa dữ liệu Regions bị lỗi encoding và re-insert đúng
-- Database: SmartAgri_PRJ301
-- Chạy trong SQL Server Management Studio
-- ============================================================
USE SmartAgri_PRJ301;
GO

-- Xóa dữ liệu cũ bị lỗi encoding
-- (nếu có Listings tham chiếu RegionID, cần SET NULL trước)
UPDATE Listings SET RegionID = NULL WHERE RegionID IS NOT NULL;
DELETE FROM Regions;
PRINT 'Cleared old Regions data';
GO

-- Re-insert với prefix N'' đảm bảo Unicode NVARCHAR
SET IDENTITY_INSERT Regions ON;
INSERT INTO Regions (RegionID, RegionName, Province, CreatedAt) VALUES
(1,  N'Gia Lai',      N'Tây Nguyên',                    GETDATE()),
(2,  N'Đắk Lắk',     N'Tây Nguyên',                    GETDATE()),
(3,  N'Lâm Đồng',    N'Tây Nguyên',                    GETDATE()),
(4,  N'Đắk Nông',    N'Tây Nguyên',                    GETDATE()),
(5,  N'Kon Tum',      N'Tây Nguyên',                    GETDATE()),
(6,  N'Đồng Nai',    N'Đông Nam Bộ',                   GETDATE()),
(7,  N'Bình Phước',  N'Đông Nam Bộ',                   GETDATE()),
(8,  N'Hậu Giang',   N'Đồng bằng sông Cửu Long',      GETDATE()),
(9,  N'An Giang',     N'Đồng bằng sông Cửu Long',      GETDATE()),
(10, N'Tiền Giang',  N'Đồng bằng sông Cửu Long',      GETDATE()),
(11, N'Hà Nội',      N'Đồng bằng sông Hồng',          GETDATE()),
(12, N'Hải Dương',   N'Đồng bằng sông Hồng',          GETDATE()),
(13, N'Đà Nẵng',     N'Miền Trung',                    GETDATE()),
(14, N'Nghệ An',     N'Miền Trung',                    GETDATE()),
(15, N'Quảng Nam',  N'Miền Trung',                    GETDATE()),
(16, N'Bình Thuận', N'Đông Nam Bộ',                   GETDATE()),
(17, N'Long An',      N'Đồng bằng sông Cửu Long',      GETDATE()),
(18, N'Tây Ninh',    N'Đông Nam Bộ',                   GETDATE()),
(19, N'Bến Tre',     N'Đồng bằng sông Cửu Long',      GETDATE()),
(20, N'Đồng Tháp',  N'Đồng bằng sông Cửu Long',      GETDATE()),
(21, N'Kiên Giang',  N'Đồng bằng sông Cửu Long',      GETDATE()),
(22, N'Bắc Giang',   N'Miền Bắc',                      GETDATE()),
(23, N'Hưng Yên',   N'Miền Bắc',                      GETDATE());
SET IDENTITY_INSERT Regions OFF;

PRINT 'Re-inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' regions with correct Unicode encoding';
GO

-- Verify
SELECT TOP 5 RegionID, RegionName, Province FROM Regions ORDER BY RegionID;
GO

-- ============================================================
-- Fix: Xóa dữ liệu MarketPrices bị lỗi encoding (nếu chưa chạy)
-- ============================================================
DELETE FROM MarketPrices;
PRINT 'Cleared old MarketPrices data';
GO

INSERT INTO MarketPrices (ProductName, RegionName, Price, Unit, SourceURL) VALUES
(N'Cà phê nhân xô',    N'Gia Lai',      97100,  N'đ/kg', N'simulated-market'),
(N'Cà phê nhân xô',    N'Đắk Lắk',     96900,  N'đ/kg', N'simulated-market'),
(N'Cà phê nhân xô',    N'Lâm Đồng',    97000,  N'đ/kg', N'simulated-market'),
(N'Cà phê nhân xô',    N'Đắk Nông',    96800,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Gia Lai',     155000,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Đắk Lắk',    154500,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Đắk Nông',   154000,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Bình Phước', 153500,  N'đ/kg', N'simulated-market'),
(N'Cao su',            N'Bình Phước',  18500,  N'đ/kg', N'simulated-market'),
(N'Cao su',            N'Đồng Nai',    18200,  N'đ/kg', N'simulated-market'),
(N'Cao su',            N'Tây Ninh',    18300,  N'đ/kg', N'simulated-market'),
(N'Sầu riêng',         N'Đắk Lắk',    85000,  N'đ/kg', N'simulated-market'),
(N'Sầu riêng',         N'Tiền Giang', 90000,  N'đ/kg', N'simulated-market'),
(N'Sầu riêng',         N'Lâm Đồng',   82000,  N'đ/kg', N'simulated-market'),
(N'Thanh long',        N'Bình Thuận', 12000,  N'đ/kg', N'simulated-market'),
(N'Thanh long',        N'Long An',     11500,  N'đ/kg', N'simulated-market'),
(N'Mít Thái',          N'Đồng Nai',    18000,  N'đ/kg', N'simulated-market'),
(N'Mít Thái',          N'Tây Ninh',    17500,  N'đ/kg', N'simulated-market'),
(N'Chanh leo',         N'Gia Lai',     25000,  N'đ/kg', N'simulated-market'),
(N'Chanh leo',         N'Lâm Đồng',   24000,  N'đ/kg', N'simulated-market'),
(N'Bơ',               N'Đắk Lắk',    22000,  N'đ/kg', N'simulated-market'),
(N'Bơ',               N'Lâm Đồng',   20000,  N'đ/kg', N'simulated-market'),
(N'Xoài cát Hòa Lộc', N'Tiền Giang', 45000,  N'đ/kg', N'simulated-market'),
(N'Xoài',             N'An Giang',    28000,  N'đ/kg', N'simulated-market'),
(N'Xoài',             N'Đồng Tháp',  27500,  N'đ/kg', N'simulated-market'),
(N'Lúa gạo IR 504',   N'An Giang',    8200,   N'đ/kg', N'simulated-market'),
(N'Lúa gạo',          N'Hậu Giang',   8000,   N'đ/kg', N'simulated-market'),
(N'Lúa gạo',          N'Kiên Giang',  8100,   N'đ/kg', N'simulated-market'),
(N'Dừa khô',          N'Tiền Giang', 11500,  N'đ/kg', N'simulated-market'),
(N'Dừa khô',          N'Bến Tre',    12000,  N'đ/kg', N'simulated-market'),
(N'Ớt đỏ',            N'Gia Lai',    35000,  N'đ/kg', N'simulated-market'),
(N'Chuối tiêu',       N'Đồng Nai',   18000,  N'đ/kg', N'simulated-market'),
(N'Nhãn',             N'Hưng Yên',   35000,  N'đ/kg', N'simulated-market'),
(N'Vải thiều',        N'Bắc Giang',  30000,  N'đ/kg', N'simulated-market');

PRINT 'Re-inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' market prices with correct Unicode';
GO

PRINT '=== DONE! All encoding issues fixed. ===';
GO
