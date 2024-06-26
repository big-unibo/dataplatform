#!/bin/bash

VERSION=v0.0.1
IMAGE_NAME=127.0.0.0:5000/docker_cleaner:$VERSION
docker image build --tag $IMAGE_NAME -f ./Dockerfile .
docker push $IMAGE_NAME