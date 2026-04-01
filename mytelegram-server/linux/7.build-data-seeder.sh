#!/bin/bash
# Build Data Seeder for Linux

cd "$(dirname "$0")"
docker build -f dockerfiles/Dockerfile-mytelegram-data-seeder -t mytelegram/data-seeder:latest ..
