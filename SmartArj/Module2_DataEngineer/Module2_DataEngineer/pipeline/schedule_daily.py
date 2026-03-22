"""
CaReTS – Scheduler tự động fetch thời tiết vào DB.

CÁCH DÙNG:
  A) Chạy thủ công (cần terminal mở):
       python schedule_daily.py

  B) Chạy nền thực sự (Windows Task Scheduler) – KHUYẾN NGHỊ:
       Chạy lệnh run_task_scheduler.bat với quyền Admin,
       hoặc dùng lệnh schtasks trong PowerShell (xem cuối file).

Lịch: 07:00 sáng mỗi ngày.
"""
import schedule
import time
import subprocess
import sys
import os
from datetime import datetime

SCRIPT_DIR   = os.path.dirname(os.path.abspath(__file__))
FETCH_SCRIPT = os.path.join(SCRIPT_DIR, "fetch_weather_to_db.py")

# ✅ FIX: Log subprocess vào file cố định để không mất output khi chạy nền
SUBPROCESS_LOG = os.path.join(SCRIPT_DIR, "subprocess_log.txt")


def job():
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"\n[{ts}] ⏰ Bat dau fetch weather -> DB...")

    # capture_output=True: bắt toàn bộ stdout + stderr
    result = subprocess.run(
        [sys.executable, FETCH_SCRIPT],
        cwd=SCRIPT_DIR,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace"
    )

    # Lưu stdout + stderr vào subprocess_log.txt (append)
    with open(SUBPROCESS_LOG, "a", encoding="utf-8") as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"[{ts}] --- STDOUT ---\n")
        f.write(result.stdout or "(no output)\n")
        if result.stderr:
            f.write(f"[{ts}] --- STDERR ---\n")
            f.write(result.stderr)
        f.write(f"[{ts}] returncode={result.returncode}\n")

    if result.returncode == 0:
        print(f"[{ts}] ✅ Fetch thanh cong. (xem chi tiet: subprocess_log.txt)")
    else:
        print(f"[{ts}] ❌ Fetch that bai (returncode={result.returncode}). Xem subprocess_log.txt")


# Lịch chạy 07:00 sáng hàng ngày
schedule.every().day.at("07:00").do(job)

print("=" * 55)
print("🚀 CaReTS Scheduler dang chay.")
print("   Script: fetch_weather_to_db.py (-> SQL Server)")
print("   Lich : Hang ngay luc 07:00")
print(f"  Log   : {SUBPROCESS_LOG}")
print("   Dung : Ctrl+C")
print("=" * 55)

# Chạy ngay 1 lần khi khởi động
job()

# Vòng lặp scheduler
while True:
    schedule.run_pending()
    time.sleep(60)
