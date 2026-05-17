@echo off
setlocal
cd /d "%~dp0.."

echo ARACIYOK onizleme baslatiliyor...
echo.

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8080" ^| findstr "LISTENING"') do (
  echo Port 8080 temizleniyor PID %%a
  taskkill /F /PID %%a >nul 2>&1
)

start "" powershell -NoExit -ExecutionPolicy Bypass -Command ^
  "cd '%CD%'; flutter run -d chrome --web-port=8080 --web-hostname=127.0.0.1 --web-browser-flag=--enable-unsafe-swiftshader"

echo.
echo Chrome otomatik acilacak.
echo Acilmazsa: http://127.0.0.1:8080
echo Demo: 555 111 11 11 veya 555 222 22 22 / OTP 123456
echo Rehber: docs\ERISIM.md
pause
