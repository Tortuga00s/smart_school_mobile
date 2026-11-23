@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>&1 || (
  echo Flutter belum terbaca. Tambahkan folder bin Flutter ke PATH lalu buka ulang.
  pause
  exit /b 1
)
call :health
if not errorlevel 1 goto ready
py -3 --version >nul 2>&1 || (
  echo Pasang Python 3.12 atau lebih baru beserta Python Launcher.
  pause
  exit /b 1
)
start "Smart School - Server Demo" "%ComSpec%" /c scripts\run_demo_api.bat
for /l %%i in (1,1,10) do (
  call :health
  if not errorlevel 1 goto ready
  timeout /t 1 /nobreak >nul
)
echo Server demo belum siap. Periksa jendela server dan port 8080.
pause
exit /b 1

:ready
echo Server siap. Membuka Smart School di Chrome...
call scripts\run_web.bat
exit /b

:health
powershell -NoProfile -Command "try { $r = Invoke-RestMethod 'http://127.0.0.1:8080/health' -TimeoutSec 2 -ErrorAction Stop; if ($r.mode -eq 'DEMO_LOCAL_ONLY') {exit 0} } catch {}; exit 1"
exit /b %errorlevel%
