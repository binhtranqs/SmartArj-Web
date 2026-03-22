import pyodbc

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

def fix_ownership():
    conn = get_conn()
    cursor = conn.cursor()
    
    # Give Zone 5, 12, 21 to user 'luu' (ID 17)
    # Also change Zone 20's name to match what they see if needed, but 'Vườn Lan Cẩm Lệ' is what we want.
    cursor.execute("UPDATE Zones SET OwnerID = 17 WHERE ZoneName LIKE N'%Vườn Lan Cẩm Lệ%'")
    print(f"Updated {cursor.rowcount} zones to be owned by luu (ID 17).")
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    fix_ownership()
