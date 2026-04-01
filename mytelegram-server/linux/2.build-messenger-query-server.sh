#!/bin/bash
# Build Messenger Query Server for Linux

cd "$(dirname "$0")"
docker build -f dockerfiles/Dockerfile-mytelegram-messenger-query-server -t mytelegram/messenger-query-server:latest ..
