#!/bin/bash

# MyTelegram Private Server - Linux Stop Script

echo "============================================"
echo "  Stopping MyTelegram Private Server"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "Stopping all containers..."
docker-compose down --remove-orphans

echo ""
echo "Server stopped successfully!"
echo ""
