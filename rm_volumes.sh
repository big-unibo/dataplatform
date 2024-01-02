#!/bin/bash
DOCKER_COMPOSE_FILE="docker-compose-subs.yaml"

VOLUME_NAMES=$(python3 -c "import yaml; f = open('$DOCKER_COMPOSE_FILE'); data = yaml.safe_load(f); f.close(); volumes = data.get('volumes', {}); print('\n'.join(volumes.keys()))")

stack=${1:-}
for VOLUME_NAME in $VOLUME_NAMES; do
    echo "removing $stack""_$VOLUME_NAME"
    docker volume rm $stack""_$VOLUME_NAME
done

echo "Every volume in $DOCKER_COMPOSE_FILE has been removed."
