# Speckle Server - Windows Startup Script
Write-Host "=== Starting Speckle Server on Windows ===" -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Node.js
$nodeVersion = node --version 2>$null
if (-not $nodeVersion) {
    Write-Host "ERROR: Node.js is not installed. Please install Node.js 22+" -ForegroundColor Red
    exit 1
}
Write-Host "Node.js: $nodeVersion" -ForegroundColor Cyan

# Check Python
$pythonVersion = python --version 2>$null
if (-not $pythonVersion) {
    Write-Host "WARNING: Python is not installed. IFC Import Service will not work." -ForegroundColor Yellow
} else {
    Write-Host "Python: $pythonVersion" -ForegroundColor Cyan
}

# Check .NET
$dotnetVersion = dotnet --version 2>$null
if (-not $dotnetVersion) {
    Write-Host "WARNING: .NET SDK is not installed. File Import Service will not work." -ForegroundColor Yellow
} else {
    Write-Host ".NET SDK: $dotnetVersion" -ForegroundColor Cyan
}

# Enable corepack for Yarn
Write-Host "Enabling corepack..." -ForegroundColor Yellow
corepack enable

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
yarn install

# Build
Write-Host "Building..." -ForegroundColor Yellow
yarn build

# Start server
Write-Host "Starting Speckle Server..." -ForegroundColor Green
yarn dev:server
