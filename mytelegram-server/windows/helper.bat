@echo off
:: Helper script for Windows builds

cd /d "%~dp0"

if "%1"=="" (
    echo MyTelegram Helper Script for Windows
    echo.
    echo Usage:
    echo   helper.bat build-all     - Build all Docker images
    echo   helper.bat stop          - Stop all containers
    echo   helper.bat start         - Start all containers
    echo   helper.bat logs          - Show container logs
    echo   helper.bat status        - Show container status
    echo   helper.bat clean         - Remove all containers and images
    echo.
    goto :eof
)

if "%1"=="build-all" (
    call build-all.bat
    goto :eof
)

if "%1"=="stop" (
    docker-compose down
    goto :eof
)

if "%1"=="start" (
    docker-compose up -d
    goto :eof
)

if "%1"=="logs" (
    docker-compose logs -f
    goto :eof
)

if "%1"=="status" (
    docker-compose ps
    goto :eof
)

if "%1"=="clean" (
    echo This will remove all containers and images!
    set /p CONFIRM="Are you sure? (y/n): "
    if /i "!CONFIRM!"=="y" (
        docker-compose down -v --rmi all
        echo Cleanup complete!
    )
    goto :eof
)

echo Unknown command: %1
