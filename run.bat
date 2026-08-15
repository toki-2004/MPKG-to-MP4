@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "PYTHON_CMD="
where python >nul 2>nul && set "PYTHON_CMD=python"
if not defined PYTHON_CMD (
    where py >nul 2>nul && set "PYTHON_CMD=py -3"
)
if not defined PYTHON_CMD (
    echo Python was not found. Please install it from:
    echo https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)

if "%~1"=="" (
    echo Usage: drag and drop a .mpkg file onto this window, or run:
    echo   %PYTHON_CMD% extract.py ^<package.mpkg^> [output_dir]
    pause
    exit /b 0
)

%PYTHON_CMD% extract.py %*
echo.
pause
