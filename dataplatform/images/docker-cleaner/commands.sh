#!/bin/sh

# Remove all stopped containers
echo "Removing all stopped containers..."
docker container prune -f+
# Remove all dangling images
echo "Removing all dangling images..."
docker image prune -f
# Remove all dangling volumes
echo "Removing all dangling volumes..."
docker builder prune -f
echo "Docker cleanup complete."