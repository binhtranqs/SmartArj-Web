import os
os.environ["CUDA_VISIBLE_DEVICES"] = ""   # Force CPU — no GPU required
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"  # Fix OpenMP duplicate lib conflict on Windows

import torch
torch.cuda.is_available = lambda: False

import pandas as pd
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Dict
from pytorch_forecasting import TemporalFusionTransformer
from contextlib import asynccontextmanager
import psycopg2
import traceback

# ==========================================
# 1. CẤU HÌNH (PATH & DB CONFIGURATION)
# ==========================================
_BASE    = os.path.dirname(os.path.abspath(__file__))
_OUTPUTS = os.path.join(_BASE, "outputs")

# Thư mục checkpoints toàn cục (dùng chung cho tất cả city)
_GLOBAL_CKPTS = os.path.join(_OUTPUTS, "checkpoints")

# Model checkpoint filenames
MODEL_CKPT_NAMES = {
    "Temperature": "tft_temp_avg-epoch=09-val_loss=1.0647.ckpt",
    "Humidity":    "tft_rh_avg-epoch=05-val_loss=4.7425.ckpt",
}

# Mapping: folder name → CityID trong DB
CITY_MAP: Dict[str, int] = {
    "cantho": 11,
    "daklak": 14,
    "dalat":  12,
    "danang": 13,
    "hanoi":  15,
    "hcm":    17,
}

# Connection string PostgreSQL (Neon) — đọc từ env var
DB_CONN_STR = os.environ.get(
    "DATABASE_URL",
    "postgresql://neondb_owner:YOUR_PASSWORD@ep-icy-butterfly-a1e74ayi-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require"
)

# ==========================================
# 2. ĐỊNH NGHĨA CẤU TRÚC DỮ LIỆU (SCHEMAS)
# ==========================================
class WeatherData(BaseModel):
    RecordedAt: str    # Thời gian ghi nhận (YYYY-MM-DD)
    Temperature: float # Nhiệt độ
    Humidity: float    # Độ ẩm
    Rainfall: float    # Lượng mưa

class Thresholds(BaseModel):
    min_temp: float = 15.0
    max_temp: float = 32.0
    min_humidity: float = 40.0
    max_humidity: float = 90.0

class ForecastRequest(BaseModel):
    target: str                            # 'Temperature' hoặc 'Humidity'
    city: Optional[str] = "danang"        # Tên thành phố (folder trong outputs/)
    thresholds: Optional[Thresholds] = Thresholds()
    history: List[WeatherData]             # Tối thiểu 30 ngày lịch sử

# ==========================================
# 3. TẢI MÔ HÌNH THEO TỪNG THÀNH PHỐ (LIFESPAN)
# ==========================================
# city_models[city][target] = model
city_models: Dict[str, Dict[str, TemporalFusionTransformer]] = {}
# city_calib[city][target]  = calib_df
city_calib: Dict[str, Dict[str, pd.DataFrame]] = {}
# city_clim[city][target]   = clim_map dict
city_clim: Dict[str, Dict[str, dict]] = {}


def _load_model(ckpt_path: str) -> Optional[TemporalFusionTransformer]:
    """Load một TFT model từ checkpoint."""
    if not os.path.exists(ckpt_path):
        return None
    checkpoint = torch.load(ckpt_path, map_location=torch.device("cpu"), weights_only=False)
    hparams = checkpoint["hyper_parameters"]
    model = TemporalFusionTransformer(**hparams)
    model.load_state_dict(checkpoint["state_dict"], strict=False)
    for module in model.modules():
        try:
            if hasattr(module, "_device"):
                module._device = torch.device("cpu")
        except Exception:
            pass
    model.eval()
    return model


@asynccontextmanager
async def lifespan(app: FastAPI):
    global city_models, city_calib, city_clim

    for city_name in CITY_MAP:
        city_folder = os.path.join(_OUTPUTS, city_name)
        if not os.path.isdir(city_folder):
            print(f"[SKIP] Thư mục không tồn tại: {city_folder}")
            continue

        city_models[city_name] = {}
        city_calib[city_name]  = {}
        city_clim[city_name]   = {}

        for target in ["Temperature", "Humidity"]:
            ckpt_name = MODEL_CKPT_NAMES[target]
            # Ưu tiên checkpoint trong folder của city, fallback về global checkpoints
            local_ckpt  = os.path.join(city_folder, "checkpoints", ckpt_name)
            global_ckpt = os.path.join(_GLOBAL_CKPTS, ckpt_name)
            ckpt_path   = local_ckpt if os.path.exists(local_ckpt) else global_ckpt

            try:
                model = _load_model(ckpt_path)
                if model is None:
                    print(f"[WARN] [{city_name}] Không tìm thấy checkpoint cho {target}: {ckpt_path}")
                    continue
                city_models[city_name][target] = model

                # Calibration CSV
                calib_internal = "temp_avg" if target == "Temperature" else "rh_avg"
                calib_csv = os.path.join(city_folder, f"calibration_{calib_internal}.csv")
                if os.path.exists(calib_csv):
                    city_calib[city_name][target] = (
                        pd.read_csv(calib_csv).set_index("horizon")
                    )

                # Climatology CSV
                clim_csv = os.path.join(city_folder, f"climatology_{calib_internal}.csv")
                if os.path.exists(clim_csv):
                    city_clim[city_name][target] = (
                        pd.read_csv(clim_csv).set_index("doy_int")["clim"].to_dict()
                    )

                print(f"[OK] [{city_name}] {target} model loaded.")
            except Exception as e:
                print(f"[ERROR] [{city_name}] {target}: {e}")

    yield  # ← app running

