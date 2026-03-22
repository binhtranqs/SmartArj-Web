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
        f"UID={DB_USER};"
        f"PWD={DB_PASS};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)

def list_dbs():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sys.databases")
    for row in cursor.fetchall():
        print(row[0])
    conn.close()

if __name__ == "__main__":
    list_dbs()
