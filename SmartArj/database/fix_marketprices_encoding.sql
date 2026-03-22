-- ============================================================
-- Fix: Xóa data bị lỗi encoding và re-insert với NVARCHAR đúng
-- Chạy trong SQL Server Management Studio
-- ============================================================
USE SmartAgri_PRJ301;
GO

-- Xóa toàn bộ dữ liệu cũ (bị lỗi encoding)
DELETE FROM MarketPrices;
PRINT 'Cleared old MarketPrices data';
GO

-- Re-insert với prefix N'' đảm bảo Unicode
INSERT INTO MarketPrices (ProductName, RegionName, Price, Unit, SourceURL) VALUES
(N'Cà phê nhân xô',    N'Gia Lai',      97100,  N'đ/kg', N'simulated-market'),
(N'Cà phê nhân xô',    N'Đắk Lắk',      96900,  N'đ/kg', N'simulated-market'),
(N'Cà phê nhân xô',    N'Lâm Đồng',     97000,  N'đ/kg', N'simulated-market'),
(N'Cà phê nhân xô',    N'Đắk Nông',     96800,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Gia Lai',     155000,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Đắk Lắk',    154500,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Đắk Nông',   154000,  N'đ/kg', N'simulated-market'),
(N'Hồ tiêu',           N'Bình Phước', 153500,  N'đ/kg', N'simulated-market'),
(N'Cao su',            N'Bình Phước',  18500,  N'đ/kg', N'simulated-market'),
(N'Cao su',            N'Đồng Nai',    18200,  N'đ/kg', N'simulated-market'),
(N'Cao su',            N'Tây Ninh',    18300,  N'đ/kg', N'simulated-market'),
(N'Sầu riêng',         N'Đắk Lắk',     85000,  N'đ/kg', N'simulated-market'),
(N'Sầu riêng',         N'Tiền Giang',  90000,  N'đ/kg', N'simulated-market'),
(N'Sầu riêng',         N'Lâm Đồng',   82000,  N'đ/kg', N'simulated-market'),
(N'Thanh long',        N'Bình Thuận',  12000,  N'đ/kg', N'simulated-market'),
(N'Thanh long',        N'Long An',     11500,  N'đ/kg', N'simulated-market'),
(N'Mít Thái',          N'Đồng Nai',    18000,  N'đ/kg', N'simulated-market'),
(N'Mít Thái',          N'Tây Ninh',    17500,  N'đ/kg', N'simulated-market'),
(N'Chanh leo',         N'Gia Lai',     25000,  N'đ/kg', N'simulated-market'),
(N'Chanh leo',         N'Lâm Đồng',   24000,  N'đ/kg', N'simulated-market'),
(N'Bơ',                N'Đắk Lắk',    22000,  N'đ/kg', N'simulated-market'),
(N'Bơ',                N'Lâm Đồng',   20000,  N'đ/kg', N'simulated-market'),
(N'Xoài cát Hòa Lộc',  N'Tiền Giang', 45000,  N'đ/kg', N'simulated-market'),
(N'Xoài',              N'An Giang',    28000,  N'đ/kg', N'simulated-market'),
(N'Xoài',              N'Đồng Tháp',  27500,  N'đ/kg', N'simulated-market'),
(N'Lúa gạo IR 504',    N'An Giang',    8200,   N'đ/kg', N'simulated-market'),
(N'Lúa gạo',           N'Hậu Giang',   8000,   N'đ/kg', N'simulated-market'),
(N'Lúa gạo',           N'Kiên Giang',  8100,   N'đ/kg', N'simulated-market'),
(N'Dừa khô',           N'Tiền Giang', 11500,  N'đ/kg', N'simulated-market'),
(N'Dừa khô',           N'Bến Tre',    12000,  N'đ/kg', N'simulated-market'),
(N'Ớt đỏ',             N'Gia Lai',    35000,  N'đ/kg', N'simulated-market'),
(N'Chuối tiêu',        N'Đồng Nai',   18000,  N'đ/kg', N'simulated-market'),
(N'Nhãn',              N'Hưng Yên',   35000,  N'đ/kg', N'simulated-market'),
(N'Vải thiều',         N'Bắc Giang',  30000,  N'đ/kg', N'simulated-market');

PRINT 'Re-inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' market prices with correct Unicode encoding';
GO

-- Verify
SELECT TOP 5 ProductName, RegionName, Price FROM MarketPrices ORDER BY PriceID;
GO
