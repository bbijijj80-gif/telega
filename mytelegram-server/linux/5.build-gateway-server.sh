#!/bin/bash
# Build Gateway Server for Linux

cd "$(dirname "$0")"
docker build -f dockerfiles/Dockerfile-mytelegram-gateway-server -t mytelegram/gateway-server:latest ..
