-- ==============================
-- TEST 1: Xem ai đang là buyer (check tất cả user)
-- ==============================
SELECT UserID, Username, FullName, AccountType, Role, IsActive
FROM Users
ORDER BY UserID;

-- ==============================
-- TEST 2: Insert CartItem thủ công để test DB
-- Thay BuyerID=X bằng UserID của tài khoản bạn đang test
-- ListingID=1 (lấy từ Listings)
-- ==============================
INSERT INTO CartItems (BuyerID, ListingID, Quantity)
SELECT TOP 1 u.UserID, l.ListingID, 1
FROM Users u
CROSS JOIN Listings l
WHERE u.Username = 'vu'  -- <-- đổi thành username bạn đang đăng nhập
  AND l.Status = 'ACTIVE'
  AND l.ListingID = (SELECT MIN(ListingID) FROM Listings WHERE Status = 'ACTIVE');

-- Xem kết quả
SELECT * FROM CartItems;

-- ==============================
-- TEST 3: Nếu INSERT thành công, xóa test item đó
-- ==============================
-- DELETE FROM CartItems WHERE CartID = (SELECT MAX(CartID) FROM CartItems);
