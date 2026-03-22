import sys
import pyodbc

sys.stdout.reconfigure(encoding='utf-8')

# Danh sách 10 thành phố tương ứng với folder trong src/java/model
CITIES = [
    {"limit": 10.04, "lon": 105.78, "city": "CanTho", "zone": "Vườn Cây Ăn Trái Cái Răng"},
    {"limit": 11.94, "lon": 108.43, "city": "DaLat", "zone": "Nông Trại Rau Sạch"},
    {"limit": 16.05, "lon": 108.20, "city": "DaNang", "zone": "Vườn Lan Cẩm Lệ"},
    {"limit": 12.66, "lon": 108.03, "city": "DakLak", "zone": "Đồi Cà Phê Buôn Ma Thuột"},
    {"limit": 21.02, "lon": 105.83, "city": "HaNoi", "zone": "Vườn Đào Nhật Tân"},
    {"limit": 20.84, "lon": 106.68, "city": "HaiPhong", "zone": "Nông Trường Thủy Sản"},
    {"limit": 10.82, "lon": 106.62, "city": "HoChiMinh", "zone": "Khu Nông Nghiệp Công Nghệ Cao"},
    {"limit": 16.46, "lon": 107.59, "city": "Hue", "zone": "Vườn Thanh Trà Thủy Biều"},
    {"limit": 12.23, "lon": 109.19, "city": "NhaTrang", "zone": "Vườn Xoài Cam Lâm"},
    {"limit": 22.33, "lon": 103.84, "city": "Sapa", "zone": "Ruộng Bậc Thang Tả Van"}
]

def setup_db():
    conn_str = (
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=localhost,1433;"
        "Database=SmartAgri_PRJ301;"
        "UID=sa;"
        "PWD=123;"
        "TrustServerCertificate=yes;"
        "Encrypt=yes;"
    )
    conn = pyodbc.connect(conn_str)
    cur = conn.cursor()

    print("--- SERVER SETUP FOR CITIES & ZONES ---")
    
    # 1. User mặc định
    cur.execute("SELECT Count(*) FROM Users WHERE Username='admin'")
    if cur.fetchone()[0] == 0:
        cur.execute("INSERT INTO Users (Username, Password, Role, IsVIP) VALUES ('admin', '123', 'Admin', 1)")
        print("Inserted Admin user.")
    
    # 2. Insert Cities & Zones
    for c in CITIES:
        # Check City
        cur.execute("SELECT CityID FROM Cities WHERE CityName = ?", (c["city"],))
        row = cur.fetchone()
        
        if row:
            city_id = row[0]
        else:
            cur.execute("INSERT INTO Cities (CityName) OUTPUT INSERTED.CityID VALUES (?)", (c["city"],))
            city_id = cur.fetchone()[0]
            print(f"Added City: {c['city']}")

        # Check Zone (theo CityID)
        cur.execute("SELECT ZoneID FROM Zones WHERE CityID = ?", (city_id,))
        z_row = cur.fetchone()
        
        if not z_row:
            cur.execute("""
                INSERT INTO Zones (ZoneName, Latitude, Longitude, CityID, OwnerID)
                VALUES (?, ?, ?, ?, ?)
            """, (c["zone"], c["limit"], c["lon"], city_id, 1)) # OwnerID=1 (Admin)
            print(f"Added Zone: {c['zone']} ({c['city']})")
        else:
            print(f"Zone for {c['city']} already exists.")

    conn.commit()
    conn.close()
    print("--- SETUP COMPLETED ---")

if __name__ == "__main__":
    setup_db()
