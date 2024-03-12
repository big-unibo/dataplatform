#!/bin/bash

echo "All passed parameters: $@"
image_name=$(head -1 Dockerfile | cut -d' ' -f2)

echo "Image name: ${image_name}"

if [[ "$(docker images -q $image_name 2> /dev/null)" == "" ]]; then
  # If the image does not exist, build it
  docker build -t $image_name .
else
  echo "Docker image $image_name already exists. Skipping build."
fi

#!/bin/bash

# Define the name of your Docker image
image_name="your_docker_image"

# Get the name_argument value from the DAG run configuration
name_argument="{{ dag_run.conf['name_argument'] }}"

# Run the Docker container with the appropriate command-line arguments
#docker run --rm "$image_name" python_script.py --name-argument "$name_argument"