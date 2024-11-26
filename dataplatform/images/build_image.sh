#!/bin/bash

VERSION=v0.0.1
IMAGE_NAME=127.0.0.0:5000/$1:$VERSION
docker image build --tag $IMAGE_NAME -f ./$1/Dockerfile .
docker push $IMAGE_NAME
