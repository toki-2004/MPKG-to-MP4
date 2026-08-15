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
    echo 未找到 Python，请先安装: https://www.python.org/downloads/
    echo 安装时请勾选 "Add Python to PATH"。
    pause
    exit /b 1
)

if "%~1"=="" (
    echo 用法: 把 .mpkg 文件直接拖到本窗口上，或运行:
    echo   %PYTHON_CMD% extract.py ^<封包路径^> [输出目录]
    pause
    exit /b 0
)

%PYTHON_CMD% extract.py %*
echo.
pause
