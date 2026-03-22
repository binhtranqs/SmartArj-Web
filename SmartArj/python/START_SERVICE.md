# Hướng Dẫn Start Python Forecast Service

## 📋 Yêu Cầu

Trước khi start service, đảm bảo bạn đã cài đặt:
- Python 3.8+
- Các thư viện cần thiết (Flask, PyTorch, pyodbc, pandas, etc.)

## 🚀 Cách Start Service

### Bước 1: Mở Terminal/Command Prompt

Mở terminal trong thư mục `python`:
```bash
cd c:\Users\LENOVO\Documents\NetBeansProjects\SmartArj\python
```

### Bước 2: Activate Virtual Environment (Nếu Có)

Nếu bạn đang dùng virtual environment:
```bash
# Windows
venv\Scripts\activate

# Sau khi activate, bạn sẽ thấy (venv) ở đầu dòng
```

### Bước 3: Cài Đặt Dependencies (Nếu Chưa Cài)

```bash
pip install flask flask-cors torch numpy pyodbc pandas
```

### Bước 4: Start Service

```bash
python app.py
```

### ✅ Kết Quả Mong Đợi

Bạn sẽ thấy output tương tự:
```
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://0.0.0.0:5001
Press CTRL+C to quit
```

## 🔍 Test Service

Sau khi service chạy, test bằng cách truy cập:
```
http://localhost:5001/health
```

Bạn sẽ thấy response:
```json
{
  "status": "ok",
  "drivers": ["ODBC Driver 17 for SQL Server", ...]
}
```

## 🎯 Test Forecast API

Test forecast cho Hà Nội:
```
http://localhost:5001/predict?city=HaNoi
```

## ⚠️ Lưu Ý Quan Trọng

### 1. Database Connection

Service cần kết nối database với config:
- **Server:** localhost
- **Database:** SmartAgri_PRJ301
- **User:** sa
- **Password:** 123

Nếu database config khác, sửa trong `app.py` (lines 92-96) hoặc set environment variables:
```bash
set DB_SERVER=localhost
set DB_NAME=SmartArj_PRJSEM
set DB_USER=sa
set DB_PASS=123
```

### 2. CityID Mapping

File `app.py` có mapping CityID (lines 44-55):
```python
CITY_ID_MAP = {
    "HaNoi": 1,
    "DaNang": 2,
    ...
}
```

**QUAN TRỌNG:** Bạn đã đổi tên bảng `CityID` → `Cities`, nhưng CityID values vẫn giữ nguyên:
- Đà Nẵng = CityID 1
- Hà Nội = CityID 2

Cần sửa mapping trong `app.py` cho đúng!

### 3. Model Files

Service cần các file model PyTorch (.pth) trong thư mục:
```
python/models/HaNoi/Model_Temperature.pth
python/models/HaNoi/Model_Humidity.pth
...
```

Nếu thiếu model files, forecast sẽ trả về 0.

## 🐛 Troubleshooting

### Lỗi: "No module named 'flask'"
```bash
pip install flask flask-cors
```

### Lỗi: "No module named 'torch'"
```bash
pip install torch
```

### Lỗi: "ODBC Driver not found"
Cài ODBC Driver 17 hoặc 18 for SQL Server

### Lỗi: Database connection failed
Kiểm tra:
- SQL Server đang chạy
- Database name đúng (SmartArj_PRJSEM)
- Username/password đúng

## 📝 Sau Khi Start Service

1. **Giữ terminal mở** - Service sẽ chạy trong terminal này
2. **Refresh dashboard** trong browser
3. **Test forecast** - Lỗi API Error 502 sẽ biến mất

## 🛑 Stop Service

Nhấn `Ctrl+C` trong terminal để stop service.