app = FastAPI(title="Agri-Smart AI Forecasting API — Multi-City", version="3.0", lifespan=lifespan)


# ==========================================
# 4. HÀM SINH CẢNH BÁO
# ==========================================
def get_actionable_insight(target: str, predictions: list, thresholds: Thresholds) -> str:
    max_val = max(predictions)
    min_val = min(predictions)

    if target == "Temperature":
        if max_val > thresholds.max_temp:
            return (f"Cảnh báo: Nhiệt độ dự báo cao nhất ({round(max_val,1)}°C) "
                    f"vượt ngưỡng an toàn ({thresholds.max_temp}°C). "
                    f"Khuyến nghị kích hoạt hệ thống làm mát/rèm che.")
        elif min_val < thresholds.min_temp:
            return (f"Cảnh báo: Nhiệt độ xuống thấp ({round(min_val,1)}°C) "
                    f"dưới ngưỡng ({thresholds.min_temp}°C). "
                    f"Khuyến nghị kiểm tra hệ thống sưởi ấm.")
        else:
            return (f"Ổn định: Nhiệt độ trong ngưỡng sinh trưởng an toàn "
                    f"({thresholds.min_temp}°C – {thresholds.max_temp}°C).")

    elif target == "Humidity":
        if max_val > thresholds.max_humidity:
            return (f"Cảnh báo: Độ ẩm rất cao ({round(max_val,1)}%), "
                    f"vượt ngưỡng ({thresholds.max_humidity}%). "
                    f"Nguy cơ nấm bệnh, cần thông gió.")
        elif min_val < thresholds.min_humidity:
            return (f"Cảnh báo: Độ ẩm quá thấp ({round(min_val,1)}%), "
                    f"dưới ngưỡng ({thresholds.min_humidity}%). "
                    f"Đề nghị tăng cường tưới nước.")

    return "Tình hình thời tiết ổn định. Duy trì chế độ chăm sóc tiêu chuẩn."


# ==========================================
# 5. HÀM GHI KẾT QUẢ VÀO DATABASE
# ==========================================
def _get_zone_id(cursor, city_id: int) -> int:
    cursor.execute(
        "SELECT ZoneID FROM Zones WHERE CityID = %s ORDER BY ZoneID LIMIT 1", (city_id,)
    )
    row = cursor.fetchone()
    return row[0] if row else 1


def save_forecasts_to_db(city_name: str, target: str, forecast: list) -> dict:
    """
    Upsert danh sách forecast [{date, value}, ...] vào bảng Forecasts.
    Trả về {"inserted": N, "updated": M} hoặc raise nếu lỗi DB.
    """
    city_id = CITY_MAP.get(city_name.lower())
    if city_id is None:
        return {"inserted": 0, "updated": 0, "warning": f"CityID không rõ cho '{city_name}'"}

    inserted = 0
    updated  = 0

    try:
        conn   = psycopg2.connect(DB_CONN_STR)
        cursor = conn.cursor()
        zone_id = _get_zone_id(cursor, city_id)

        for item in forecast:
            date  = item["date"]
            value = item["value"]

            # Kiểm tra record đã tồn tại chưa
            cursor.execute(
                "SELECT ForecastID FROM Forecasts WHERE CityID = %s AND ForecastDate = %s",
                (city_id, date)
            )
            existing = cursor.fetchone()

            if existing:
                if target == "Temperature":
                    cursor.execute(
                        "UPDATE Forecasts SET Temperature = %s, CreatedAt = NOW() WHERE ForecastID = %s",
                        (value, existing[0])
                    )
                else:
                    cursor.execute(
                        "UPDATE Forecasts SET Humidity = %s, CreatedAt = NOW() WHERE ForecastID = %s",
                        (value, existing[0])
                    )
                updated += 1
            else:
                temp_val = value if target == "Temperature" else None
                rh_val   = value if target == "Humidity"    else None
                cursor.execute(
                    "INSERT INTO Forecasts (ZoneID, ForecastDate, Temperature, CityID, Humidity, CreatedAt) "
                    "VALUES (%s, %s, %s, %s, %s, NOW())",
                    (zone_id, date, temp_val, city_id, rh_val)
                )
                inserted += 1

        conn.commit()
        cursor.close()
        conn.close()
        print(f"[DB] [{city_name}] {target}: inserted={inserted} updated={updated}")
        return {"inserted": inserted, "updated": updated}

    except Exception as e:
        print(f"[DB ERROR] [{city_name}] {target}: {e}")
        return {"inserted": 0, "updated": 0, "error": str(e)}


