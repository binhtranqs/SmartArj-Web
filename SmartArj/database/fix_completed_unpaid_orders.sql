-- Fix: Cập nhật các đơn hàng COMPLETED nhưng vẫn còn trạng thái UNPAID
-- COD: khi giao hàng hoàn thành = đã nhận tiền mặt => PAID
-- VNPay: có thể đã PAID từ trước, nhưng nếu chưa thì update luôn

UPDATE Orders
SET PaymentStatus = 'PAID',
    UpdatedAt = GETDATE()
WHERE Status = 'COMPLETED'
  AND (PaymentStatus IS NULL OR PaymentStatus = 'UNPAID');

-- Xác nhận kết quả
SELECT OrderID, Status, PaymentMethod, PaymentStatus, UpdatedAt
FROM Orders
WHERE Status = 'COMPLETED'
ORDER BY UpdatedAt DESC;
