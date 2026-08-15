@echo off
setlocal
cd /d "%~dp0"

rem Prefer the bundled standalone exe; fall back to Python source.
set "TOOL="
if exist "%~dp0mpkg2mp4.exe" set "TOOL="%~dp0mpkg2mp4.exe""
if not defined TOOL (
    where python >nul 2>nul && set "TOOL=python extract.py"
)
if not defined TOOL (
    where py >nul 2>nul && set "TOOL=py -3 extract.py"
)
if not defined TOOL (
    echo mpkg2mp4.exe not found and Python is not installed.
    echo Please install Python from https://www.python.org/downloads/
    echo and check "Add Python to PATH", or get mpkg2mp4.exe.
    pause
    exit /b 1
)

rem Called with a file argument (e.g. dragged onto this .bat): extract once.
if not "%~1"=="" (
    %TOOL% %*
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
%TOOL% "%PKG%"
echo.
goto :loop
