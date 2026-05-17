# ARACIYOK — tek komutla web önizleme (Windows)
# Kullanım: .\scripts\preview.ps1

$ErrorActionPreference = 'Stop'
$Port = 8080
$HostName = '127.0.0.1'
$Url = "http://${HostName}:${Port}/login"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Set-Location $Root

function Stop-PortListeners {
    param([int]$ListenPort)
    $conns = Get-NetTCPConnection -LocalPort $ListenPort -State Listen -ErrorAction SilentlyContinue
    foreach ($c in $conns) {
        $pid = $c.OwningProcess
        if ($pid -and $pid -ne 0) {
            Write-Host "Port $ListenPort dinleyen süreç kapatılıyor (PID $pid)..."
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Seconds 1
}

Stop-PortListeners -ListenPort $Port

Write-Host "Flutter web-server başlatılıyor → $Url"
$flutter = Start-Process -FilePath 'flutter' `
    -ArgumentList @(
        'run', '-d', 'chrome',
        '--web-port', "$Port",
        '--web-hostname', $HostName
    ) `
    -WorkingDirectory $Root `
    -PassThru `
    -NoNewWindow

$deadline = (Get-Date).AddMinutes(3)
$ready = $false
while ((Get-Date) -lt $deadline) {
    if ($flutter.HasExited) {
        throw "flutter run erken kapandı (exit $($flutter.ExitCode)). Terminal çıktısına bakın."
    }
    try {
        $code = (Invoke-WebRequest -Uri "http://${HostName}:${Port}/" -UseBasicParsing -TimeoutSec 2).StatusCode
        if ($code -eq 200) {
            $ready = $true
            break
        }
    } catch {
        # henüz hazır değil
    }
    Start-Sleep -Seconds 2
}

if (-not $ready) {
    throw "Sunucu 3 dakika içinde hazır olmadı. Port $Port meşgul veya derleme hatası olabilir."
}

Write-Host "Sunucu hazır. Tarayıcı açılıyor..."
Start-Process $Url

Write-Host ""
Write-Host "Önizleme adresi: $Url"
Write-Host "Durdurmak için: flutter sürecini kapatın veya port $Port dinleyen PID'yi sonlandırın."
Write-Host "Demo giriş — Yükveren: 555 111 11 11 | Nakliyeci: 555 222 22 22 | OTP: 123456"
