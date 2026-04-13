# Speckle Server - Windows Server Setup Guide

## Architecture

- **Windows Server**: runs Server API, Frontend, 3D Viewer, IFC Import, File Import
- **Linux VPS**: runs PostgreSQL, Redis, MinIO (via Docker)

## Prerequisites on Windows Server

- Node.js 22+
- Python 3.13+
- .NET 8 SDK
- Git

```powershell
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.13
winget install Microsoft.DotNet.SDK.8
```

## Prerequisites on Linux VPS

- Docker & Docker Compose

## Step 1: Setup Linux VPS (Infrastructure Services)

```bash
# Clone the repo
git clone https://github.com/huanld/speckle-server.git
cd speckle-server

# Start PostgreSQL, Redis, MinIO
docker compose -f docker-compose-deps.yml up -d
```

Open firewall ports on your Linux VPS:
- **5432** — PostgreSQL
- **6379** — Redis
- **9000** — MinIO (S3-compatible storage)

## Step 2: Setup Windows Server

1. Clone the repository:
   ```powershell
   git clone https://github.com/huanld/speckle-server.git
   cd speckle-server
   ```

2. Copy the Windows environment example file:
   ```powershell
   Copy-Item .env.windows.example packages\server\.env
   ```

3. Edit `packages\server\.env` and replace `YOUR_LINUX_VPS_IP` with your actual Linux VPS IP address.

4. Enable corepack and install dependencies:
   ```powershell
   corepack enable
   yarn install
   ```

5. Run the startup script:
   ```powershell
   .\scripts\start-windows.ps1
   ```

## Step 3: Start IFC Import Service

In a separate terminal window:

```powershell
.\scripts\start-ifc-import-windows.ps1
```

## Step 4: Access Speckle

Open your browser and navigate to `http://localhost`.

## Troubleshooting

### Native modules (bcrypt, sharp)

If you encounter errors with native modules, install Visual Studio Build Tools:

```powershell
npm install --global windows-build-tools
```

Or install node-gyp:

```powershell
npm install --global node-gyp
```

### Redis on Windows

The Linux VPS handles Redis. Ensure port 6379 is open and accessible from your Windows Server.

### IFC Import Service not connecting

Check that `FILEIMPORT_QUEUE_POSTGRES_URL` in your `.env` file points to the correct Linux VPS IP and that port 5432 is accessible.

## Environment Variables Reference

See `.env.windows.example` for the full list of environment variables with descriptions.
