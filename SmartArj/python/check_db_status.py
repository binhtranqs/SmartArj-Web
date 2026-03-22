import pyodbc
import os

# DB Config
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

import sys
import io

# Force UTF-8 for stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def check_status():
    conn = get_conn()
    cursor = conn.cursor()
    
    print("--- ZONES ---")
    cursor.execute("SELECT ZoneID, ZoneName FROM Zones")
    for row in cursor.fetchall():
        print(f"ID: {row[0]}, Name: {row[1]}")
    
    print("\n--- WEATHER LOGS COUNT ---")
    cursor.execute("SELECT ZoneID, COUNT(*) FROM WeatherLogs GROUP BY ZoneID")
    for row in cursor.fetchall():
        print(f"Zone {row[0]}: {row[1]} records")
        
    conn.close()

if __name__ == "__main__":
    check_status()
