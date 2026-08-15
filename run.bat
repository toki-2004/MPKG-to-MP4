@echo off
setlocal
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

rem Called with a file argument (e.g. dragged onto this .bat): extract once.
if not "%~1"=="" (
    %PYTHON_CMD% extract.py %*
    echo.
    pause
    exit /b %errorlevel%
)

rem Interactive mode: keep waiting for files dragged into the window.
:loop
echo.
echo Drag a .mpkg file onto this window and press Enter.
echo Or type the full path of the .mpkg file. Type exit to quit.
set "PKG="
set /p "PKG=mpkg path: "
set "PKG=%PKG:"=%"
if /i "%PKG%"=="exit" exit /b 0
if not defined PKG goto :loop
%PYTHON_CMD% extract.py "%PKG%"
echo.
goto :loop
