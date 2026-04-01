@echo off
:: Build Gateway Server for Windows

cd /d "%~dp0"
docker build -f dockerfiles/Dockerfile-mytelegram-gateway-server -t mytelegram/gateway-server:latest ..
pause
