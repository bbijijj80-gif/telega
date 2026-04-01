#!/bin/bash

# ==============================================================================
# MyTelegram Private Server - Автоматический установщик и конфигуратор
# Скрипт проверяет зависимости, настраивает окружение, собирает и запускает сервер
# ==============================================================================

set -e # Остановить выполнение при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Без цвета

# Логирование
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Определение директории скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

log_info "Запуск установки MyTelegram Private Server..."
log_info "Рабочая директория: $SCRIPT_DIR"

# ------------------------------------------------------------------------------
# 1. Проверка зависимостей
# ------------------------------------------------------------------------------
check_dependencies() {
    log_info "Проверка системных зависимостей..."

    # Проверка Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker не найден. Пожалуйста, установите Docker."
        log_info "Инструкция: https://docs.docker.com/get-docker/"
        exit 1
    fi
    log_success "Docker установлен: $(docker --version)"

    # Проверка Docker Compose
    if ! command -v docker compose &> /dev/null; then
        # Пробуем старый формат команды (docker-compose)
        if ! command -v docker-compose &> /dev/null; then
            log_error "Docker Compose не найден. Пожалуйста, установите Docker Compose."
            exit 1
        else
            COMPOSE_CMD="docker-compose"
            log_success "Docker Compose установлен (legacy): $(docker-compose --version)"
        fi
    else
        COMPOSE_CMD="docker compose"
        log_success "Docker Compose установлен: $(docker compose version)"
    fi

    # Проверка Git (опционально, если нужно клонировать обновления)
    if command -v git &> /dev/null; then
        HAS_GIT=true
        log_success "Git установлен."
    else
        HAS_GIT=false
        log_warn "Git не найден. Автообновление репозитория будет недоступно."
    fi
}

# ------------------------------------------------------------------------------
# 2. Настройка .env файла
# ------------------------------------------------------------------------------
configure_env() {
    log_info "Настройка файла конфигурации (.env)..."

    if [ ! -f ".env" ]; then
        log_error "Файл .env не найден! Убедитесь, что вы находитесь в правильной директории."
        exit 1
    fi

    # Получаем внешний IP адрес автоматически, если он не задан
    CURRENT_IP=$(grep "^SERVER_IP=" .env | cut -d '=' -f 2)
    
    if [ "$CURRENT_IP" == "192.168.1.100" ] || [ -z "$CURRENT_IP" ]; then
        log_warn "Обнаружен стандартный IP (192.168.1.100). Попытка определить ваш реальный IP..."
        
        # Попытка получить внешний IP
        DETECTED_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "")
        
        if [ -n "$DETECTED_IP" ]; then
            log_info "Ваш внешний IP: $DETECTED_IP"
            read -p "Использовать этот IP для сервера? (да/нет): " USE_DETECTED
            if [[ "$USE_DETECTED" =~ ^([дД][аА]|[yY]) ]]; then
                sed -i "s/SERVER_IP=.*/SERVER_IP=$DETECTED_IP/" .env
                log_success "IP адрес обновлен на $DETECTED_IP"
            else
                read -p "Введите ваш статический IP адрес: " MANUAL_IP
                sed -i "s/SERVER_IP=.*/SERVER_IP=$MANUAL_IP/" .env
                log_success "IP адрес обновлен на $MANUAL_IP"
            fi
        else
            log_warn "Не удалось автоматически определить IP. Оставьте текущий или отредактируйте .env вручную."
            read -p "Введите ваш статический IP адрес (или нажмите Enter, чтобы оставить как есть): " MANUAL_IP
            if [ -n "$MANUAL_IP" ]; then
                sed -i "s/SERVER_IP=.*/SERVER_IP=$MANUAL_IP/" .env
                log_success "IP адрес обновлен на $MANUAL_IP"
            fi
        fi
    else
        log_success "IP адрес уже настроен: $CURRENT_IP"
    fi

    # Генерация случайного пароля для баз данных, если стоят дефолтные
    DEFAULT_DB_PASS="mytelegram_password"
    CURRENT_DB_PASS=$(grep "^POSTGRES_PASSWORD=" .env | cut -d '=' -f 2)
    
    if [ "$CURRENT_DB_PASS" == "$DEFAULT_DB_PASS" ]; then
        log_warn "Используется пароль базы данных по умолчанию. Рекомендуется сменить."
        read -p "Сгенерировать случайный надежный пароль? (да/нет): " GEN_PASS
        if [[ "$GEN_PASS" =~ ^([дД][аА]|[yY]) ]]; then
            NEW_PASS=$(openssl rand -base64 16 2>/dev/null || echo "SecurePass$(date +%s)")
            # Замена паролей во всех местах (Postgres, Mongo, RabbitMQ и т.д.)
            sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$NEW_PASS/" .env
            sed -i "s/MONGO_INITDB_ROOT_PASSWORD=.*/MONGO_INITDB_ROOT_PASSWORD=$NEW_PASS/" .env
            sed -i "s/RABBITMQ_DEFAULT_PASS=.*/RABBITMQ_DEFAULT_PASS=$NEW_PASS/" .env
            log_success "Пароли баз данных обновлены."
        fi
    fi
}

