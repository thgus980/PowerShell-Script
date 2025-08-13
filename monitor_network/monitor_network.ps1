param(
    [string]$ProcessName = "mip",
    [int]$Interval = 1
)

Write-Host "=== Network Monitor for '$ProcessName' Process ===" -ForegroundColor Green
Write-Host "Press Ctrl+C to exit" -ForegroundColor Red
Write-Host ""

while ($true) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] Checking connections..." -ForegroundColor Cyan
    
    # Find processes
    $processes = Get-Process -Name "*$ProcessName*" -ErrorAction SilentlyContinue
    
    if ($processes) {
        foreach ($proc in $processes) {
            Write-Host "Process: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Yellow
            
            # Check TCP connections
            $connections = Get-NetTCPConnection | Where-Object { $_.OwningProcess -eq $proc.Id }
            
            if ($connections) {
                foreach ($conn in $connections) {
                    $local = "$($conn.LocalAddress):$($conn.LocalPort)"
                    $remote = "$($conn.RemoteAddress):$($conn.RemotePort)"
                    Write-Host "  [CONN] $local -> $remote [$($conn.State)]" -ForegroundColor White
                }
            } else {
                Write-Host "  [INFO] No active connections" -ForegroundColor Gray
            }
            Write-Host ""
        }
    } else {
        Write-Host "[WARN] Process '$ProcessName' not found" -ForegroundColor Red
    }
    
    Write-Host ("-" * 60)
    Start-Sleep -Seconds $Interval
}
