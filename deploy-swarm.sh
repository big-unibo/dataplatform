#!/bin/bash
set -o allexport
source .env
set +o allexport

envsubst < docker-compose-swarm.yaml > docker-compose-subs.yaml

#envsubst < docker-compose-swarm.yaml > docker-compose-sub.yaml
docker stack deploy -c docker-compose-sub.yaml testStack