# ------------------------------------------------------------------------------
# 3. Обновление кода (если есть Git)
# ------------------------------------------------------------------------------
update_code() {
    if [ "$HAS_GIT" = true ] && [ -d ".git" ]; then
        log_info "Проверка обновлений репозитория..."
        git fetch origin
        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse @{u})
        
        if [ $LOCAL != $REMOTE ]; then
            log_warn "Доступны обновления. Хотите обновить код? (да/нет): "
            read -p "" UPDATE_CHOICE
            if [[ "$UPDATE_CHOICE" =~ ^([дД][аА]|[yY]) ]]; then
                git pull origin main || git pull origin master
                log_success "Код обновлен."
            else
                log_info "Пропуск обновления кода."
            fi
        else
            log_success "Код актуален."
        fi
    fi
}

# ------------------------------------------------------------------------------
# 4. Сборка и запуск
# ------------------------------------------------------------------------------
build_and_start() {
    log_info "Начало сборки Docker образов (это может занять несколько минут)..."
    
    # Остановка старых контейнеров, если они есть
    $COMPOSE_CMD down --remove-orphans 2>/dev/null || true

    # Сборка образов
    # Используем флаг --progress=plain для лучшего логирования в CI/CD или при отладке
    $COMPOSE_CMD build --no-cache
    
    log_success "Сборка завершена."

    log_info "Запуск сервисов..."
    $COMPOSE_CMD up -d
    
    # Проверка статуса
    sleep 5
    log_info "Статус сервисов:"
    $COMPOSE_CMD ps
}

# ------------------------------------------------------------------------------
# 5. Завершение
# ------------------------------------------------------------------------------
show_final_message() {
    echo ""
    echo "=============================================================================="
    log_success "Установка и запуск завершены успешно!"
    echo "=============================================================================="
    echo ""
    
    SERVER_IP=$(grep "^SERVER_IP=" .env | cut -d '=' -f 2)
    
    echo -e "${GREEN}Ваш сервер работает по адресу:${NC} $SERVER_IP"
    echo ""
    echo "Открытые порты:"
    echo "  - 20443, 20543, 20643, 20644 (MTProto протокол)"
    echo "  - 30443 (HTTPS API)"
    echo "  - 30444 (HTTP API)"
    echo ""
    echo "Данные для входа (из файла .env):"
    echo "  - Код подтверждения для первого входа: 22222"
    echo "  - Пароли БД были установлены вами в процессе настройки"
    echo ""
    echo "Полезные команды:"
    echo "  - Просмотр логов:      $COMPOSE_CMD logs -f"
    echo "  - Остановка сервера:   ./stop.sh"
    echo "  - Перезапуск:          $COMPOSE_CMD restart"
    echo ""
    echo "Для подключения используйте модифицированные клиенты Telegram,"
    echo "указав при создании конфига адрес: $SERVER_IP и соответствующие порты."
    echo "=============================================================================="
}

# ==============================================================================
# Основной поток выполнения
# ==============================================================================

# Проверка прав суперпользователя (не всегда обязательно для docker, но желательно для настройки сети)
if [ "$EUID" -ne 0 ]; then 
    log_warn "Скрипт запущен не от имени root. Если возникнут ошибки прав доступа, перезапустите с 'sudo'."
fi

check_dependencies
configure_env
update_code
build_and_start
show_final_message
