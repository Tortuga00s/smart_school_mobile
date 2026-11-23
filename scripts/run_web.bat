@echo off
cd /d "%~dp0..\apps\mobile"
call flutter pub get
if errorlevel 1 goto end
call flutter run -d chrome --web-hostname=127.0.0.1 --web-port=7357 --dart-define=DEMO_API_URL=http://127.0.0.1:8080
:end
pause
