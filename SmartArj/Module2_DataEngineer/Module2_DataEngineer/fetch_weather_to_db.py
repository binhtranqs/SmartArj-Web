import sys
import io
import os
import requests
import pyodbc
import logging
from logging.handlers import RotatingFileHandler
from datetime import date, datetime, timedelta, timezone
from dotenv import load_dotenv
import time

# ===== FIX CONSOLE ENCODING (Windows cp1252) =====
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

# ===== LOGGING SETUP (path cố định theo thư mục script) =====
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_FILE   = os.path.join(SCRIPT_DIR, "fetch_log.txt")

_handler = RotatingFileHandler(
    LOG_FILE,
    maxBytes=5 * 1024 * 1024,   # 5 MB mỗi file
    backupCount=3,               # giữ tối đa 3 bản backup
    encoding="utf-8"
)
_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))

logger = logging.getLogger("weather_pipeline")
logger.setLevel(logging.INFO)
logger.addHandler(_handler)

# ===== CONFIG – đọc từ .env (nếu có), fallback về giá trị mặc định =====
# Tạo file .env từ .env.example rồi điền đúng thông tin máy của bạn
load_dotenv(dotenv_path=os.path.join(SCRIPT_DIR, ".env"))

SERVER      = os.environ.get("DB_SERVER",   "localhost")
DATABASE    = os.environ.get("DB_NAME",     "SmartAgri_PRJ301")
DRIVER      = os.environ.get("DB_DRIVER",   "ODBC Driver 17 for SQL Server")
DB_UID      = os.environ.get("DB_UID",      "sa")
DB_PWD      = os.environ.get("DB_PWD",      "123")

HISTORY_DAYS  = 90
END_LAG_DAYS  = 5          # Archive API thường lag 2-5 ngày
ARCHIVE_URL   = "https://archive-api.open-meteo.com/v1/archive"
TIMEZONE      = "Asia/Ho_Chi_Minh"

# ===== OUTLIER THRESHOLDS =====
TEMP_MIN, TEMP_MAX   = -30.0, 55.0   # °C
HUMID_MIN, HUMID_MAX =   0.0, 100.0  # %
WIND_MIN             =   0.0          # km/h
RAIN_MIN             =   0.0          # mm
RAD_MIN              =   0.0          # W/m²


# ==========================================================
# 1. DATABASE CONNECTION
# ==========================================================
def get_conn():
    return pyodbc.connect(
        f"DRIVER={{{DRIVER}}};"
        f"SERVER={SERVER},1433;"
        f"DATABASE={DATABASE};"
        f"UID={DB_UID};"
        f"PWD={DB_PWD};"
        "TrustServerCertificate=yes;"
        "Encrypt=yes;"
    )


# ==========================================================
# 2. FETCH TỪ OPEN-METEO ARCHIVE API
# ==========================================================
def fetch_weather_12h(lat: float, lon: float, start_date: str, end_date: str):
    """
    Lấy snapshot 12:00 mỗi ngày từ Open-Meteo Archive.
    Tự lùi end_date nếu API trả 400 (data chưa có).
    """
    params = {
        "latitude":  lat,
        "longitude": lon,
        "start_date": start_date,
        "end_date":   end_date,
        "hourly": "temperature_2m,relative_humidity_2m,rain,wind_speed_10m,shortwave_radiation",
        "timezone": TIMEZONE
    }

    base_end = date.fromisoformat(end_date)
    for back in range(0, 15):
        if back > 0:
            params["end_date"] = (base_end - timedelta(days=back)).strftime("%Y-%m-%d")

        r = requests.get(ARCHIVE_URL, params=params, timeout=60)

        if r.status_code == 200:
            j = r.json()
            h = j["hourly"]
            times = h["time"]

            rows = []
            for i, t in enumerate(times):
                if "T12:00" in t:
                    db_time = t.replace("T", " ") + ":00"
                    rows.append((
                        db_time,
                        h["temperature_2m"][i],
                        h["relative_humidity_2m"][i],
                        h["rain"][i],
                        h["wind_speed_10m"][i],
                        h["shortwave_radiation"][i],
                    ))
            return rows

        if r.status_code == 400:
            print(f"  API 400 (end_date={params['end_date']}). Lui them 1 ngay...")
            continue

        raise RuntimeError(f"API error {r.status_code}: {r.text[:300]}")

    raise RuntimeError("API lien tuc 400 sau khi da lui end_date nhieu ngay.")


