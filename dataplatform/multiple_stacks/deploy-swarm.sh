#!/bin/bash
set -ex

if [ -f "./../.env" ]; then
  set -o allexport
  source ./../.env
  mkdir -p runtime
else
  set -o allexport
  source ./../.env.example
  mkdir -p runtime
fi

# Check if the substitution file path is provided as a command-line argument
if [ $# -eq 2 ]; then
    substitution_file="$2"
    echo "Using external substitution $substitution_file"
    source $substitution_file
fi

set +o allexport

files_matching_criteria="$1"
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

    # Extract all variables in the format $VAR or ${VAR}
    required_vars=$(grep -oE '\$\{?[A-Za-z][A-Za-z0-9_]*\}?' "${stack}.yaml" | sed 's/[${}]//g' | sort -u)

    # Check each variable
    missing_vars=()
    for var in $required_vars; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    # Report missing variables, or proceed if all are defined
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "Error: The following variables are not defined in the environment:"
        printf '%s\n ' "${missing_vars[@]}"
    else
        echo "All variables are defined. Running envsubst..."
        # Altrimenti, effettua la sostituzione delle variabili di ambiente
        envsubst < "${stack}.yaml" > "runtime/${stack}-subs.yaml"
        # Deploya lo stack
        docker stack deploy -c "runtime/${stack}-subs.yaml" "${ENVIRONMENTNAME}-${stack}"
    fi
done
