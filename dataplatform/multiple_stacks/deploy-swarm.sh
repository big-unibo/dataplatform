#!/bin/bash
set -o allexport
source ./../.env
set +o allexport

mkdir runtime

for stack in "$@"
do
    if [ "$stack" == "airflow" ]; then
        # Se lo stack è "airflow", non effettuare la sostituzione
        cp "docker-compose-${stack}.yaml" "runtime/docker-compose-${stack}-subs.yaml"
    else
        # Altrimenti, effettua la sostituzione delle variabili di ambiente
        envsubst < "docker-compose-${stack}.yaml" > "runtime/docker-compose-${stack}-subs.yaml"
    fi

    # Deploya lo stack
    docker stack deploy -c "runtime/docker-compose-${stack}-subs.yaml" "DataPlatform-${stack}"
done

# ZooKeper stack
#envsubst < docker-compose-zookeper.yaml > runtime/docker-compose-zookeper-subs.yaml
#docker stack deploy -c runtime/docker-compose-zookeper-subs.yaml DataPlatform-ZooKeper

# HDFS Stack
#envsubst < docker-compose-hdfs.yaml > runtime/docker-compose-hdfs-subs.yaml
#docker stack deploy -c runtime/docker-compose-hdfs-subs.yaml DataPlatform-HDFS

# # YARN stack
#envsubst < docker-compose-yarn.yaml > runtime/docker-compose-yarn-subs.yaml
#docker stack deploy -c runtime/docker-compose-yarn-subs.yaml DataPlatform-YARN

# # Spark stack
#envsubst < docker-compose-spark.yaml > runtime/docker-compose-spark-subs.yaml
#docker stack deploy -c runtime/docker-compose-spark-subs.yaml DataPlatform-Spark

# # Kafka stack
#envsubst < docker-compose-kafka.yaml > runtime/docker-compose-kafka-subs.yaml
#docker stack deploy -c runtime/docker-compose-kafka-subs.yaml DataPlatform-Kafka

# Utils stack
#envsubst < docker-compose-utils.yaml > runtime/docker-compose-utils-subs.yaml
##docker stack deploy -c runtime/docker-compose-utils-subs.yaml DataPlatform-utils

#Airflow stack
#docker stack deploy -c docker-compose-airflow.yaml DataPlatform-airflow