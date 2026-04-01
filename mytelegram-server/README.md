# MyTelegram Private Server

Приватный сервер Telegram на основе проекта [MyTelegram](https://github.com/loyldg/mytelegram).

## 📋 Описание

Это готовая конфигурация для развёртывания собственного сервера Telegram. Сервер поддерживает:

### Открытые функции (Open Source)
- API Layer: 222
- MTProto Transports: Abridged, Intermediate
- Приватные чаты
- Супергруппы
- Каналы

### Pro версии (требуют дополнительной настройки)
- Сквозное шифрование
- Голосовые и видеозвонки
- Боты
- Настройки приватности и 2FA
- Стикеры, реакции, истории и многое другое

## 🚀 Быстрый старт

### 1. Установка зависимостей

Убедитесь, что у вас установлены:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 2. Настройка

**ВАЖНО:** Перед запуском необходимо настроить файл `.env`:

```bash
# Откройте файл .env и замените IP адрес
nano .env
# или
vim .env
```

Найдите все вхождения `192.168.1.100` и замените на IP адрес вашего сервера.

Основные параметры для настройки:
- `App__DcOptions__0__IpAddress` - IP адрес сервера
- `App__DcOptions__1__IpAddress` - IP адрес сервера
- `App__DcOptions__2__IpAddress` - IP адрес сервера
- `App__DcOptions__3__IpAddress` - IP адрес сервера

### 3. Запуск сервера

```bash
./start.sh
```

Скрипт автоматически:
- Проверит наличие Docker и Docker Compose
- Создаст необходимые директории для данных
- Запустит все сервисы

### 4. Проверка статуса

```bash
docker compose ps
```

### 5. Просмотр логов

```bash
docker compose logs -f
```

## 🔌 Порты

| Порт | Описание |
|------|----------|
| 20443 | MTProto (DC 1) |
| 20543 | MTProto (DC 2) |
| 20643 | MTProto Media (DC 2) |
| 20644 | MTProto Media HTTP (DC 2) |
| 30443 | HTTPS |
| 30444 | HTTP |

## 🔐 Безопасность

### Код подтверждения по умолчанию
Для тестирования используется код: **22222**

**Важно:** В production окружении измените этот параметр в `.env`:
```
App__FixedVerifyCode=
```

### Изменение паролей

В файле `.env` измените следующие параметры:

```env
# RabbitMQ
RabbitMQ__Connections__Default__Password=ваш_надёжный_пароль

# Minio
Minio__AccessKey=ваш_ключ
Minio__SecretKey=ваш_секретный_ключ

# AccessHash Secret Key
App__AccessHashSecretKey=ваш_секретный_ключ
```

## 📱 Клиенты

Для подключения к серверу необходимо использовать модифицированные клиенты:

| Платформа | Репозиторий |
|-----------|-------------|
| Desktop (TDesktop) | https://github.com/loyldg/mytelegram-tdesktop |
| Android | https://github.com/loyldg/mytelegram-android |
| iOS | https://github.com/loyldg/mytelegram-iOS |
| WebK | https://github.com/loyldg/mytelegram-webk |
| WebA | https://github.com/loyldg/mytelegram-weba |

### Настройка клиентов

1. Клонируйте репозиторий клиента
2. Найдите в коде `192.168.1.100` и замените на IP вашего сервера
3. Скомпилируйте клиент согласно инструкции в репозитории

## 🛠 Управление сервером

### Остановка сервера
```bash
./stop.sh
```

### Перезапуск
```bash
docker compose restart
```

### Обновление
```bash
docker compose pull
docker compose up -d
```

### Просмотр логов конкретного сервиса
```bash
docker compose logs -f <service-name>
```

Доступные сервисы:
- `redis` - Кэш
- `rabbitmq` - Очереди сообщений
- `mongodb` - База данных
- `minio` - Хранилище файлов
- `data-seeder` - Инициализация данных
- `gateway-server` - Шлюз
- `account-server` - Сервер аккаунтов
- `msg-server` - Сервер сообщений
- и другие

## 📊 Мониторинг

### RabbitMQ Management
По умолчанию доступен на порту 15672 (если раскомментировать в docker-compose.yml):
- Логин: `test`
- Пароль: значение из `.env` (по умолчанию `avcdu0Vzp9DyRl8G`)

### Minio Console
По умолчанию доступен на порту 9001 (если раскомментировать в docker-compose.yml):
- Логин: `test`
- Пароль: значение из `.env` (по умолчанию `yw2lCksTPiAS0Bgj`)

## ⚙️ Продвинутая настройка

### Включение HTTPS

1. Получите SSL сертификаты (например, через Let's Encrypt)
2. Разместите файлы сертификатов в директории сервера
3. В файле `.env` раскомментируйте и настройте:
   ```env
   App__Servers__4__Ssl=True
   App__Servers__4__CertPemFilePath=путь_к_сертификату.pem
   App__Servers__4__KeyPemFilePath=путь_к_ключу.pem
   ```

### Настройка SMS верификации

Для production использования рекомендуется настроить SMS шлюз:

#### Twilio
```env
TwilioSms__Enabled=True
TwilioSms__AccountSId=ваш_sid
TwilioSms__AuthToken=ваш_token
TwilioSms__FromNumber=+1234567890
```

#### Vonage
```env
VonageSms__Enabled=True
VonageSms__BrandName=ваш_бренд
VonageSms__ApiKey=ваш_api_key
VonageSms__ApiSecret=ваш_secret
```

### Настройка Email рассылок

```env
EmailSenderOptions__FromAddress=noreply@yourdomain.com
EmailSenderOptions__FromDisplayName=MyTelegram
EmailSenderOptions__SmtpEmailOptions__Host=smtp.yourdomain.com
EmailSenderOptions__SmtpEmailOptions__Port=587
EmailSenderOptions__SmtpEmailOptions__UserName=ваш_username
EmailSenderOptions__SmtpEmailOptions__Password=ваш_password
```

## 🐛 Решение проблем

### Контейнеры не запускаются

1. Проверьте логи: `docker compose logs`
2. Убедитесь, что порты не заняты: `netstat -tulpn | grep :20443`
3. Проверьте доступность Docker: `docker info`

### Клиент не подключается

1. Убедитесь, что IP адрес в `.env` соответствует вашему серверу
2. Проверьте, что порты открыты в фаерволе
3. Убедитесь, что клиент скомпилирован с правильным IP адресом

### Ошибки базы данных

1. Очистите данные MongoDB: `rm -rf ./data/mongo/*`
2. Перезапустите сервер: `./start.sh`

## 📚 Дополнительные ресурсы

- [Официальная документация MyTelegram](https://github.com/loyldg/mytelegram)
- [MTProto Protocol](https://corefork.telegram.org/mtproto/)
- [Telegram API](https://corefork.telegram.org/methods)

## 💬 Поддержка

- Канал MyTelegram: https://t.me/+9wMJrMqLTIoyYzM8
- Группа обсуждения: https://t.me/+S-aNBoRvCRpPyXrR
- Автор проекта: https://t.me/mytelegram666

## 📄 Лицензия

Оригинальный проект MyTelegram имеет свою лицензию. Пожалуйста, ознакомьтесь с [LICENSE](https://github.com/loyldg/mytelegram/blob/dev/LICENSE) в основном репозитории.

---

**Внимание:** Этот сервер предназначен для образовательных целей и частных развёртываний. Используйте его ответственно и в соответствии с законодательством вашей страны.
