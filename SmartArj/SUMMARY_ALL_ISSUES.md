# Tổng Hợp Tất Cả Các Vấn Đề Đã Fix & Còn Lại

## ✅ ĐÃ FIX THÀNH CÔNG

### 1. Login Error (HTTP 500)
- **Nguyên nhân:** JPA detached entity trong UserDAO
- **Giải pháp:** Sửa `UserDAO.checkLogin()` để return fresh user từ DB
- **Status:** ✅ FIXED (cần Clean & Build project)

### 2. Cities Table Error
- **Nguyên nhân:** Bảng tên `CityID` nhưng code query `Cities`
- **Giải pháp:** Đổi tên bảng `CityID` → `Cities`
- **Script:** `FIX_ALL_DATABASE_ISSUES.sql`
- **Status:** ✅ FIXED

### 3. WeatherLogs Missing Columns
- **Nguyên nhân:** Thiếu cột `WindSpeed`, `Rainfall`
- **Giải pháp:** ALTER TABLE thêm các cột
- **Script:** `FIX_ALL_DATABASE_ISSUES.sql`
- **Status:** ✅ FIXED

### 4. Python Forecast Service Config
- **Nguyên nhân:** CityID mapping sai, database name sai
- **Giải pháp:** Sửa `app.py` - DaNang=1, HaNoi=2, DB=SmartArj_PRJSEM
- **Status:** ✅ FIXED

## ⚠️ VẤN ĐỀ CÒN LẠI

### Forecast API Error 502

**Hiện tượng:**
- Python service chạy OK (`/health` trả về 200)
- Dashboard gọi `/api/forecast?zoneId=X` → Lỗi 502

**Nguyên nhân có thể:**

#### 1. Thiếu Dữ Liệu WeatherLogs
Python service cần **30 bản ghi** tại mốc 12:00 trưa để dự báo.

**Kiểm tra:**
```sql
-- Kiểm tra số lượng records tại mốc 12h cho zone
SELECT COUNT(*) 
FROM WeatherLogs 
WHERE ZoneID = 1 
  AND DATEPART(HOUR, RecordedAt) = 12;
```

**Nếu < 30 records:** Cần thêm dữ liệu mẫu

#### 2. Thiếu Model Files
Python service cần file `.pth` trong `python/models/`:
```
python/models/DaNang/Model_Temperature.pth
python/models/DaNang/Model_Humidity.pth
python/models/DaNang/Model_Rainfall.pth
python/models/DaNang/Model_Wind.pth
python/models/DaNang/Model_Radiation.pth
```

**Nếu thiếu:** Forecast sẽ trả về 0 hoặc lỗi

#### 3. Zone Không Tồn Tại
Dashboard gọi với `zoneId` không có trong database.

**Kiểm tra:**
```sql
SELECT * FROM Zones WHERE CityID IN (1, 2);
```

## 🔍 CÁCH DEBUG

### Bước 1: Kiểm Tra Python Service Logs

Khi dashboard gọi API, xem terminal chạy Python service:
- Có request đến không?
- Error message là gì?

### Bước 2: Test Trực Tiếp Python API

```
http://localhost:5001/predict?city=DaNang
```

**Nếu lỗi:**
- Copy error message
- Kiểm tra database có đủ dữ liệu không

### Bước 3: Kiểm Tra Java Servlet Logs

Xem NetBeans Output window khi gọi `/api/forecast`:
- ForecastServlet có nhận request không?
- Lỗi gì khi gọi Python service?

### Bước 4: Kiểm Tra Browser Console

F12 → Console tab:
- Request URL là gì?
- Response status code?
- Response body?

## 📋 CHECKLIST ĐỂ FIX FORECAST

- [ ] Chạy `FIX_ALL_DATABASE_ISSUES.sql` (Cities, WeatherLogs columns)
- [ ] Clean & Build project Java
- [ ] Restart Java server
- [ ] Start Python service (`python/start_service.bat`)
- [ ] Kiểm tra WeatherLogs có đủ 30 records tại mốc 12h
- [ ] Kiểm tra Zones table có data với CityID=1,2
- [ ] Test Python API trực tiếp: `http://localhost:5001/predict?city=DaNang`
- [ ] Xem Python service logs khi dashboard gọi API
- [ ] Kiểm tra model files trong `python/models/`

## 🆘 NẾU VẪN KHÔNG ĐƯỢC

Gửi cho tôi:
1. **Python service logs** khi dashboard gọi API
2. **Browser console** error message
3. **Kết quả query:**
   ```sql
   SELECT COUNT(*) FROM WeatherLogs WHERE ZoneID=1 AND DATEPART(HOUR,RecordedAt)=12;
   SELECT * FROM Zones WHERE CityID IN (1,2);
   ```
4. **Screenshot** lỗi trên dashboard

## 📝 GHI CHÚ

- Chatbot đang hoạt động OK (mock response)
- Dashboard hiển thị OK
- Chỉ còn forecast API cần fix
- Có thể tạm thời dùng mock data cho forecast nếu cần test UI
