import sys
import io
# Fix Unicode encoding cho Windows terminal / Task Scheduler
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

import requests
import pyodbc
from datetime import date, timedelta, datetime, timezone
import time

# ====== CONFIG: Sửa lại cho đúng máy của bạn ======
SERVER = "DESKTOP-NI4P9VK" 
DATABASE = "SmartAgri_PRJ301"
DRIVER = "ODBC Driver 17 for SQL Server" 

HISTORY_DAYS = 90
ARCHIVE_URL  = "https://archive-api.open-meteo.com/v1/archive"
FORECAST_URL = "https://api.open-meteo.com/v1/forecast"   # Có dữ liệu gần real-time

def get_conn():
    return pyodbc.connect(
        f"DRIVER={{{DRIVER}}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

def _parse_hourly_12h(h) -> list:
    """Trích 1 bản ghi/ngày tại mốc 12:00 từ hourly response của Open-Meteo."""
    times = h["time"]
    rows = []
    for i in range(len(times)):
        if "T12:00" in times[i]:
            db_time = times[i].replace("T", " ") + ":00"
            rows.append((
                db_time,
                h["temperature_2m"][i],
                h["relative_humidity_2m"][i],
                h["rain"][i],
                h["wind_speed_10m"][i],
                h["shortwave_radiation"][i],
            ))
    return rows

def fetch_weather_12h(lat: float, lon: float, start_date: str, end_date: str) -> list:
    """Lấy dữ liệu lịch sử (>5 ngày trước) từ Archive API."""
    params = {
        "latitude": lat,
        "longitude": lon,
        "start_date": start_date,
        "end_date": end_date,
        "hourly": "temperature_2m,relative_humidity_2m,rain,wind_speed_10m,shortwave_radiation",
        "timezone": "Asia/Ho_Chi_Minh"
    }
    r = requests.get(ARCHIVE_URL, params=params, timeout=60)
    r.raise_for_status()
    return _parse_hourly_12h(r.json()["hourly"])

def fetch_recent_weather_12h(lat: float, lon: float, past_days: int = 6) -> list:
    """Lấy dữ liệu 6 ngày gần nhất (kể cả hôm nay) từ Forecast API."""
    params = {
        "latitude": lat,
        "longitude": lon,
        "past_days": past_days,
        "forecast_days": 1,          # chỉ cần hôm nay, không cần tương lai
        "hourly": "temperature_2m,relative_humidity_2m,rain,wind_speed_10m,shortwave_radiation",
        "timezone": "Asia/Ho_Chi_Minh"
    }
    r = requests.get(FORECAST_URL, params=params, timeout=60)
    r.raise_for_status()
    return _parse_hourly_12h(r.json()["hourly"])

def delete_existing(conn, zone_id: int, start_date: str, end_date: str):
    sql = "DELETE FROM WeatherLogs WHERE ZoneID = ? AND RecordedAt >= ? AND RecordedAt < DATEADD(day, 1, ?)"
    cur = conn.cursor()
    cur.execute(sql, (zone_id, start_date, end_date))
    conn.commit()

def insert_rows(conn, zone_id: int, rows):
    sql = "INSERT INTO WeatherLogs (ZoneID, RecordedAt, Temperature, Humidity, Rainfall, Wind, Radiation) VALUES (?, ?, ?, ?, ?, ?, ?)"
    cur = conn.cursor()
    for r in rows:
        cur.execute(sql, (zone_id, r[0], r[1], r[2], r[3], r[4], r[5]))
    conn.commit()

def main():
    # Ensure GMT+7 so `today` does not roll over incorrectly at 00:00 UTC
    tz_vn = timezone(timedelta(hours=7))
    today_vn = datetime.now(tz_vn).date()

    # Archive: lấy dữ liệu lịch sử (từ 90 ngày trước đến 6 ngày trước)
    archive_end   = today_vn - timedelta(days=6)
    archive_start = archive_end - timedelta(days=HISTORY_DAYS)
    archive_start_s = archive_start.strftime("%Y-%m-%d")
    archive_end_s   = archive_end.strftime("%Y-%m-%d")

    # Recent: lấy 6 ngày gần nhất (kể cả hôm nay) từ Forecast API
    recent_start_s = (today_vn - timedelta(days=6)).strftime("%Y-%m-%d")
    recent_end_s   = today_vn.strftime("%Y-%m-%d")

    try:
        conn = get_conn()
        cur  = conn.cursor()

        query = """
            SELECT z.ZoneID, c.CityName, z.ZoneName, z.Latitude, z.Longitude 
            FROM Zones z
            JOIN Cities c ON z.CityID = c.CityID
        """
        cur.execute(query)
        zones = cur.fetchall()

        if not zones:
            print("Loi: Chua co vung trong (Zones) hoac Thanh pho (Cities) trong DB.")
            return

        for z in zones:
            zone_id = int(z.ZoneID)
            print(f"\n[Zone] {z.CityName} - {z.ZoneName}")

            # --- 1. Lịch sử (Archive API) ---
            archive_rows = fetch_weather_12h(float(z.Latitude), float(z.Longitude),
                                             archive_start_s, archive_end_s)
            if archive_rows:
                delete_existing(conn, zone_id, archive_start_s, archive_end_s)
                insert_rows(conn, zone_id, archive_rows)
                print(f"  [Archive] Cap nhat {len(archive_rows)} ban ghi ({archive_start_s} -> {archive_end_s})")

            time.sleep(0.5)

            # --- 2. Gần đây (Forecast API, past_days=6) ---
            try:
                recent_rows = fetch_recent_weather_12h(float(z.Latitude), float(z.Longitude), past_days=6)
                if recent_rows:
                    delete_existing(conn, zone_id, recent_start_s, recent_end_s)
                    insert_rows(conn, zone_id, recent_rows)
                    print(f"  [Recent]  Cap nhat {len(recent_rows)} ban ghi ({recent_start_s} -> {recent_end_s})")
            except Exception as ex:
                print(f"  [Recent]  WARN: {ex}")

            time.sleep(0.5)

        conn.close()
        print("\nXONG: Toan bo du lieu da duoc dong bo!")

    except Exception as e:
        print(f"Loi he thong: {e}")

if __name__ == "__main__":
    main()