# ==========================================================
# 3. DATA VALIDATION & CLEANING  ← MỚI
# ==========================================================
def validate_and_clean(rows: list, zone_label: str = "") -> tuple[list, int]:
    """
    Lọc và làm sạch dữ liệu trước khi insert DB.

    Chiến lược:
      - Bỏ record mà TẤT CẢ giá trị đều None.
      - Clamp giá trị về 0 nếu âm bất hợp lệ (rain, wind, radiation).
      - Bỏ (skip) record có nhiệt độ hoặc humidity ngoài dải cho phép.

    Returns:
        clean_rows : list rows đã sạch
        rejected   : số records bị loại
    """
    clean  = []
    rejected = 0

    for r in rows:
        recorded_at, temp, humid, rain, wind, rad = r

        # --- Skip nếu toàn None ---
        if all(v is None for v in [temp, humid, rain, wind, rad]):
            rejected += 1
            logger.warning(
                f"[{zone_label}] SKIP toàn None @ {recorded_at}"
            )
            continue

        # --- Validate nhiệt độ ---
        if temp is not None:
            if not (TEMP_MIN <= temp <= TEMP_MAX):
                rejected += 1
                logger.warning(
                    f"[{zone_label}] SKIP temp={temp} ngoài dải [{TEMP_MIN},{TEMP_MAX}] @ {recorded_at}"
                )
                continue

        # --- Validate humidity ---
        if humid is not None:
            if not (HUMID_MIN <= humid <= HUMID_MAX):
                rejected += 1
                logger.warning(
                    f"[{zone_label}] SKIP humidity={humid} ngoài dải [0,100] @ {recorded_at}"
                )
                continue

        # --- Clamp rain (không âm) ---
        if rain is not None and rain < RAIN_MIN:
            logger.warning(f"[{zone_label}] CLAMP rain={rain} → 0 @ {recorded_at}")
            rain = 0.0

        # --- Clamp wind (không âm) ---
        if wind is not None and wind < WIND_MIN:
            logger.warning(f"[{zone_label}] CLAMP wind={wind} → 0 @ {recorded_at}")
            wind = 0.0

        # --- Clamp radiation (không âm) ---
        if rad is not None and rad < RAD_MIN:
            logger.warning(f"[{zone_label}] CLAMP radiation={rad} → 0 @ {recorded_at}")
            rad = 0.0

        clean.append((recorded_at, temp, humid, rain, wind, rad))

    return clean, rejected


# ==========================================================
# 4. UPSERT BẰNG MERGE  ← THAY DELETE+INSERT
# ==========================================================
def upsert_rows(conn, zone_id: int, rows: list) -> int:
    """
    Dùng T-SQL MERGE để upsert an toàn.
    Nếu (ZoneID, RecordedAt) đã tồn tại → UPDATE.
    Nếu chưa → INSERT.
    Trả về số rows thực sự được affected.
    """
    merge_sql = """
        MERGE WeatherLogs AS target
        USING (SELECT ? AS ZoneID,
                      CAST(? AS DATETIME) AS RecordedAt,
                      ? AS Temperature,
                      ? AS Humidity,
                      ? AS Rainfall,
                      ? AS Wind,
                      ? AS Radiation) AS src
        ON (target.ZoneID = src.ZoneID AND target.RecordedAt = src.RecordedAt)
        WHEN MATCHED THEN
            UPDATE SET
                Temperature = src.Temperature,
                Humidity    = src.Humidity,
                Rainfall    = src.Rainfall,
                Wind        = src.Wind,
                Radiation   = src.Radiation,
                DataType    = N'Quá khứ'
        WHEN NOT MATCHED THEN
            INSERT (ZoneID, RecordedAt, DataType, Temperature, Humidity, Rainfall, Wind, Radiation)
            VALUES (src.ZoneID, src.RecordedAt, N'Quá khứ',
                    src.Temperature, src.Humidity, src.Rainfall, src.Wind, src.Radiation);
    """
    cur = conn.cursor()
    count = 0
    for r in rows:
        cur.execute(merge_sql, (
            zone_id,
            r[0],   # RecordedAt
            r[1],   # Temperature
            r[2],   # Humidity
            r[3],   # Rainfall
            r[4],   # Wind
            r[5],   # Radiation
        ))
        count += cur.rowcount
    conn.commit()
    return count


