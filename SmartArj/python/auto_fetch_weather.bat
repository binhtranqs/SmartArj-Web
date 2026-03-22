@echo off
REM ============================================================
REM  SmartArj - Auto Fetch Weather Data to Database
REM  Chạy mỗi đêm qua Windows Task Scheduler
REM ============================================================

SET "BASE_DIR=C:\Users\LENOVO\Documents\NetBeansProjects\SmartArj\python"
SET "LOG_DIR=%BASE_DIR%\logs"
SET "LOG_FILE=%LOG_DIR%\weather_cron_%date:~10,4%-%date:~4,2%-%date:~7,2%.log"

REM Tạo thư mục logs nếu chưa có
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ============================================================ >> "%LOG_FILE%"
echo [%date% %time%] === BAT DO FETCH WEATHER START === >> "%LOG_FILE%"
echo ============================================================ >> "%LOG_FILE%"

REM Chuyển vào thư mục python
cd /d "%BASE_DIR%"

REM Kích hoạt virtualenv
call "%BASE_DIR%\venv\Scripts\activate.bat"

REM Chạy script cào dữ liệu, ghi log
python "%BASE_DIR%\fetch_weather_to_db.py" >> "%LOG_FILE%" 2>&1

echo [%date% %time%] === TRIGGERING AI FORECAST PREDICTION === >> "%LOG_FILE%"
python "C:\Users\LENOVO\Documents\NetBeansProjects\SmartArj\SmartArj\SmartArj\AI_Engine\AI_Engine\auto_predict.py" >> "%LOG_FILE%" 2>&1

REM Ghi trạng thái kết thúc
echo. >> "%LOG_FILE%"
echo [%date% %time%] === FETCH DONE (exit code: %ERRORLEVEL%) === >> "%LOG_FILE%"
echo ============================================================ >> "%LOG_FILE%"

REM Tự động xóa log cũ hơn 30 ngày
forfiles /p "%LOG_DIR%" /s /m *.log /d -30 /c "cmd /c del @file" 2>nul

exit /b 0
