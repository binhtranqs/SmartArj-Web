from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import torch.nn as nn
import numpy as np
import os
import pyodbc
import pandas as pd
from datetime import datetime, timedelta

# ================= CẤU HÌNH =================
app = Flask(__name__)
CORS(app)

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_BASE_DIR = os.path.join(BASE_DIR, "models")

SEQ_LEN = 30
INPUT_DIM = 5
PRED_LEN = 7

FEATURES = ["Temperature", "Humidity", "Rainfall", "Wind", "Radiation"]

# Map city query -> folder models
CITY_MAP = {
    "HaNoi": "HaNoi",
    "DaNang": "DaNang",
    "HoChiMinh": "HoChiMinh",
    "CanTho": "CanTho",
    "HaiPhong": "HaiPhong",
    "DakLak": "DakLak",
    "DaLat": "DaLat",
    "Hue": "Hue",
    "NhaTrang": "NhaTrang",
    "Sapa": "Sapa",
}

# ================= DB: map city -> CityID =================
# Updated to match actual database CityIDs after renaming CityID table to Cities
# Đà Nẵng = 1, Hà Nội = 2, etc.
CITY_ID_MAP = {
    "DaNang": 1,      # Đà Nẵng
    "HaNoi": 2,       # Hà Nội
    "HoChiMinh": 3,   # Hồ Chí Minh
    "CanTho": 4,      # Cần Thơ
    "DaLat": 5,       # Đà Lạt
    "DakLak": 6,      # Đắk Lắk
    "HaiPhong": 7,    # Hải Phòng
    "Hue": 8,         # Huế
    "NhaTrang": 9,    # Nha Trang
    "Sapa": 10,       # Sapa
}

# ================= MODEL CARETS =================
class CaReTS_Model(nn.Module):
    def __init__(self, input_dim=5, hidden_dim=64, num_layers=2, output_len=7):
        super().__init__()
        self.output_len = output_len
        self.input_projection = nn.Linear(input_dim, hidden_dim)
        self.pos_embedding = nn.Parameter(torch.randn(1, 100, hidden_dim))
        encoder_layer = nn.TransformerEncoderLayer(d_model=hidden_dim, nhead=4, batch_first=True)
        self.feature_extractor = nn.TransformerEncoder(encoder_layer, num_layers=num_layers)

        self.trend_branch = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim), nn.ReLU(), nn.Linear(hidden_dim, output_len)
        )
        self.delta_branch = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim), nn.ReLU(), nn.Linear(hidden_dim, output_len * 2)
        )

    def forward(self, x, curr):
        x_proj = self.input_projection(x)
        seq_len = x.size(1)
        x_proj = x_proj + self.pos_embedding[:, :seq_len, :]
        out = self.feature_extractor(x_proj)
        h = out[:, -1, :]

        trend_logits = self.trend_branch(h)
        trend_probs = torch.sigmoid(trend_logits)

        delta_raw = self.delta_branch(h).view(-1, self.output_len, 2)
        d_up, d_down = delta_raw[:, :, 0], delta_raw[:, :, 1]

        prediction = curr + (trend_probs * d_up) - ((1 - trend_probs) * d_down)
        return prediction


# ================= DB CONFIG =================
DB_SERVER = os.getenv("DB_SERVER", r"localhost")
DB_NAME = os.getenv("DB_NAME", "SmartAgri_PRJ301")  # Actual database name
DB_USER = os.getenv("DB_USER", "sa")
DB_PASS = os.getenv("DB_PASS", "123")
DB_TRUSTED = os.getenv("DB_TRUSTED", "0")  # "1" = Windows Auth

