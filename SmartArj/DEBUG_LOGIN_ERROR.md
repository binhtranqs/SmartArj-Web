# Hướng Dẫn Debug Lỗi HTTP 500 Khi Đăng Nhập

## 🔍 Các Bước Debug

### Bước 1: Test Page Đơn Giản
Truy cập: `http://localhost:8080/SmartArj/simple_test.jsp`

Trang này sẽ test từng bước:
1. Load User class
2. Tạo User object
3. Gọi isVIP()
4. Gọi getDaysRemaining()

**Nếu có lỗi**, trang sẽ hiển thị:
- Error message
- Error type
- Stack trace đầy đủ

### Bước 2: Clean and Build (QUAN TRỌNG!)

**Trong NetBeans:**
1. Right-click vào project "SmartArj"
2. Chọn "Clean and Build" (hoặc Shift+F11)
3. Đợi build hoàn tất
4. Xem Output window - đảm bảo "BUILD SUCCESSFUL"

**Nếu Build Failed:**
- Copy error message từ Output window
- Có thể là lỗi compile trong UserDAO.java

### Bước 3: Restart Server

1. Stop server trong NetBeans
2. Start lại server
3. Đợi server khởi động xong

### Bước 4: Clear Browser Cache

1. Mở DevTools (F12)
2. Right-click vào nút Refresh
3. Chọn "Empty Cache and Hard Reload"

### Bước 5: Test Login Lại

1. Truy cập: `http://localhost:8080/SmartArj/login`
2. Đăng nhập
3. Nếu vẫn lỗi, xem NetBeans Output window

## 🐛 Các Lỗi Thường Gặp

### Lỗi 1: JPA Detached Entity
**Triệu chứng:** HTTP 500 khi truy cập dashboard
**Nguyên nhân:** User object trong session bị detached
**Giải pháp:** Đã fix trong UserDAO.checkLogin() - cần Clean & Build

### Lỗi 2: Missing getDaysRemaining() Method
**Triệu chứng:** NoSuchMethodError
**Nguyên nhân:** Code cũ chưa được compile
**Giải pháp:** Clean & Build project

### Lỗi 3: NullPointerException
**Triệu chứng:** NPE khi gọi user.getDaysRemaining()
**Nguyên nhân:** vipExpiryDate = null
**Giải pháp:** Method đã handle null, cần Clean & Build

## 📝 Checklist

- [ ] Chạy simple_test.jsp - xem có lỗi không
- [ ] Clean and Build project
- [ ] Restart server
- [ ] Clear browser cache
- [ ] Test login lại
- [ ] Nếu vẫn lỗi, check NetBeans Output window

## 🆘 Nếu Vẫn Không Được

Gửi cho tôi:
1. Screenshot của simple_test.jsp
2. Error message từ NetBeans Output window
3. Build output (nếu build failed)
