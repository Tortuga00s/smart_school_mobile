@echo off
cd /d "%~dp0..\apps\mobile"
call flutter pub get
if errorlevel 1 goto end
call flutter run --dart-define=DEMO_API_URL=http://10.0.2.2:8080
:end
pause
