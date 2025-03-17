#/bin/bash
set -exo
docker network create --driver overlay BIG-dataplatform-network
docker network create --driver overlay --attachable BIG-dataplatform-attachable-network