# ==========================================
# 6. CORE FORECAST LOGIC (tách ra để dùng lại)
# ==========================================
def _run_forecast(best_model, calib_df, clim_map, target: str, history: List[WeatherData],
                  thresholds: Thresholds) -> dict:
    """
    Thực hiện dự báo 7 ngày cho một target (Temperature / Humidity).
    Trả về dict chứa forecast list + insight.
    """
    raw_data = [h.dict() for h in history]
    df = pd.DataFrame(raw_data)
    df = df.rename(columns={
        "RecordedAt":  "date",
        "Temperature": "temp_avg",
        "Humidity":    "rh_avg",
        "Rainfall":    "precip_sum"
    })

    df["date"] = pd.to_datetime(df["date"])
    df = df.sort_values("date").reset_index(drop=True)

    # Pad nếu thiếu lịch sử
    if len(df) < best_model.hparams.max_encoder_length:
        missing_count = best_model.hparams.max_encoder_length - len(df)
        first_row = df.iloc[0:1].copy()
        pad_df = pd.concat([first_row] * missing_count, ignore_index=True)
        pad_dates = pd.date_range(
            end=first_row["date"].iloc[0] - pd.Timedelta(days=1),
            periods=missing_count, freq="D"
        )
        pad_df["date"] = pad_dates
        df = pd.concat([pad_df, df], ignore_index=True)
        df = df.sort_values("date").reset_index(drop=True)

    # Time features
    df["time_idx"] = np.arange(len(df), dtype=np.int64)
    df["series_id"] = "loc_1"
    df["doy_int"]   = df["date"].dt.dayofyear.astype(int)
    dow = df["date"].dt.dayofweek.astype(int)
    df["doy_sin"]      = np.sin(2 * np.pi * df["doy_int"] / 365.25)
    df["doy_cos"]      = np.cos(2 * np.pi * df["doy_int"] / 365.25)
    df["dow_sin"]      = np.sin(2 * np.pi * dow / 7.0)
    df["dow_cos"]      = np.cos(2 * np.pi * dow / 7.0)
    df["precip_log1p"] = np.log1p(df["precip_sum"].clip(lower=0))

    internal_target = "temp_avg" if target == "Temperature" else "rh_avg"
    is_temp = internal_target.startswith("temp_")

    if is_temp and clim_map is not None:
        df[f"{internal_target}_clim"]  = df["doy_int"].map(clim_map)
        df[f"{internal_target}_clim"]  = df[f"{internal_target}_clim"].fillna(df[internal_target].mean())
        df[f"{internal_target}_resid"] = df[internal_target] - df[f"{internal_target}_clim"]
        actual_col = f"{internal_target}_resid"
    else:
        actual_col = internal_target

    model_target = best_model.dataset_parameters.get(
        "target", f"{internal_target}_resid" if is_temp else internal_target
    )

    if actual_col != model_target and actual_col in df.columns:
        df[model_target] = df[actual_col]

    last_time_idx = int(df["time_idx"].max())
    pred_len = 7
    today = pd.Timestamp.today().normalize()
    future_dates = pd.date_range(today, periods=pred_len, freq="D")

    future = pd.DataFrame({
        "date":      future_dates,
        "series_id": "loc_1",
        "time_idx":  np.arange(last_time_idx + 1, last_time_idx + 1 + pred_len, dtype=np.int64),
    })

    future_doy = future["date"].dt.dayofyear.astype(int)
    future_dow = future["date"].dt.dayofweek.astype(int)
    future["doy_sin"]      = np.sin(2 * np.pi * future_doy / 365.25)
    future["doy_cos"]      = np.cos(2 * np.pi * future_doy / 365.25)
    future["dow_sin"]      = np.sin(2 * np.pi * future_dow / 7.0)
    future["dow_cos"]      = np.cos(2 * np.pi * future_dow / 7.0)
    future["precip_sum"]   = 0.0
    future["precip_log1p"] = 0.0

    if is_temp and clim_map is not None:
        future["doy_int"] = future_doy
        future[f"{internal_target}_clim"] = (
            future["doy_int"].map(clim_map).fillna(df[internal_target].mean())
        )
        future[model_target] = df[model_target].iloc[-1]
    else:
        future[model_target] = df[model_target].iloc[-1]

    df_combined = pd.concat([df, future], ignore_index=True)
    raw_predictions = best_model.predict(
        df_combined, mode="prediction", trainer_kwargs={"accelerator": "cpu"}
    )
    y_next7 = raw_predictions.detach().cpu().numpy().flatten()

    final_forecast = []
    for i in range(pred_len):
        h = i + 1
        if is_temp and clim_map is not None:
            clim_val  = future.iloc[i][f"{internal_target}_clim"]
            y_val_raw = y_next7[i] + clim_val
        else:
            y_val_raw = y_next7[i]

        try:
            bias_h = float(calib_df.loc[h, "bias"]) if calib_df is not None else 0.0
        except Exception:
            bias_h = 0.0

        final_forecast.append({
            "horizon": h,
            "date":    future_dates[i].strftime("%Y-%m-%d"),
            "value":   round(float(y_val_raw + bias_h), 2)
        })

    predicted_values = [f["value"] for f in final_forecast]
    return {
        "forecast": final_forecast,
        "insight":  get_actionable_insight(target, predicted_values, thresholds),
    }


