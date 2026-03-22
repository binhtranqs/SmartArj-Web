import pyodbc
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

DB_SERVER = r"localhost"
DB_USER = "sa"
DB_PASS = "123"

def get_conn():
    drivers = [d for d in pyodbc.drivers()]
    driver = "ODBC Driver 17 for SQL Server" if "ODBC Driver 17 for SQL Server" in drivers else "ODBC Driver 18 for SQL Server"
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={DB_SERVER};"
        f"DATABASE=SmartAgri_PRJ301;"
        f"UID={DB_USER};"
        f"PWD={DB_PASS};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)

def check_owners():
    conn = get_conn()
    cursor = conn.cursor()
    
    print("--- ZONES WITH OWNERS ---")
    cursor.execute("SELECT ZoneID, ZoneName, OwnerID FROM Zones")
    for row in cursor.fetchall():
        print(f"ID: {row[0]}, Name: {row[1]}, Owner: {row[2]}")
        
    print("\n--- USERS ---")
    cursor.execute("SELECT UserID, Username, FullName, Role FROM Users")
    for row in cursor.fetchall():
        print(f"ID: {row[0]}, User: {row[1]}, Name: {row[2]}, Role: {row[3]}")
        
    conn.close()

if __name__ == "__main__":
    check_owners()
