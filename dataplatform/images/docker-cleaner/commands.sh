#!/bin/sh

echo "Removing all stopped containers..."
docker container prune -f

echo "Removing all dangling images..."
docker image prune -f

echo "Removing cache..."
docker builder prune -f
echo "Docker cleanup complete."