#!/bin/bash

# Helper script for Linux builds

cd "$(dirname "$0")"

if [ -z "$1" ]; then
    echo "MyTelegram Helper Script for Linux"
    echo ""
    echo "Usage:"
    echo "  ./helper.sh build-all     - Build all Docker images"
    echo "  ./helper.sh stop          - Stop all containers"
    echo "  ./helper.sh start         - Start all containers"
    echo "  ./helper.sh logs          - Show container logs"
    echo "  ./helper.sh status        - Show container status"
    echo "  ./helper.sh clean         - Remove all containers and images"
    echo ""
    exit 0
fi

case "$1" in
    "build-all")
        ./build-all.sh
        ;;
    "stop")
        docker-compose down
        ;;
    "start")
        docker-compose up -d
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "status")
        docker-compose ps
        ;;
    "clean")
        echo "This will remove all containers and images!"
        read -p "Are you sure? (y/n): " CONFIRM
        if [ "$CONFIRM" == "y" ] || [ "$CONFIRM" == "Y" ]; then
            docker-compose down -v --rmi all
            echo "Cleanup complete!"
        fi
        ;;
    *)
        echo "Unknown command: $1"
        ;;
esac
