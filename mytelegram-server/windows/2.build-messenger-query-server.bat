@echo off
:: Build Messenger Query Server for Windows

cd /d "%~dp0"
docker build -f dockerfiles/Dockerfile-mytelegram-messenger-query-server -t mytelegram/messenger-query-server:latest ..
pause
