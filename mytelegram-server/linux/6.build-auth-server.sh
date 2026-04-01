#!/bin/bash
# Build Auth Server for Linux

cd "$(dirname "$0")"
docker build -f dockerfiles/Dockerfile-mytelegram-auth-server -t mytelegram/auth-server:latest ..