# ==========================================================
# 5. FETCH LOGS (AUDIT TRAIL)  ← MỚI
# ==========================================================
def log_fetch(conn, zone_id: int, status: str, rows_fetched: int,
              rows_inserted: int, rows_rejected: int, error_msg: str = None):
    """Ghi 1 dòng vào bảng FetchLogs sau mỗi lần fetch 1 zone."""
    sql = """
        INSERT INTO FetchLogs
            (ZoneID, FetchTime, Status, RowsFetched, RowsInserted, RowsRejected, ErrorMsg)
        VALUES (?, GETDATE(), ?, ?, ?, ?, ?)
    """
    try:
        cur = conn.cursor()
        cur.execute(sql, (zone_id, status, rows_fetched, rows_inserted, rows_rejected, error_msg))
        conn.commit()
    except Exception as e:
        # Không để lỗi log ảnh hưởng pipeline chính
        print(f"  [WARN] Ghi FetchLogs that bai: {e}")


# ==========================================================
# 6. MAIN
# ==========================================================
def main():
    # Ensure GMT+7 so `today` does not roll over incorrectly at 00:00 UTC
    tz_vn = timezone(timedelta(hours=7))
    today_vn = datetime.now(tz_vn).date()
    
    end   = today_vn - timedelta(days=END_LAG_DAYS)
    start = end - timedelta(days=HISTORY_DAYS)
    start_s = start.strftime("%Y-%m-%d")
    end_s   = end.strftime("%Y-%m-%d")

    run_ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{run_ts}] === CaReTS Weather Fetch ===")
    print(f"Khoang lay: {start_s} -> {end_s} (lag {END_LAG_DAYS} ngay)")
    logging.info(f"=== Bat dau fetch: {start_s} -> {end_s} ===")

    conn = None
    try:
        conn = get_conn()
        cur  = conn.cursor()

        cur.execute("""
            SELECT z.ZoneID, c.CityName, z.ZoneName, z.Latitude, z.Longitude
            FROM Zones z
            JOIN Cities c ON z.CityID = c.CityID
        """)
        zones = cur.fetchall()

        if not zones:
            print("LOI: Chua co Zones/Cities trong DB. Chay setup_zones.py truoc.")
            return

        total_inserted = 0

        for z in zones:
            zone_id    = int(z.ZoneID)
            city       = str(z.CityName)
            zone_name  = str(z.ZoneName)
            label      = f"{city} – {zone_name}"

            print(f"\n>>> {label} (ZoneID={zone_id})")
            logger.info(f"Fetch zone: {label}")

            try:
                raw_rows = fetch_weather_12h(
                    float(z.Latitude), float(z.Longitude), start_s, end_s
                )

                if not raw_rows:
                    print("  Khong co du lieu tra ve.")
                    log_fetch(conn, zone_id, "EMPTY", 0, 0, 0)
                    continue

                # ── DATA CLEANING ──────────────────────────────
                clean_rows, rejected = validate_and_clean(raw_rows, label)
                print(f"  Fetch: {len(raw_rows)} rows | Sau cleaning: {len(clean_rows)} rows | Reject: {rejected}")

                if not clean_rows:
                    print("  Toan bo rows bi reject sau cleaning.")
                    log_fetch(conn, zone_id, "ALL_REJECTED", len(raw_rows), 0, rejected)
                    continue

                # ── UPSERT (MERGE) ─────────────────────────────
                affected = upsert_rows(conn, zone_id, clean_rows)
                total_inserted += affected
                print(f"  DB affected: {affected} rows (MERGE)")
                logger.info(f"  {label}: {affected} rows upserted.")

                log_fetch(conn, zone_id, "SUCCESS",
                          len(raw_rows), affected, rejected)

            except Exception as zone_err:
                err_str = str(zone_err)[:500]
                print(f"  LOI zone {label}: {err_str}")
                logger.error(f"Zone {label}: {err_str}")
                log_fetch(conn, zone_id, "FAILED", 0, 0, 0, err_str)

            time.sleep(1)   # tránh rate-limit API

        print(f"\n=== XONG: Tong cong {total_inserted} rows upserted vao DB ===")
        logger.info(f"=== Ket thuc: {total_inserted} rows ===")

    except Exception as e:
        print(f"LOI HE THONG: {e}")
        logger.critical(f"LOI HE THONG: {e}")
        sys.exit(1)   # ← Task Scheduler sẽ phát hiện exit code != 0

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    main()
