@echo off
REM Quick Start Script for Python Forecast Service

echo ========================================
echo Starting Python Forecast Service
echo ========================================
echo.

cd /d "%~dp0"

REM Check if venv exists
if exist "venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
) else (
    echo WARNING: Virtual environment not found
    echo Using system Python
)

echo.
echo Starting Flask app on http://localhost:5001...
echo.
echo Press Ctrl+C to stop the service
echo ========================================
echo.

python app.py

pause
