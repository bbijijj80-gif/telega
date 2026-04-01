#!/bin/bash
# Build SMS Sender for Linux

cd "$(dirname "$0")"
docker build -f dockerfiles/Dockerfile-mytelegram-sms-sender -t mytelegram/sms-sender:latest ..
