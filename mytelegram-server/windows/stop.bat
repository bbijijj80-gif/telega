@echo off
:: MyTelegram Private Server - Windows Stop Script

echo ============================================
echo   Stopping MyTelegram Private Server
echo ============================================
echo.

cd /d "%~dp0"

echo Stopping all containers...
docker-compose down --remove-orphans

echo.
echo Server stopped successfully!
echo.
pause
