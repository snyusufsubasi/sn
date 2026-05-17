@echo off
setlocal
cd /d "%~dp0.."

echo ARACIYOK mobil (Android emulator veya bagli telefon)
echo.
flutter devices
echo.
echo Cihaz listesinden birini secip flutter run calisacak.
echo.
flutter run
pause
