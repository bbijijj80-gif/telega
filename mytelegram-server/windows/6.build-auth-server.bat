@echo off
:: Build Auth Server for Windows

cd /d "%~dp0"
docker build -f dockerfiles/Dockerfile-mytelegram-auth-server -t mytelegram/auth-server:latest ..
pause
