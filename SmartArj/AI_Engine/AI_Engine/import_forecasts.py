"""
import_forecasts.py
Đổ dữ liệu forecast từ outputs/<city>/forecast_next7_*.csv vào bảng Forecasts trong SQL Server.
Chạy: python import_forecasts.py
"""

import os
import sys
import io
import csv
import pyodbc

# Fix console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

# ─── CẤU HÌNH ────────────────────────────────────────────────────
BASE    = os.path.dirname(os.path.abspath(__file__))
OUTPUTS = os.path.join(BASE, "outputs")

# Connection string SQL Server 
CONN_STR = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost,1433;"
    "DATABASE=SmartAgri_PRJ301;"
    "UID=sa;"
    "PWD=123;"
    "TrustServerCertificate=yes;"
)

# Mapping: tên folder → CityID trong DB
CITY_MAP = {
    "cantho":  11,   # CanTho
    "daklak":  14,   # DakLak
    "dalat":   12,   # DaLat
    "danang":  13,   # DaNang
    "hanoi":   15,   # HaNoi
    "hcm":     17,   # HoChiMinh
}
# ─────────────────────────────────────────────────────────────────

def get_zone_id(cursor, city_id):
    """Lấy ZoneID đầu tiên của city (để đổ vào cột ZoneID bắt buộc)."""
    cursor.execute("SELECT TOP 1 ZoneID FROM Zones WHERE CityID = ? ORDER BY ZoneID", city_id)
    row = cursor.fetchone()
    return row[0] if row else 1

def import_city(cursor, city_folder, city_id):
    """Đọc CSV và upsert vào bảng Forecasts."""
    temp_csv = os.path.join(city_folder, "forecast_next7_temp_avg.csv")
    rh_csv   = os.path.join(city_folder, "forecast_next7_rh_avg.csv")

    # Đọc Temperature
    temp_data = {}   # date → y_pred
    if os.path.exists(temp_csv):
        with open(temp_csv, encoding="utf-8") as f:
            for row in csv.DictReader(f):
                d = row["date"].strip()
                if d:
                    temp_data[d] = float(row["y_pred"])

    # Đọc Humidity
    rh_data = {}
    if os.path.exists(rh_csv):
        with open(rh_csv, encoding="utf-8") as f:
            for row in csv.DictReader(f):
                d = row["date"].strip()
                if d:
                    rh_data[d] = float(row["y_pred"])

    all_dates = sorted(set(list(temp_data.keys()) + list(rh_data.keys())))
    if not all_dates:
        print(f"  [SKIP] Không có dữ liệu trong {city_folder}")
        return 0

    zone_id = get_zone_id(cursor, city_id)
    inserted = 0
    updated  = 0

    for date in all_dates:
        temp = temp_data.get(date)
        rh   = rh_data.get(date)

        # Kiểm tra đã có record chưa (theo ZoneID + ForecastDate)
        cursor.execute(
            "SELECT ForecastID FROM Forecasts WHERE ZoneID = ? AND ForecastDate = ?",
            zone_id, date
        )
        existing = cursor.fetchone()

        if existing:
            # UPDATE
            cursor.execute("""
                UPDATE Forecasts
                SET Temperature = ?,
                    CreatedAt   = GETDATE()
                WHERE ForecastID = ?
            """, temp, existing[0])
            updated += 1
        else:
            # INSERT
            cursor.execute("""
                INSERT INTO Forecasts (ZoneID, ForecastDate, Temperature, CreatedAt)
                VALUES (?, ?, ?, GETDATE())
            """, zone_id, date, temp)
            inserted += 1

    return inserted, updated


def main():
    print("=" * 55)
    print("  SmartAgri — Import AI Forecasts → SQL Server")
    print("=" * 55)

    try:
        conn = pyodbc.connect(CONN_STR, autocommit=False)
    except Exception as e:
        print(f"[ERROR] Kết nối DB thất bại: {e}")
        print("Kiểm tra lại CONN_STR trong file này.")
        return

    cursor = conn.cursor()
    total_ins = 0
    total_upd = 0

    for folder_name, city_id in CITY_MAP.items():
        folder_path = os.path.join(OUTPUTS, folder_name)
        if not os.path.isdir(folder_path):
            print(f"[SKIP] Thư mục không tồn tại: {folder_path}")
            continue

        print(f"\n→ {folder_name.upper()} (CityID={city_id})")
        try:
            ins, upd = import_city(cursor, folder_path, city_id)
            print(f"   Inserted: {ins}  |  Updated: {upd}")
            total_ins += ins
            total_upd += upd
        except Exception as e:
            print(f"   [ERROR] {e}")
            conn.rollback()
            continue

    conn.commit()
    cursor.close()
    conn.close()

    print("\n" + "=" * 55)
    print(f"  DONE!  Tổng inserted={total_ins}  updated={total_upd}")
    print("=" * 55)


if __name__ == "__main__":
    main()
