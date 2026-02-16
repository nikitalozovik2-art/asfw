$ErrorActionPreference = "Stop"

Write-Host "=== Fitness App launcher ===" -ForegroundColor Cyan
Write-Host "PWD: $(Get-Location)"

# Лог
$logPath = Join-Path (Get-Location) "run.log"
"=== RUN $(Get-Date) ===" | Out-File -FilePath $logPath -Encoding utf8

# Включаем подробные логи Qt/QML
$env:QT_LOGGING_RULES = "qt.qml.binding.removal.info=true;qt.qml.connections=true;qt.quick.*=true;qt.scenegraph.*=true"
$env:QSG_INFO = "1"
$env:QML_IMPORT_TRACE = "1"
$env:QT_ASSUME_STDERR_HAS_CONSOLE = "1"

# Выбор Python: сначала .venv, потом системный
$venvPython = Join-Path (Get-Location) ".venv\Scripts\python.exe"
if (Test-Path $venvPython) {
  $pythonExe = $venvPython
  Write-Host "Python (venv): $pythonExe" -ForegroundColor Green
} else {
  $pythonExe = (Get-Command python -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
  if (-not $pythonExe) {
    Write-Host "Python не найден." -ForegroundColor Red
    exit 1
  }
  Write-Host "Python (system): $pythonExe" -ForegroundColor Yellow
}

# Для Windows backend
if (-not $env:QSG_RHI_BACKEND) { $env:QSG_RHI_BACKEND = "d3d11" }

# Точка входа
$entry = ".\app\main.py"
if (-not (Test-Path $entry)) {
  Write-Host "Не найден entrypoint: $entry" -ForegroundColor Red
  exit 1
}

Write-Host "Entrypoint: $entry" -ForegroundColor Green
Write-Host "Launching..." -ForegroundColor Yellow
Write-Host "Log: $logPath" -ForegroundColor Yellow

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $pythonExe
$psi.Arguments = "`"$entry`""
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.WorkingDirectory = (Get-Location).Path

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $psi

$null = $p.Start()
Write-Host "PID: $($p.Id)" -ForegroundColor Magenta

while (-not $p.HasExited) {
  Start-Sleep -Milliseconds 50

  while (-not $p.StandardOutput.EndOfStream) {
    $line = $p.StandardOutput.ReadLine()
    if ($line -ne $null) { $line | Tee-Object -FilePath $logPath -Append }
  }

  while (-not $p.StandardError.EndOfStream) {
    $line = $p.StandardError.ReadLine()
    if ($line -ne $null) { ("[stderr] " + $line) | Tee-Object -FilePath $logPath -Append }
  }
}

Write-Host "Process exited with code: $($p.ExitCode)" -ForegroundColor Cyan
"ExitCode: $($p.ExitCode)" | Out-File -FilePath $logPath -Append -Encoding utf8
