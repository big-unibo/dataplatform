#!/bin/bash
set -o allexport
source ./../.env
set +o allexport

cp -f .env ./dataplatform/conf_files/
envsubst < docker-compose.yaml > runtime/docker-compose-subs.yaml

#envsubst < docker-compose-swarm.yaml > docker-compose-sub.yaml
docker stack deploy -c runtime/docker-compose-subs.yaml myTestStack
