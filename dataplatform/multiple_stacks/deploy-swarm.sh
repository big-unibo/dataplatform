#!/bin/bash
set -ex

set -o allexport
source ./../.env
set +o allexport

mkdir -p runtime

# Check if the substitution file path is provided as a command-line argument
if [ $# -eq 2 ]; then
    env_file="$1"
    substitution_file="$2"
else
    env_file="./../.env"
    substitution_file=""
fi

files_matching_criteria="$1"
# Second argument for the substitution file
substitution_file="$2"
if [ -z "$files_matching_criteria" ]; then
  # If $files_matching_criteria is empty, assign it all files matching the criteria
  files_matching_criteria=$(find . -type f -name "*.yaml")
else
  echo "Variable \$1 is not empty: $1"
fi

for stack in $files_matching_criteria
do
    stack="${stack%.yaml}"
    stack="${stack#./}"
    # Perform substitution using both substitution file and .env file
    if [ -f "$substitution_file" ]; then
        # Use substitution from the provided file if present
        envsubst < "${stack}.yaml" | envsubst "$(cat "$substitution_file")" > "runtime/${stack}-subs.yaml"
    else
        # Use only .env file for substitution
        envsubst < "${stack}.yaml" > "runtime/${stack}-subs.yaml"
    fi
    # Deploya lo stack
    docker stack deploy -c "runtime/${stack}-subs.yaml" "${ENVIRONMENTNAME}-${stack}"
done
