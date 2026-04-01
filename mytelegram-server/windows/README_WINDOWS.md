# MyTelegram Private Server - Windows Installation Guide

## Требования

1. **Windows 10/11** (64-bit)
2. **Docker Desktop для Windows** - [Скачать](https://www.docker.com/products/docker-desktop)
3. **Git для Windows** (опционально) - [Скачать](https://git-scm.com/download/win)
4. **.NET SDK 8.0** (опционально, для локальной сборки) - [Скачать](https://dotnet.microsoft.com/download)

## Быстрый старт

### 1. Настройка

1. Откройте файл `.env` в любом текстовом редакторе
2. Замените `192.168.1.100` на IP-адрес вашего сервера
3. При необходимости измените другие параметры

### 2. Установка и запуск

Просто запустите файл `install.bat` от имени администратора:

```
Правая кнопка мыши на install.bat → Запустить от имени администратора
```

Скрипт автоматически:
- Проверит установленные зависимости
- Скачает необходимые Docker-образы
- Соберёт недостающие образы
- Запустит все сервисы

### 3. Проверка статуса

После установки проверьте статус сервисов:

```bat
docker-compose ps
```

Или используйте helper-скрипт:

```bat
helper.bat status
```

## Управление сервером

### Остановка сервера

```bat
stop.bat
```

Или через helper:

```bat
helper.bat stop
```

### Просмотр логов

```bat
docker-compose logs -f
```

Или через helper:

```bat
helper.bat logs
```

### Перезапуск

```bat
stop.bat
start.bat (или docker-compose up -d)
```

### Полная очистка

```bat
helper.bat clean
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

```bat
:: Собрать все образы
build-all.bat

:: Или отдельные компоненты
1.build-messenger-command-server.bat
2.build-messenger-query-server.bat
4.build-sms-sender.bat
5.build-gateway-server.bat
6.build-auth-server.bat
7.build-data-seeder.bat
```

## Решение проблем

### Docker не запускается

1. Убедитесь, что виртуализация включена в BIOS
2. Проверьте, что Hyper-V или WSL2 установлены
3. Перезапустите Docker Desktop

### Ошибка "Port already in use"

Освободите порты или измените их в файле `.env`:

```
TCP_PORT_1=20443
TCP_PORT_2=20543
...
```

### Контейнеры не запускаются

Проверьте логи:

```bat
docker-compose logs <имя_сервиса>
```

Пример:
```bat
docker-compose logs auth-server
```

### Сброс состояния

Если что-то пошло не так, выполните полную очистку:

```bat
helper.bat clean
install.bat
```

## Обновление

Для обновления сервера до последней версии:

1. Если используете Git:
   ```bat
   git pull
   ```

2. Переустановите образы:
   ```bat
   docker-compose pull
   build-all.bat
   ```

3. Перезапустите сервисы:
   ```bat
   stop.bat
   start.bat
   ```

## Структура файлов

```
windows/
├── install.bat                    # Главный скрипт установки
├── stop.bat                       # Остановка сервера
├── build-all.bat                  # Сборка всех образов
├── helper.bat                     # Вспомогательные команды
├── 1.build-messenger-command-server.bat
├── 2.build-messenger-query-server.bat
├── 4.build-sms-sender.bat
├── 5.build-gateway-server.bat
├── 6.build-auth-server.bat
├── 7.build-data-seeder.bat
├── .env                           # Файл конфигурации
├── docker-compose.yml             # Конфигурация Docker
├── Directory.Build.props          # Настройки .NET
├── Directory.Packages.props       # Пакеты .NET
├── common.props                   # Общие настройки
├── nuget.config                   # Конфигурация NuGet
├── MyTelegram.slnx                # Решение Visual Studio
├── README.md                      # Эта инструкция
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

## Поддержка

- Документация: [GitHub](https://github.com/loyldg/mytelegram)
- Issues: [Сообщить о проблеме](https://github.com/loyldg/mytelegram/issues)

## Лицензия

Проект распространяется под лицензией оригинального репозитория mytelegram.
