import pyodbc
import sys
import io

# Force UTF-8 for stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

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

def dump_logs(zone_id):
    conn = get_conn()
    cursor = conn.cursor()
    
    print(f"--- WEATHER LOGS FOR ZONE {zone_id} (Latest 5) ---")
    cursor.execute("SELECT TOP 5 LogID, Temperature, RecordedAt FROM WeatherLogs WHERE ZoneID = ? ORDER BY RecordedAt DESC", (zone_id,))
    for row in cursor.fetchall():
        print(f"LogID: {row[0]}, Temp: {row[1]}, Time: {row[2]}")
        
    conn.close()

if __name__ == "__main__":
    dump_logs(zone_id=21)
