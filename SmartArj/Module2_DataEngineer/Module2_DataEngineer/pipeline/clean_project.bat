@echo off
chcp 65001 >nul
:: ==========================================================
:: CaReTS – Dọn dẹp project trước khi gửi team
:: Chạy file này từ thư mục D:\PRJ301\weather
:: ==========================================================

echo ========================================================
echo   CaReTS: Dong dep project (clean_project.bat)
echo ========================================================
echo.

set PROJECT_DIR=%~dp0

:: ----------------------------------------------------------
:: 1. Xóa tất cả thư mục __pycache__
:: ----------------------------------------------------------
echo [1/6] Xoa __pycache__...
for /d /r "%PROJECT_DIR%" %%d in (__pycache__) do (
    if exist "%%d" (
        echo      Xoa: %%d
        rd /s /q "%%d"
    )
)
echo      Xong.

:: ----------------------------------------------------------
:: 2. Xóa tất cả file *.log
:: ----------------------------------------------------------
echo.
echo [2/6] Xoa file *.log...
for /r "%PROJECT_DIR%" %%f in (*.log *.txt.1 *.txt.2 *.txt.3) do (
    echo      Xoa: %%f
    del /f /q "%%f"
)
:: Xóa riêng fetch_log.txt và subprocess_log.txt
if exist "%PROJECT_DIR%fetch_log.txt" (
    echo      Xoa: fetch_log.txt
    del /f /q "%PROJECT_DIR%fetch_log.txt"
)
if exist "%PROJECT_DIR%subprocess_log.txt" (
    echo      Xoa: subprocess_log.txt
    del /f /q "%PROJECT_DIR%subprocess_log.txt"
)
echo      Xong.

:: ----------------------------------------------------------
:: 3. Xóa thư mục build\
:: ----------------------------------------------------------
echo.
echo [3/6] Xoa thu muc build\...
if exist "%PROJECT_DIR%build\" (
    echo      Xoa: %PROJECT_DIR%build\
    rd /s /q "%PROJECT_DIR%build\"
    echo      Xong.
) else (
    echo      Khong tim thay build\ - bo qua.
)

:: ----------------------------------------------------------
:: 4. Xóa thư mục dist\
:: ----------------------------------------------------------
echo.
echo [4/6] Xoa thu muc dist\...
if exist "%PROJECT_DIR%dist\" (
    echo      Xoa: %PROJECT_DIR%dist\
    rd /s /q "%PROJECT_DIR%dist\"
    echo      Xong.
) else (
    echo      Khong tim thay dist\ - bo qua.
)

:: ----------------------------------------------------------
:: 5. Xóa weather_data.json
:: ----------------------------------------------------------
echo.
echo [5/6] Xoa weather_data.json...
if exist "%PROJECT_DIR%weather_data.json" (
    echo      Xoa: %PROJECT_DIR%weather_data.json
    del /f /q "%PROJECT_DIR%weather_data.json"
    echo      Xong.
) else (
    echo      Khong tim thay weather_data.json - bo qua.
)

:: ----------------------------------------------------------
:: 6. Xóa weather_history.json
:: ----------------------------------------------------------
echo.
echo [6/6] Xoa weather_history.json...
if exist "%PROJECT_DIR%weather_history.json" (
    echo      Xoa: %PROJECT_DIR%weather_history.json
    del /f /q "%PROJECT_DIR%weather_history.json"
    echo      Xong.
) else (
    echo      Khong tim thay weather_history.json - bo qua.
)

:: ----------------------------------------------------------
:: Kết quả
:: ----------------------------------------------------------
echo.
echo ========================================================
echo   Hoan tat! Project da sach, san sang de zip va gui.
echo   Cac file .py va .sql KHONG bi xoa.
echo ========================================================
echo.
pause
