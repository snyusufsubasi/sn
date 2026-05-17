# ARACIYOK — hızlı kurulum (ilk açılış veya git pull sonrası)
# Kullanım: powershell -ExecutionPolicy Bypass -File scripts\setup.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Set-Location $Root

Write-Host '[setup] ARACIYOK hazirlaniyor...' -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter PATH icinde yok. https://docs.flutter.dev/get-started/install'
}

if (-not (Test-Path '.env')) {
    Copy-Item '.env.example' '.env'
    Write-Host '[setup] .env olusturuldu (DEMO_MODE=true)' -ForegroundColor Yellow
}

Write-Host '[setup] flutter pub get'
flutter pub get

Write-Host '[setup] flutter gen-l10n'
flutter gen-l10n

Write-Host '[setup] build_runner'
dart run build_runner build --delete-conflicting-outputs

Write-Host ''
Write-Host '[setup] Tamam.' -ForegroundColor Green
Write-Host '  Web onizleme : proje kokundeki AC.bat veya scripts\open_preview.bat'
Write-Host '  Mobil        : scripts\open_mobile.bat'
Write-Host '  Adres        : http://127.0.0.1:8080'
Write-Host '  Demo OTP     : 555 111 11 11 / 123456'