# ==========================================
# 7. API ENDPOINTS
# ==========================================

@app.get("/cities")
async def list_cities():
    """Trả về danh sách thành phố đang có model."""
    available = {
        city: list(models.keys())
        for city, models in city_models.items()
        if models
    }
    return {"cities": available, "city_map": CITY_MAP}


@app.post("/predict")
async def predict_legacy(request: ForecastRequest):
    """
    Endpoint tương thích ngược (backward-compatible).
    Dùng city='danang' nếu không truyền city.
    Sau khi dự báo, tự động lưu vào DB.
    """
    return await predict_city(request)


@app.post("/predict-city")
async def predict_city(request: ForecastRequest):
    """
    Dự báo 7 ngày cho một thành phố cụ thể.
    - city: tên thành phố (cantho, daklak, dalat, danang, hanoi, hcm)
    - target: 'Temperature' hoặc 'Humidity'
    - history: danh sách dữ liệu lịch sử (tối thiểu 30 ngày)
    Kết quả tự động được lưu vào bảng Forecasts trong SQL Server.
    """
    city_key = (request.city or "danang").lower().strip()

    # Kiểm tra city hợp lệ
    if city_key not in city_models:
        raise HTTPException(
            status_code=400,
            detail=f"Thành phố '{city_key}' không hợp lệ. Các thành phố hỗ trợ: {list(CITY_MAP.keys())}"
        )

    city_target_models = city_models.get(city_key, {})
    if request.target not in city_target_models:
        raise HTTPException(
            status_code=500,
            detail=f"Mô hình {request.target} cho '{city_key}' chưa được tải."
        )

    best_model = city_target_models[request.target]
    calib_df   = city_calib.get(city_key, {}).get(request.target)
    clim_map   = city_clim.get(city_key, {}).get(request.target)

    try:
        result = _run_forecast(
            best_model, calib_df, clim_map,
            request.target, request.history, request.thresholds
        )

        # ── Tự động lưu vào DB ──────────────────────────────────
        db_result = save_forecasts_to_db(city_key, request.target, result["forecast"])

        return {
            "city":     city_key,
            "city_id":  CITY_MAP.get(city_key),
            "target":   request.target,
            "forecast": result["forecast"],
            "insight":  result["insight"],
            "db_write": db_result,
            "status":   "success"
        }

    except HTTPException:
        raise
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/predict-all")
async def predict_all_cities(request: ForecastRequest):
    """
    Dự báo cùng 1 target cho TẤT CẢ thành phố có model.
    Cùng dữ liệu history được dùng cho mọi city (hữu ích khi test).
    Kết quả mỗi city được lưu vào DB ngay lập tức.
    """
    results = {}
    for city_name, models_dict in city_models.items():
        if request.target not in models_dict:
            results[city_name] = {"status": "no_model"}
            continue

        best_model = models_dict[request.target]
        calib_df   = city_calib.get(city_name, {}).get(request.target)
        clim_map   = city_clim.get(city_name, {}).get(request.target)

        try:
            result    = _run_forecast(
                best_model, calib_df, clim_map,
                request.target, request.history, request.thresholds
            )
            db_result = save_forecasts_to_db(city_name, request.target, result["forecast"])
            results[city_name] = {
                "status":   "success",
                "city_id":  CITY_MAP.get(city_name),
                "forecast": result["forecast"],
                "insight":  result["insight"],
                "db_write": db_result,
            }
        except Exception as e:
            traceback.print_exc()
            results[city_name] = {"status": "error", "detail": str(e)}

    return {"target": request.target, "results": results}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)