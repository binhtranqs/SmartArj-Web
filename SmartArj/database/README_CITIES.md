# Hướng Dẫn Sửa Lỗi Cities - Bước Cuối Cùng

## 📋 Tình Huống
- CityID 1 và 2 có dữ liệu NULL (không có Region, Latitude, Longitude)
- Cần xóa 2 hàng này và insert lại đầy đủ thông tin

## 🚀 Các Bước Thực Hiện (Theo Thứ Tự)

### Bước 1: Xóa 2 hàng NULL
```sql
-- Chạy file: database/delete_null_cities.sql
```
Script này sẽ xóa CityID 1 và 2 (hàng có NULL data).

### Bước 2: Insert lại tất cả 10 cities
```sql
-- Chạy file: database/insert_all_cities.sql
```
Script này sẽ insert đầy đủ 10 cities với CityID từ 1-10.

## ✅ Kết Quả Mong Đợi

Sau khi chạy 2 scripts, bạn sẽ có:

| CityID | CityName | Region | Latitude | Longitude |
|--------|----------|--------|----------|-----------|
| 1 | Đà Nẵng | Miền Trung | 16.0544 | 108.2022 |
| 2 | Hà Nội | Miền Bắc | 21.0285 | 105.8542 |
| 3 | Hồ Chí Minh | Miền Nam | 10.8231 | 106.6297 |
| 4 | Cần Thơ | Miền Nam | 10.0452 | 105.7469 |
| 5 | Đà Lạt | Miền Nam | 11.9404 | 108.4583 |
| 6 | Đắk Lắk | Tây Nguyên | 12.6667 | 108.0500 |
| 7 | Hải Phòng | Miền Bắc | 20.8449 | 106.6881 |
| 8 | Huế | Miền Trung | 16.4637 | 107.5909 |
| 9 | Nha Trang | Miền Trung | 12.2388 | 109.1967 |
| 10 | Sapa | Miền Bắc | 22.3364 | 103.8438 |

## 📝 Lưu Ý

- Không cần lo về Zones và Users - chúng sẽ tự động liên kết lại khi Cities được insert
- Nếu có foreign key constraint error, chạy script `restore_hanoi_danang.sql` thay thế
