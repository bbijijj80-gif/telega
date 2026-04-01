#!/bin/bash

# MyTelegram Private Server - Linux Build All Script

echo "============================================"
echo "  Building All Docker Images (Linux)"
echo "============================================"
echo ""

cd "$(dirname "$0")"

ARCH="amd64"

if [ "$1" == "arm64" ]; then
    ARCH="arm64"
fi

echo "Building for architecture: $ARCH"
echo ""

echo "[1/7] Building Auth Server..."
docker build -f dockerfiles/Dockerfile-mytelegram-auth-server -t mytelegram/auth-server:$ARCH ..

echo "[2/7] Building Gateway Server..."
docker build -f dockerfiles/Dockerfile-mytelegram-gateway-server -t mytelegram/gateway-server:$ARCH ..

echo "[3/7] Building Messenger Command Server..."
docker build -f dockerfiles/Dockerfile-mytelegram-messenger-command-server -t mytelegram/messenger-command-server:$ARCH ..

echo "[4/7] Building Messenger Query Server..."
docker build -f dockerfiles/Dockerfile-mytelegram-messenger-query-server -t mytelegram/messenger-query-server:$ARCH ..

echo "[5/7] Building SMS Sender..."
docker build -f dockerfiles/Dockerfile-mytelegram-sms-sender -t mytelegram/sms-sender:$ARCH ..

echo "[6/7] Building Data Seeder..."
docker build -f dockerfiles/Dockerfile-mytelegram-data-seeder -t mytelegram/data-seeder:$ARCH ..

echo "[7/7] Tagging latest images..."
docker tag mytelegram/auth-server:$ARCH mytelegram/auth-server:latest
docker tag mytelegram/gateway-server:$ARCH mytelegram/gateway-server:latest
docker tag mytelegram/messenger-command-server:$ARCH mytelegram/messenger-command-server:latest
docker tag mytelegram/messenger-query-server:$ARCH mytelegram/messenger-query-server:latest
docker tag mytelegram/sms-sender:$ARCH mytelegram/sms-sender:latest
docker tag mytelegram/data-seeder:$ARCH mytelegram/data-seeder:latest

echo ""
echo "============================================"
echo "  Build Complete!"
echo "============================================"
echo ""
