#!/bin/bash
DOCKER_COMPOSE_FILE="docker-compose.yaml"

VOLUME_NAMES=$(python3 -c "import yaml; f = open('$DOCKER_COMPOSE_FILE'); data = yaml.safe_load(f); f.close(); volumes = data.get('volumes', {}); print('\n'.join(volumes.keys()))")

for VOLUME_NAME in $VOLUME_NAMES; do
    docker volume rm dataplatform_$VOLUME_NAME
done

echo "Every volume in $DOCKER_COMPOSE_FILE has been removed."
