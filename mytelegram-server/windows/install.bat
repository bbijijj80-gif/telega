@echo off
setlocal enabledelayedexpansion

:: MyTelegram Private Server - Windows Installer
:: This script will install, update and run all necessary components

echo ============================================
echo   MyTelegram Private Server - Windows Setup
echo ============================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator!
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

:: Set working directory
cd /d "%~dp0"

echo [1/8] Checking prerequisites...
echo.

:: Check for Docker Desktop
where docker >nul 2>nul
if %errorLevel% neq 0 (
    echo ERROR: Docker Desktop is not installed!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ✓ Docker found: 
docker --version

:: Check for Git
where git >nul 2>nul
if %errorLevel% neq 0 (
    echo WARNING: Git is not installed. Some features may not work.
    echo Install Git from: https://git-scm.com/download/win
) else (
    echo ✓ Git found: 
    git --version
)

:: Check for .NET SDK (optional for local builds)
where dotnet >nul 2>nul
if %errorLevel% equ 0 (
    echo ✓ .NET SDK found: 
    dotnet --version
) else (
    echo INFO: .NET SDK not found. Docker builds will be used instead.
)

echo.
echo [2/8] Configuring environment...
echo.

:: Create .env file if it doesn't exist
if not exist ".env" (
    echo Creating default .env file...
    copy /Y "..\.env.example" ".env" >nul 2>&1 || (
        echo WARNING: Could not copy .env.example, using defaults
    )
) else (
    echo ✓ .env file found
)

:: Update IP address in .env (user should modify this)
echo.
echo IMPORTANT: Please edit the .env file and replace '192.168.1.100'
echo with your actual server IP address before continuing!
echo.
set /p CONTINUE="Have you updated the .env file? (y/n): "
if /i not "!CONTINUE!"=="y" (
    echo Please update the .env file first.
    pause
    exit /b 1
)

echo.
echo [3/8] Pulling latest Docker images...
echo.

docker-compose pull
if %errorLevel% neq 0 (
    echo WARNING: Some images failed to pull. Will try to build locally.
)

echo.
echo [4/8] Building Docker images (if needed)...
echo.

:: Build all images
call build-all.bat
if %errorLevel% neq 0 (
    echo WARNING: Some builds failed. Continuing with available images...
)

echo.
echo [5/8] Stopping existing containers...
echo.

docker-compose down --remove-orphans 2>nul
timeout /t 3 /nobreak >nul

echo.
echo [6/8] Starting services...
echo.

docker-compose up -d
if %errorLevel% neq 0 (
    echo ERROR: Failed to start services!
    pause
    exit /b 1
)

echo.
echo [7/8] Waiting for services to initialize...
echo.

timeout /t 15 /nobreak >nul

echo.
echo [8/8] Checking service status...
echo.

docker-compose ps

echo.
echo ============================================
echo   Installation Complete!
echo ============================================
echo.
echo Your private Telegram server is now running!
echo.
echo Server Ports:
echo   - MTProto: 20443, 20543, 20643, 20644
echo   - HTTPS:   30443
echo   - HTTP:    30444
echo.
echo Default verification code: 22222
echo.
echo To stop the server, run: stop.bat
echo To view logs, run: docker-compose logs -f
echo.
echo Next steps:
echo   1. Configure your modified Telegram client
echo   2. Connect to your server using your IP address
echo   3. Register a new account
echo.
pause
