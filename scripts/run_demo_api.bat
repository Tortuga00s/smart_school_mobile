@echo off
cd /d "%~dp0.."
py -3 services\demo_api\server.py
pause
