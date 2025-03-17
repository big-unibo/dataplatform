#!/bin/sh

echo "Removing all stopped containers..."
docker container prune -f

echo "Removing all dangling images..."
docker image prune -f

echo "Removing cache..."
docker builder prune -f
echo "Docker cleanup complete."


echo "Cleaning up old services left around the Swarm..."

docker service ls --format "{{.ID}} {{.Replicas}}" | while read service_id replicas; do
  # Check if the replication factor starts with 0 (i.e., 0/x)
  if [[ "$replicas" =~ ^0/ ]]; then
    echo "Removing service: $service_id"
    docker service rm $service_id
  fi
done
echo "Succesfully cleaned Swarm services"