def get_conn():
    drivers = [d for d in pyodbc.drivers()]
    driver = None
    if "ODBC Driver 18 for SQL Server" in drivers:
        driver = "ODBC Driver 18 for SQL Server"
    elif "ODBC Driver 17 for SQL Server" in drivers:
        driver = "ODBC Driver 17 for SQL Server"
    else:
        raise RuntimeError(
            f"Không thấy ODBC Driver 17/18. drivers hiện có: {drivers}. "
            f"Hãy cài 'ODBC Driver 18 for SQL Server' rồi chạy lại."
        )

    if DB_TRUSTED == "1":
        conn_str = (
            f"DRIVER={{{driver}}};"
            f"SERVER={DB_SERVER};"
            f"DATABASE={DB_NAME};"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;"
        )
    else:
        conn_str = (
            f"DRIVER={{{driver}}};"
            f"SERVER={DB_SERVER};"
            f"DATABASE={DB_NAME};"
            f"UID={DB_USER};"
            f"PWD={DB_PASS};"
            "Encrypt=yes;"
            "TrustServerCertificate=yes;"
        )
    return pyodbc.connect(conn_str, timeout=10)


def lookup_zoneid_by_city(city_key: str):
    """
    Zones của mày: ZoneID, ZoneName, Latitude, Longitude, CityID, OwnerID
    => không có CityName => lookup theo CityID.
    """
    if city_key not in CITY_ID_MAP:
        return None, f"CITY_ID_MAP chưa có key '{city_key}'. Thêm CityID cho city này."

    city_id = CITY_ID_MAP[city_key]

    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 ZoneID FROM Zones WHERE CityID = ?", (city_id,))
        row = cur.fetchone()
        if not row:
            return None, f"Không tìm thấy ZoneID nào với CityID={city_id} trong bảng Zones."
        return int(row[0]), None
    finally:
        conn.close()


def get_input_from_db(zone_id: int):
    """
    Lấy dữ liệu đầu vào cho model:
    1. Ưu tiên 30 record tại mốc 12:00 (12h trưa).
    2. Nếu không đủ 30, lấy 30 record mới nhất bất kể giờ.
    3. Nếu vẫn không đủ 30, thực hiện padding (lặp lại bản ghi cũ nhất).
    """
    conn = get_conn()
    try:
        # Step 1: Try 12:00 PM records
        query_12h = """
            SELECT TOP (?)
                Temperature, Humidity, Rainfall, Wind, Radiation, RecordedAt
            FROM WeatherLogs
            WHERE ZoneID = ?
              AND DATEPART(HOUR, RecordedAt) = 12
            ORDER BY RecordedAt DESC
        """
        df = pd.read_sql(query_12h, conn, params=[SEQ_LEN, zone_id])

        # Step 2: Fallback to latest records if not enough 12h data
        if df.shape[0] < SEQ_LEN:
            print(f"[AI] Zone {zone_id} only has {df.shape[0]} records at 12h. Falling back to latest data.")
            query_latest = """
                SELECT TOP (?)
                    Temperature, Humidity, Rainfall, Wind, Radiation, RecordedAt
                FROM WeatherLogs
                WHERE ZoneID = ?
                ORDER BY RecordedAt DESC
            """
            df = pd.read_sql(query_latest, conn, params=[SEQ_LEN, zone_id])

        if df.empty:
            return None, None

        # Step 3: Padding if still not enough records
        if df.shape[0] < SEQ_LEN:
            print(f"[AI] Zone {zone_id} has only {df.shape[0]} total records. Padding to {SEQ_LEN}.")
            needed = SEQ_LEN - df.shape[0]
            last_row = df.iloc[[-1]] # Take the oldest record (since it's ORDER BY RecordedAt DESC)
            padding = pd.concat([last_row] * needed, ignore_index=True)
            df = pd.concat([df, padding], ignore_index=True)

        # Đảo lại (cũ -> mới) cho đúng thứ tự thời gian của RNN/Transformer
        df = df.iloc[::-1].reset_index(drop=True)

        # Fill NaNs with sensible defaults to avoid "HAS_NAN" error
        df["Temperature"] = df["Temperature"].fillna(25.0)
        df["Humidity"] = df["Humidity"].fillna(70.0)
        df["Rainfall"] = df["Rainfall"].fillna(0.0)
        df["Wind"] = df["Wind"].fillna(5.0)
        df["Radiation"] = df["Radiation"].fillna(200.0)

        X = df[["Temperature", "Humidity", "Rainfall", "Wind", "Radiation"]].astype(np.float32).values
        last_time = df["RecordedAt"].iloc[-1]

        return X, last_time
    finally:
        conn.close()


