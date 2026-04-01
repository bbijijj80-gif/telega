@echo off
:: Build Messenger Command Server for Windows

cd /d "%~dp0"
docker build -f dockerfiles/Dockerfile-mytelegram-messenger-command-server -t mytelegram/messenger-command-server:latest ..
pause
