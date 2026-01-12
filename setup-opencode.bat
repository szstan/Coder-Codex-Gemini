@echo off
chcp 65001 >nul
echo Starting CCG OpenCode Setup...
powershell -ExecutionPolicy Bypass -File "%~dp0setup-opencode.ps1"
pause
