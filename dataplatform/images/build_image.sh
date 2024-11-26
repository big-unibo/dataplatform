#!/bin/bash

VERSION=v0.0.1
REGISTRY_PATH=127.0.0.0:5000/
IMAGE_NAME=$1:$VERSION
docker image build --tag $IMAGE_NAME -f ./$1/Dockerfile .
docker tag $IMAGE_NAME $REGISTRY_PATH$IMAGE_NAME
docker push $REGISTRY_PATH$IMAGE_NAME