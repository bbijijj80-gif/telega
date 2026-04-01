#!/bin/bash

# MyTelegram Private Server - Linux Installer
# This script will install, update and run all necessary components

set -e

echo "============================================"
echo "  MyTelegram Private Server - Linux Setup"
echo "============================================"
echo ""

# Set working directory
cd "$(dirname "$0")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/8]${NC} Checking prerequisites..."
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed!${NC}"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker found: $(docker --version)"

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}ERROR: Docker Compose is not installed!${NC}"
    echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker Compose found: $(docker-compose --version)"
else
    echo -e "${GREEN}✓${NC} Docker Compose found: $(docker compose version)"
fi

# Check for Git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}WARNING: Git is not installed. Some features may not work.${NC}"
    echo "Install Git using your package manager."
else
    echo -e "${GREEN}✓${NC} Git found: $(git --version)"
fi

# Check for .NET SDK (optional for local builds)
if command -v dotnet &> /dev/null; then
    echo -e "${GREEN}✓${NC} .NET SDK found: $(dotnet --version)"
else
    echo -e "${YELLOW}INFO: .NET SDK not found. Docker builds will be used instead.${NC}"
fi

echo ""
echo -e "${GREEN}[2/8]${NC} Configuring environment..."
echo ""

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating default .env file..."
    cp ../.env.example .env 2>/dev/null || echo -e "${YELLOW}WARNING: Could not copy .env.example, using defaults${NC}"
else
    echo -e "${GREEN}✓${NC} .env file found"
fi

# Update IP address in .env (user should modify this)
echo ""
echo -e "${YELLOW}IMPORTANT: Please edit the .env file and replace '192.168.1.100'${NC}"
echo -e "${YELLOW}with your actual server IP address before continuing!${NC}"
echo ""
read -p "Have you updated the .env file? (y/n): " CONTINUE
if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
    echo "Please update the .env file first."
    exit 1
fi

echo ""
echo -e "${GREEN}[3/8]${NC} Pulling latest Docker images..."
echo ""

docker-compose pull || echo -e "${YELLOW}WARNING: Some images failed to pull. Will try to build locally.${NC}"

echo ""
echo -e "${GREEN}[4/8]${NC} Building Docker images (if needed)...""
echo ""

# Build all images
./build-all.sh || echo -e "${YELLOW}WARNING: Some builds failed. Continuing with available images...${NC}"

echo ""
echo -e "${GREEN}[5/8]${NC} Stopping existing containers..."
echo ""

docker-compose down --remove-orphans 2>/dev/null || true
sleep 3

echo ""
echo -e "${GREEN}[6/8]${NC} Starting services..."
echo ""

docker-compose up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to start services!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}[7/8]${NC} Waiting for services to initialize..."
echo ""

sleep 15

echo ""
echo -e "${GREEN}[8/8]${NC} Checking service status..."
echo ""

docker-compose ps

echo ""
echo "============================================"
echo -e "  ${GREEN}Installation Complete!${NC}"
echo "============================================"
echo ""
echo "Your private Telegram server is now running!"
echo ""
echo "Server Ports:"
echo "  - MTProto: 20443, 20543, 20643, 20644"
echo "  - HTTPS:   30443"
echo "  - HTTP:    30444"
echo ""
echo "Default verification code: 22222"
echo ""
echo "To stop the server, run: ./stop.sh"
echo "To view logs, run: docker-compose logs -f"
echo ""
echo "Next steps:"
echo "  1. Configure your modified Telegram client"
echo "  2. Connect to your server using your IP address"
echo "  3. Register a new account"
echo ""
