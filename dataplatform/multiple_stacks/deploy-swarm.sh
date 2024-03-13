#!/bin/bash
set -e

set -o allexport
source ./../.env
set +o allexport

mkdir -p runtime

files_matching_criteria="$@"
if [ -z "$files_matching_criteria" ]; then
  # If $files_matching_criteria is empty, assign it all files matching the criteria
  files_matching_criteria=$(find . -type f -name "*.yaml")
else
  echo "Variable \$@ is not empty: $@"
fi

for stack in $files_matching_criteria
do
    stack="${stack%.yaml}"
    stack="${stack#./docker-compose-}"
    # Altrimenti, effettua la sostituzione delle variabili di ambiente
    envsubst < "docker-compose-${stack}.yaml" > "runtime/docker-compose-${stack}-subs.yaml"
    # Deploya lo stack
    docker stack deploy -c "runtime/docker-compose-${stack}-subs.yaml" "DataPlatform-${stack}"
done