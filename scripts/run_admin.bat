@echo off
cd /d "%~dp0..\apps\admin_windows"
call flutter pub get
if errorlevel 1 goto end
call flutter run -d windows --dart-define=DEMO_API_URL=http://127.0.0.1:8080
:end
pause
