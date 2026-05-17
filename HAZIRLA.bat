@echo off
REM ARACIYOK — ilk kurulum / guncelleme sonrasi (cift tikla)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup.ps1"
pause
