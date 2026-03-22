import pyodbc
from datetime import datetime, timedelta
import random
import os

# DB Config (matching app.py)
DB_SERVER = r"localhost"
DB_NAME = "SmartAgri_PRJ301"
DB_USER = "sa"
DB_PASS = "123"

def get_conn():
    drivers = [d for d in pyodbc.drivers()]
    driver = "ODBC Driver 17 for SQL Server" if "ODBC Driver 17 for SQL Server" in drivers else "ODBC Driver 18 for SQL Server"
    
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_NAME};"
        f"UID={DB_USER};"
        f"PWD={DB_PASS};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)

def generate_data(zone_id, days=40):
    conn = get_conn()
    cursor = conn.cursor()
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    
    print(f"Generating {days} days of data for Zone {zone_id}...")
    
    current_date = start_date
    count = 0
    while current_date <= end_date:
        # Generate 24 hours of data for each day
        for hour in range(24):
            recorded_at = current_date.replace(hour=hour, minute=0, second=0, microsecond=0)
            
            # Check if record already exists
            cursor.execute("SELECT 1 FROM WeatherLogs WHERE ZoneID = ? AND RecordedAt = ?", (zone_id, recorded_at))
            if cursor.fetchone():
                continue

            # Random but somewhat realistic values
            temp = random.uniform(20.0, 35.0)
            humid = random.uniform(50.0, 90.0)
            rain = random.uniform(0.0, 10.0) if random.random() > 0.8 else 0.0
            wind = random.uniform(0.0, 15.0)
            rad = random.uniform(0.0, 800.0) if 6 < hour < 18 else 0.0
            
            cursor.execute("""
                INSERT INTO WeatherLogs (ZoneID, Temperature, Humidity, Rainfall, Wind, Radiation, RecordedAt)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (zone_id, temp, humid, rain, wind, rad, recorded_at))
            count += 1
            
        current_date += timedelta(days=1)
        if count % 100 == 0:
            conn.commit()
            print(f"Inserted {count} records...")

    conn.commit()
    conn.close()
    print(f"Successfully generated {count} records for Zone {zone_id}.")

if __name__ == "__main__":
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT ZoneID FROM Zones")
    zone_ids = [row[0] for row in cursor.fetchall()]
    conn.close()
    
    for zid in zone_ids:
        generate_data(zone_id=zid, days=380)
