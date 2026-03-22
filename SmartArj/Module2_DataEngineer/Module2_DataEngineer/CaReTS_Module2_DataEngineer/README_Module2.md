# CaReTS – Module 2: Data Engineer

## Mô tả

Pipeline tự động thu thập, làm sạch và lưu dữ liệu thời tiết lịch sử từ
**Open-Meteo Archive API** vào SQL Server (`SmartAgri_PRJ301`).

| Nhiệm vụ | Cách thực hiện |
|---|---|
| Thu thập dữ liệu tự động | `fetch_weather_12h()` → Open-Meteo API |
| Kiểm soát chất lượng | `validate_and_clean()` – bỏ null, outlier, clamp âm |
| Tránh trùng bản ghi | T-SQL `MERGE` (upsert) |
| Audit trail | Bảng `FetchLogs` + `vw_FetchSummary` |
| Tự động hóa | Windows Task Scheduler – 07:00 mỗi ngày |
| Monitor freshness | `vw_DataFreshness` – FRESH / WARNING / STALE |

---

## Yêu cầu hệ thống

| Thành phần | Phiên bản |
|---|---|
| Python | 3.9+ |
| SQL Server | 2017+ (hoặc Express) |
| ODBC Driver | 17 for SQL Server |
| Windows | 10/11 (Task Scheduler) |

---

## Cài đặt

### Bước 1 – Cài thư viện Python

```bash
pip install -r requirements.txt
```

### Bước 2 – Cấu hình kết nối Database

```bash
copy .env.example .env
```

Mở `.env` và sửa đúng thông tin máy của bạn:

```
DB_SERVER=YourServer\SQLEXPRESS
DB_NAME=SmartAgri_PRJ301
DB_DRIVER=ODBC Driver 17 for SQL Server
```

> ⚠️ File `.env` **không được commit** lên Git (đã có trong `.gitignore`).

---

## Khởi tạo Database (chạy 1 lần)

Chạy theo thứ tự trên **SQL Server Management Studio**:

```
1. sql/SmartAgri_Setup.sql    ← Tạo DB, bảng Zones / Cities / WeatherLogs
2. sql/add_fetchlogs.sql      ← Tạo bảng FetchLogs + Views monitor
```

Sau đó seed dữ liệu zone:

```bash
python setup_zones.py
```

---

## Chạy pipeline

### Thủ công (test)

```bash
python fetch_weather_to_db.py
```

### Tự động hóa – Khuyến nghị

Chuột phải `run_task_scheduler.bat` → **Run as administrator**

→ Task `CaReTS_WeatherFetch` chạy tự động lúc **07:00 mỗi ngày**.

Kiểm tra task đã đăng ký:
```bat
schtasks /query /tn "CaReTS_WeatherFetch" /fo LIST
```

---

## Kiểm tra pipeline hoạt động

Chạy 3 câu SQL sau trên SSMS:

```sql
-- 1. Tổng số bản ghi (phải > 0)
SELECT COUNT(*) AS TotalRows FROM WeatherLogs;

-- 2. Trạng thái lần fetch gần nhất (phải có Status = 'SUCCESS')
SELECT TOP 3 ZoneID, FetchTime, Status, RowsFetched, RowsInserted, RowsRejected
FROM vw_FetchSummary;

-- 3. Độ tươi của dữ liệu từng zone (phải có FreshnessStatus = 'FRESH')
SELECT ZoneID, CityName, ZoneName, LatestRecord, FreshnessStatus
FROM vw_DataFreshness;
```

---

## Cấu trúc file log

| File | Nội dung | Rotation |
|---|---|---|
| `fetch_log.txt` | Log chi tiết từng record (INFO / WARNING / ERROR) | 5 MB × 3 bản |
| `subprocess_log.txt` | stdout + stderr của scheduler | Append |

---

## Cấu trúc project

```
CaReTS_Module2_DataEngineer/
├── README_Module2.md
├── requirements.txt
├── .env.example
├── .gitignore
├── fetch_weather_to_db.py      ← pipeline chính
├── setup_zones.py
├── schedule_daily.py
├── run_task_scheduler.bat
├── clean_project.bat
└── sql/
    ├── SmartAgri_Setup.sql
    ├── add_fetchlogs.sql
    └── check_freshness.sql
```
