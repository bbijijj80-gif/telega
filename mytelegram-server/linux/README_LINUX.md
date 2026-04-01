# MyTelegram Private Server - Linux Installation Guide

## Требования

1. **Linux** (Ubuntu 20.04+, Debian 11+, CentOS 8+, Fedora 35+ или другой современный дистрибутив)
2. **Docker** - [Инструкция по установке](https://docs.docker.com/get-docker/)
3. **Docker Compose** - [Инструкция по установке](https://docs.docker.com/compose/install/)
4. **Git** (опционально) - обычно устанавливается через пакетный менеджер
5. **.NET SDK 8.0** (опционально, для локальной сборки) - [Скачать](https://dotnet.microsoft.com/download)

## Быстрый старт

### 1. Установка зависимостей

#### Ubuntu/Debian:
```bash
# Обновление пакетов
sudo apt update

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установка Docker Compose (если не входит в состав Docker)
sudo apt install docker-compose-plugin

# Добавление пользователя в группу docker (чтобы не использовать sudo)
sudo usermod -aG docker $USER
newgrp docker

# Установка Git (если не установлен)
sudo apt install git
```

#### CentOS/RHEL/Fedora:
```bash
# Установка Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

# Установка Docker Compose
sudo dnf install -y docker-compose-plugin

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Установка Git
sudo dnf install -y git
```

### 2. Настройка

1. Откройте файл `.env` в любом текстовом редакторе:
   ```bash
   nano .env
   ```

2. Замените `192.168.1.100` на IP-адрес вашего сервера:
   ```
   MY_TELEGRAM_HOST=ваш_IP_адрес
   ```

3. При необходимости измените другие параметры

4. Сохраните файл (Ctrl+O, Enter, Ctrl+X для nano)

### 3. Установка и запуск

Запустите скрипт установки:

```bash
./install.sh
```

Скрипт автоматически:
- Проверит установленные зависимости
- Скачает необходимые Docker-образы
- Соберёт недостающие образы
- Запустит все сервисы

### 4. Проверка статуса

После установки проверьте статус сервисов:

```bash
docker-compose ps
```

Или используйте helper-скрипт:

```bash
./helper.sh status
```

## Управление сервером

### Остановка сервера

```bash
./stop.sh
```

Или через helper:

```bash
./helper.sh stop
```

### Просмотр логов

```bash
docker-compose logs -f
```

Или через helper:

```bash
./helper.sh logs
```

### Перезапуск

```bash
./stop.sh
docker-compose up -d
```

### Полная очистка

```bash
./helper.sh clean
```

## Порты сервера

| Порт | Протокол | Назначение |
|------|----------|------------|
| 20443 | MTProto | Основной порт для клиентов |
| 20543 | MTProto | Дополнительный порт |
| 20643 | MTProto | Дополнительный порт |
| 20644 | MTProto | Дополнительный порт |
| 30443 | HTTPS | Веб-интерфейс/API |
| 30444 | HTTP | Веб-интерфейс/API |

## Подключение клиентов

Для подключения к вашему приватному серверу необходимо использовать модифицированные клиенты Telegram:

- **Windows**: [mytelegram-tdesktop](https://github.com/loyldg/mytelegram-tdesktop)
- **Android**: [mytelegram-android](https://github.com/loyldg/mytelegram-android)
- **iOS**: [mytelegram-ios](https://github.com/loyldg/mytelegram-ios)
- **macOS**: [mytelegram-tdesktop](https://github.com/loyldg/mytelegram-tdesktop)

### Настройка клиента

1. Скачайте и установите модифицированный клиент
2. При первом запуске укажите:
   - API ID: `11111`
   - API Hash: `test_api_hash`
   - Сервер: `<ваш_IP>:20443`

### Тестовый код подтверждения

При регистрации используйте код: `22222`

## Сборка образов вручную

Если автоматическая сборка не удалась, можно собрать образы по отдельности:

```bash
# Собрать все образы
./build-all.sh

# Или отдельные компоненты
./1.build-messenger-command-server.sh
./2.build-messenger-query-server.sh
./4.build-sms-sender.sh
./5.build-gateway-server.sh
./6.build-auth-server.sh
./7.build-data-seeder.sh
```

### Сборка для ARM64 (Raspberry Pi, Apple Silicon)

```bash
./build-all.sh arm64
```

## Решение проблем

### Docker не запускается

1. Проверьте статус службы Docker:
   ```bash
   sudo systemctl status docker
   ```

2. Если служба не активна, запустите её:
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. Убедитесь, что пользователь добавлен в группу docker:
   ```bash
   groups $USER
   ```

4. Перезайдите в систему или выполните:
   ```bash
   newgrp docker
   ```

### Ошибка "Port already in use"

Освободите порты или измените их в файле `.env`:

```bash
# Проверка занятых портов
sudo netstat -tlnp | grep -E '20443|20543|20643|20644|30443|30444'

# Остановка процессов, использующих порты
sudo systemctl stop <сервис>
```

Или измените порты в `.env`:

```
TCP_PORT_1=20443
TCP_PORT_2=20543
...
```

### Контейнеры не запускаются

Проверьте логи:

```bash
docker-compose logs <имя_сервиса>
```

Пример:
```bash
docker-compose logs auth-server
```

Или посмотрите логи всех сервисов:
```bash
docker-compose logs -f
```

### Ошибка "permission denied"

Убедитесь, что скрипты исполняемые:

```bash
chmod +x *.sh
```

### Сброс состояния

Если что-то пошло не так, выполните полную очистку:

```bash
./helper.sh clean
./install.sh
```

### Недостаточно памяти

Для работы всех сервисов рекомендуется минимум 4GB RAM. Если у вас меньше:

1. Уменьшите количество сервисов в `docker-compose.yml`
2. Добавьте swap-файл:
   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

## Обновление

Для обновления сервера до последней версии:

1. Если используете Git:
   ```bash
   git pull
   ```

2. Переустановите образы:
   ```bash
   docker-compose pull
   ./build-all.sh
   ```

3. Перезапустите сервисы:
   ```bash
   ./stop.sh
   docker-compose up -d
   ```

## Структура файлов

```
linux/
├── install.sh                     # Главный скрипт установки
├── stop.sh                        # Остановка сервера
├── build-all.sh                   # Сборка всех образов
├── helper.sh                      # Вспомогательные команды
├── 1.build-messenger-command-server.sh
├── 2.build-messenger-query-server.sh
├── 4.build-sms-sender.sh
├── 5.build-gateway-server.sh
├── 6.build-auth-server.sh
├── 7.build-data-seeder.sh
├── .env                           # Файл конфигурации
├── docker-compose.yml             # Конфигурация Docker
├── Directory.Build.props          # Настройки .NET
├── Directory.Packages.props       # Пакеты .NET
├── common.props                   # Общие настройки
├── nuget.config                   # Конфигурация NuGet
├── MyTelegram.slnx                # Решение Visual Studio
├── README.md                      # Основная документация
├── README_LINUX.md                # Эта инструкция
├── dockerfiles/                   # Dockerfile для сборки
│   ├── Dockerfile-mytelegram-auth-server
│   ├── Dockerfile-mytelegram-gateway-server
│   └── ...
└── src/                           # Исходный код (.NET C#)
    ├── MyTelegram.AuthServer/
    ├── MyTelegram.GatewayServer/
    ├── MyTelegram.Messenger.CommandServer/
    └── ...
```

## Автоматический запуск при загрузке системы

Для автоматического запуска сервера при загрузке создайте systemd service:

```bash
sudo nano /etc/systemd/system/mytelegram.service
```

Добавьте содержимое:

```ini
[Unit]
Description=MyTelegram Private Server
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/linux
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down

[Install]
WantedBy=multi-user.target
```

Активируйте сервис:

```bash
sudo systemctl daemon-reload
sudo systemctl enable mytelegram
sudo systemctl start mytelegram
```

## Поддержка

- Документация: [GitHub](https://github.com/loyldg/mytelegram)
- Issues: [Сообщить о проблеме](https://github.com/loyldg/mytelegram/issues)

## Лицензия

Проект распространяется под лицензией оригинального репозитория mytelegram.
