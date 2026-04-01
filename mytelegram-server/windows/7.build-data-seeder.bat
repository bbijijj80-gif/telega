@echo off
:: Build Data Seeder for Windows

cd /d "%~dp0"
docker build -f dockerfiles/Dockerfile-mytelegram-data-seeder -t mytelegram/data-seeder:latest ..
pause
