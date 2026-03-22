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

def upgrade_user():
    conn = get_conn()
    cursor = conn.cursor()
    
    # Upgrade user 'luu' (ID 17) to VIP
    cursor.execute("UPDATE Users SET AccountType = 'VIP' WHERE UserID = 17")
    print(f"Updated {cursor.rowcount} users to VIP.")
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    upgrade_user()
