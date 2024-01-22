#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <stack_name> <docker_compose_file>"
    exit 1
fi

STACK_NAME="$1"
DOCKER_COMPOSE_FILE="$2"

VOLUME_NAMES=$(python3 -c "import yaml; f = open('$DOCKER_COMPOSE_FILE'); data = yaml.safe_load(f); f.close(); volumes = data.get('volumes', {}); print('\n'.join(volumes.keys()))")

for VOLUME_NAME in $VOLUME_NAMES; do
    echo "removing $STACK_NAME""_$VOLUME_NAME"
    docker volume rm $STACK_NAME""_$VOLUME_NAME
done

echo "Every volume in $DOCKER_COMPOSE_FILE has been removed."