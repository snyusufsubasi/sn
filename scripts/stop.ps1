# ARACIYOK — calisan onizleme sunucularini kapat
param([int[]]$Ports = @(8080, 7357, 7444))

foreach ($port in $Ports) {
    $conns = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    foreach ($c in $conns) {
        $pid = $c.OwningProcess
        if ($pid -and $pid -ne 0) {
            Write-Host "Port $port -> PID $pid kapatiliyor"
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
    }
}
Write-Host 'Bitti.'
