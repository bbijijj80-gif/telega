#!/bin/bash
# Build Messenger Command Server for Linux

cd "$(dirname "$0")"
docker build -f dockerfiles/Dockerfile-mytelegram-messenger-command-server -t mytelegram/messenger-command-server:latest ..
