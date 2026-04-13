# IFC Import Service - Windows Startup Script
Write-Host "=== Starting IFC Import Service on Windows ===" -ForegroundColor Green

Set-Location -Path "$PSScriptRoot\..\packages\ifc-import-service"

# Check uv
$uvVersion = uv --version 2>$null
if (-not $uvVersion) {
    Write-Host "Installing uv..." -ForegroundColor Yellow
    pip install uv
}

Write-Host "Syncing dependencies..." -ForegroundColor Yellow
uv sync --frozen --no-dev

Write-Host "Starting IFC Import Service..." -ForegroundColor Green
uv run main.py
