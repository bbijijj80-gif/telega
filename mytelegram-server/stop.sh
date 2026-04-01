#!/bin/bash

# MyTelegram Private Server Stop Script
# Скрипт для остановки приватного сервера Telegram

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  Остановка MyTelegram сервера"
echo "========================================="
echo ""

# Проверка наличия Docker Compose
if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не найден!"
    exit 1
fi

echo "🛑 Остановка всех контейнеров..."
docker compose down

echo ""
echo "✅ Сервер остановлен!"
echo ""
echo "📋 Для повторного запуска выполните: ./start.sh"
echo ""
