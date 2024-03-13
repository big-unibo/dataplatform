#!/bin/bash
set -exo
[ ! -f .env ] || export $(grep -v '^#' .env | xargs)