-- Fix encoding: Xóa các events cũ bị lỗi encoding tiếng Việt trong Description
-- Sau khi chạy script này, hệ thống sẽ tự tạo events mới với encoding đúng
-- khi có hoạt động mới (đặt hàng, thanh toán, đăng sản phẩm, ...)

-- Xem trước các events bị lỗi (Description chứa ký tự bị vỡ)
SELECT EventId, EventType, Description, CreatedAt
FROM SystemEvents
ORDER BY CreatedAt DESC;

-- Xóa TẤT CẢ events cũ (reset để tạo events mới với encoding đúng)
-- Chỉ chạy dòng này nếu bạn muốn xóa hết events cũ:
-- TRUNCATE TABLE SystemEvents;

-- Hoặc chỉ xóa events trong ngày hôm nay:
DELETE FROM SystemEvents
WHERE CAST(CreatedAt AS DATE) <= CAST(GETDATE() AS DATE);

-- Xác nhận
SELECT COUNT(*) AS RemainingEvents FROM SystemEvents;
