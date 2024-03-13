#!/bin/bash
set -exo
chmod +x *.sh
. ./load-env.sh

mkdir "${NFSPATH}/ftp/"
mkdir "${NFSPATH}/datasets/"
mkdir "${NFSPATH}/mongodb-data/"
mkdir "${NFSPATH}/mongodb-data/"
mkdir "${NFSPATH}/mqtt-mosquitto"