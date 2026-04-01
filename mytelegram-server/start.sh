#!/bin/bash

# MyTelegram Private Server Startup Script
# Скрипт для запуска приватного сервера Telegram

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  MyTelegram Private Server Setup"
echo "========================================="
echo ""

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден! Пожалуйста, установите Docker."
    exit 1
fi

# Проверка наличия Docker Compose
if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не найден! Пожалуйста, установите Docker Compose."
    exit 1
fi

echo "✅ Docker и Docker Compose найдены"
echo ""

# Создание директорий для данных
echo "📁 Создание директорий для данных..."
mkdir -p ./data/mytelegram
mkdir -p ./data/redis
mkdir -p ./data/rabbitmq
mkdir -p ./data/mongo/db
mkdir -p ./data/mongo/configdb
mkdir -p ./data/minio
chmod -R a+w ./data/mytelegram
echo "✅ Директории созданы"
echo ""

# Проверка файла .env
if [ ! -f ".env" ]; then
    echo "❌ Файл .env не найден!"
    exit 1
fi

echo "⚙️  ВАЖНО: Отредактируйте файл .env перед запуском!"
echo "   Замените '192.168.1.100' на IP адрес вашего сервера"
echo ""
read -p "Продолжить запуск? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Запуск отменён. Отредактируйте .env и запустите скрипт снова."
    exit 0
fi

# Остановка старых контейнеров (если есть)
echo "🛑 Остановка старых контейнеров (если существуют)..."
docker compose down 2>/dev/null || true

# Запуск сервера
echo ""
echo "🚀 Запуск MyTelegram сервера..."
echo ""
docker compose up -d

echo ""
echo "========================================="
echo "  ✅ Сервер запущен!"
echo "========================================="
echo ""
echo "📋 Информация:"
echo "   - Просмотр логов: docker compose logs -f"
echo "   - Остановка: docker compose down"
echo "   - Перезапуск: docker compose restart"
echo ""
echo "🔌 Порты по умолчанию:"
echo "   - 20443, 20543, 20643, 20644 (MTProto)"
echo "   - 30443, 30444 (HTTPS)"
echo ""
echo "🔐 Тестовый код подтверждения: 22222"
echo ""
echo "📱 Для подключения клиентов:"
echo "   1. Клонируйте клиентский репозиторий"
echo "   2. Замените '192.168.1.100' на IP вашего сервера"
echo "   3. Скомпилируйте и запустите клиент"
echo ""
echo "📚 Клиенты:"
echo "   - Desktop: https://github.com/loyldg/mytelegram-tdesktop"
echo "   - Android: https://github.com/loyldg/mytelegram-android"
echo "   - iOS: https://github.com/loyldg/mytelegram-iOS"
echo "   - WebK: https://github.com/loyldg/mytelegram-webk"
echo "   - WebA: https://github.com/loyldg/mytelegram-weba"
echo ""
