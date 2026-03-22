import os
import sys
import io
import requests
import pyodbc
from datetime import datetime

# ==========================================
# CẤU HÌNH API VÀ DATABASE
# ==========================================
# Fix console encoding for Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

API_URL = "http://localhost:8001/predict-city"

CONN_STR = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost,1433;"
    "DATABASE=SmartAgri_PRJ301;"
    "UID=sa;"
    "PWD=123;"
    "TrustServerCertificate=yes;"
)

# Thống nhất với app.py của AI_Engine
CITY_MAP = {
    "cantho": 11,
    "daklak": 14,
    "dalat":  12,
    "danang": 13,
    "hanoi":  15,
    "hcm":    17,
}

def get_history_from_db(conn, zone_id, limit=90):
    cursor = conn.cursor()
    query = f"""
        SELECT TOP {limit}
            CAST(RecordedAt AS DATE) as RecordedAt,
            Temperature,
            Humidity,
            Rainfall
        FROM WeatherLogs
        WHERE ZoneID = ?
        ORDER BY RecordedAt DESC
    """
    cursor.execute(query, zone_id)
    rows = cursor.fetchall()
    
    history = []
    # Data is ordered by DESC, app.py prediction pipeline likely expects ASC but it sorts it anyway ("df = df.sort_values('date')")
    for row in rows:
        history.append({
            "RecordedAt": row[0].strftime("%Y-%m-%d"),
            "Temperature": float(row[1]) if row[1] is not None else 28.0,
            "Humidity": float(row[2]) if row[2] is not None else 70.0,
            "Rainfall": float(row[3]) if row[3] is not None else 0.0
        })
    return history

def run_predictions():
    print("=" * 60)
    print("  SmartAgri - Auto Daily Forecast Generator")
    print("=" * 60)
    
    try:
        conn = pyodbc.connect(CONN_STR, autocommit=True)
    except Exception as e:
        print(f"[ERROR] Không thể kết nối DB: {e}")
        return

    cursor = conn.cursor()
    
    for city_name, city_id in CITY_MAP.items():
        print(f"\n→ PROCESSING CA-RETS FORECAST FOR [{city_name.upper()}] (CityID: {city_id})")
        
        # Get actual ZoneID from CityID
        cursor.execute("SELECT TOP 1 ZoneID FROM Zones WHERE CityID = ? ORDER BY ZoneID", city_id)
        zone_row = cursor.fetchone()
        if not zone_row:
            print(f"   [SKIP] Không tìm thấy Zone tương ứng với CityID {city_id}")
            continue
            
        zone_id = zone_row[0]
        history = get_history_from_db(conn, zone_id)
        
        if not history:
            print(f"   [SKIP] Không tìm thấy dữ liệu WeatherLogs lịch sử cho ZoneID {zone_id}")
            continue
            
        print(f"   [INFO] Lấy thành công {len(history)} dòng lịch sử.")
        
        # Gọi mô hình Temperature
        req_temp = {
            "target": "Temperature",
            "city": city_name,
            "history": history
        }
        
        try:
            resp = requests.post(API_URL, json=req_temp, timeout=60)
            if resp.status_code == 200:
                print(f"   [SUCCESS] Predict Temperature: {resp.json().get('status')}")
            else:
                print(f"   [ERROR] Predict Temperature Failed: HTTP {resp.status_code} - {resp.text}")
        except Exception as e:
            print(f"   [ERROR] Gọi API thất bại: {e}")
            
        # Gọi mô hình Humidity
        req_humid = {
            "target": "Humidity",
            "city": city_name,
            "history": history
        }
        
        try:
            resp = requests.post(API_URL, json=req_humid, timeout=60)
            if resp.status_code == 200:
                print(f"   [SUCCESS] Predict Humidity: {resp.json().get('status')}")
            else:
                print(f"   [ERROR] Predict Humidity Failed: HTTP {resp.status_code} - {resp.text}")
        except Exception as e:
            print(f"   [ERROR] Gọi API thất bại: {e}")

    conn.close()
    print("\n" + "=" * 60)
    print("  DONE! Auto Prediction Pipeline Completed.")
    print("=" * 60)

if __name__ == "__main__":
    run_predictions()
