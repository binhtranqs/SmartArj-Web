@echo off
chcp 65001 >nul
:: ==========================================================
:: CaReTS – Đăng ký Windows Task Scheduler
:: Chạy file này với quyền Administrator:
::   Chuột phải vào file → "Run as administrator"
:: ==========================================================

echo ========================================================
echo   CaReTS: Dang ky Windows Task Scheduler
echo ========================================================
echo.

:: --- Xác định đường dẫn Python ---
where python >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [LOI] Khong tim thay Python trong PATH.
    echo       Hay cai Python va them vao PATH, sau do chay lai.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('where python') do set PYTHON_PATH=%%i
echo [INFO] Python tim thay tai: %PYTHON_PATH%

:: --- Đường dẫn script + log ---
set SCRIPT=d:\PRJ301\weather\fetch_weather_to_db.py
set LOGFILE=d:\PRJ301\weather\task_scheduler.log
set TASK_NAME=CaReTS_WeatherFetch

:: --- Tạo wrapper bat để có log ---
set WRAPPER=d:\PRJ301\weather\run_fetch.bat
echo @echo off > "%WRAPPER%"
echo echo [%%DATE%% %%TIME%%] Bat dau chay... >> "%WRAPPER%"
echo "%PYTHON_PATH%" "%SCRIPT%" >> "%WRAPPER%"
echo IF %%ERRORLEVEL%% NEQ 0 ( >> "%WRAPPER%"
echo     echo [%%DATE%% %%TIME%%] LOI: exit code %%ERRORLEVEL%% >> "%WRAPPER%"
echo ) ELSE ( >> "%WRAPPER%"
echo     echo [%%DATE%% %%TIME%%] Thanh cong. >> "%WRAPPER%"
echo ) >> "%WRAPPER%"
echo. >> "%WRAPPER%"

echo [INFO] Da tao wrapper script: %WRAPPER%

:: --- Xóa task cũ nếu có ---
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

:: --- Đăng ký task mới ---
schtasks /create ^
  /tn "%TASK_NAME%" ^
  /tr "\"%WRAPPER%\"" ^
  /sc DAILY ^
  /st 00:00 ^
  /ru SYSTEM ^
  /rl HIGHEST ^
  /f

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Task "%TASK_NAME%" da duoc dang ky thanh cong!
    echo      Lich      : Hang ngay luc 00:00 (nua dem)
    echo      Script    : %SCRIPT%
    echo      Log output: fetch_log.txt (ghi boi Python script^)
    echo.
    echo Cac lenh kiem tra:
    echo   schtasks /query /tn "%TASK_NAME%" /fo LIST
    echo   schtasks /run   /tn "%TASK_NAME%"
) ELSE (
    echo.
    echo [LOI] Dang ky that bai!
    echo       Hay chay file nay voi quyen Administrator.
)

echo.
pause
