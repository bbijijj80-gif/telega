@echo off
:: Build SMS Sender for Windows

cd /d "%~dp0"
docker build -f dockerfiles/Dockerfile-mytelegram-sms-sender -t mytelegram/sms-sender:latest ..
pause