# ================= MODEL LOADER =================
def find_model_file(city_folder: str, target: str):
    base = os.path.join(MODEL_BASE_DIR, city_folder)
    candidates = [
        f"Model_{target}.pth",
        f"Model_{target}.pt",
        f"{target}.pth",
        f"{target}.pt",
        f"{target.lower()}.pth",
        f"{target.lower()}.pt",
    ]
    for name in candidates:
        path = os.path.join(base, name)
        if os.path.exists(path):
            return path
    return None


def run_city_forecast(city_key: str, zone_id_override: int = None):
    city_folder = CITY_MAP[city_key]

    if zone_id_override:
        zone_id = zone_id_override
    else:
        zone_id, zerr = lookup_zoneid_by_city(city_key)
        if zerr:
            return None, zerr

    X, last_time = get_input_from_db(zone_id)

    if X is None:
        return None, f"Không đủ dữ liệu mốc 12h (cần {SEQ_LEN} bản ghi tại ZoneID={zone_id}). Hãy thêm dữ liệu lịch sử."

    # ✅ FIX LỖI numpy array ambiguous
    if isinstance(X, str) and X == "HAS_NAN":
        return None, "Trong WeatherLogs có NULL ở mốc 12h => hãy fill đủ dữ liệu rồi thử lại."

    input_tensor = torch.from_numpy(X).unsqueeze(0).to(DEVICE)  # (1,30,5)
    curr_vals = input_tensor[:, -1, :]  # (1,5)

    forecast = {}
    loaded_any = False

    for i, target in enumerate(FEATURES):
        model_path = find_model_file(city_folder, target)
        if not model_path:
            forecast[target] = [0.0] * PRED_LEN
            continue

        model = CaReTS_Model(input_dim=INPUT_DIM, output_len=PRED_LEN).to(DEVICE)
        state = torch.load(model_path, map_location=DEVICE)
        model.load_state_dict(state)
        model.eval()

        with torch.no_grad():
            pred = model(input_tensor, curr_vals[:, i:i+1])  # (1,7)
            forecast[target] = [float(x) for x in pred.squeeze(0).cpu().numpy().tolist()]
            loaded_any = True

    if not loaded_any:
        return None, f"Không tìm thấy model .pth trong: {os.path.join(MODEL_BASE_DIR, city_folder)}"

    # dates: +1 .. +7 ngày từ HÔM NAY (không phụ thuộc ngày ghi DB)
    today = datetime.now().replace(hour=12, minute=0, second=0, microsecond=0)
    dates = []
    for k in range(1, PRED_LEN + 1):
        d = today + timedelta(days=k)
        dates.append(d.strftime("%Y-%m-%d"))

    return {
        "status": "success",
        "city": city_key,
        "zone_id": zone_id,
        "last_recorded_at": today.strftime("%Y-%m-%d %H:%M:%S"),
        "dates": dates,
        "forecast": forecast,
    }, None


# ================= API =================
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "drivers": pyodbc.drivers()})


@app.route("/predict", methods=["GET"])
def predict():
    city = request.args.get("city", "").strip()
    if not city:
        return jsonify({"status": "error", "message": "Thiếu city. Ví dụ: /predict?city=HaNoi"}), 400

    if city not in CITY_MAP:
        return jsonify({"status": "error", "message": f"City không hỗ trợ: {city}"}), 400

    try:
        zone_id_param = request.args.get("zoneId")
        zone_id_override = int(zone_id_param) if zone_id_param else None
        
        result, err = run_city_forecast(city, zone_id_override)
        if err:
            return jsonify({"status": "error", "message": err}), 400
        return jsonify(result)
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == "__main__":
    # Port 5001 cho khỏi đụng 5000
    app.run(host="0.0.0.0", port=5001, debug=True)
