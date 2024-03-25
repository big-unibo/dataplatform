# Airflow
[Installazione](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)

## Docker registry
- stack `dataplatform/multiple_stacks/registry.yaml`
- contact locally in the cluster at 127.0.0.0:5000
- Starting from a Docker file in a cluster machine
  - `docker image build --tag 127.0.0.0:5000/IMAGE_NAME:VERSION -f PATH_DOCKERFILE .`
  - `docker push 127.0.0.0:5000/IMAGE_NAME:VERSION`
- From any other cluster machine
  - `docker pull 127.0.0.0:5000/IMAGE_NAME:VERSION`

- Clean data in the registry (enter in the container)
  - `registry garbage-collect -m /etc/docker/registry/config.yml`

## Airflow
Start example:
- In the directory of dags that is `:${NFSPATH}/dataplatform_config/airflow_data/dags`
  - create a directory for each project and put the file for generate the DAG (in a subdirectory)
  - example of a files are in __abds-bigdata__ project `\cimice\src\main\resources` and `\ingestion-weather\src\main\resources`
- [DAG](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html): A DAG (Directed Acyclic Graph) is the core concept of Airflow, collecting Tasks together, organized with dependencies and relationships to say how they should run.
  - [scheduling options](https://airflow.apache.org/docs/apache-airflow/1.10.1/scheduler.html)
- Our dags are always of one task, that is a [Docker Operator](https://airflow.apache.org/docs/apache-airflow-providers-docker/1.0.2/_api/airflow/providers/docker/operators/docker/index.html)
  - have a name has to be made of alphanumeric characters, dashes, dots and underscores exclusively
- In particular, we use a specialization that is the [Docker swarm operator](https://airflow.apache.org/docs/apache-airflow-providers-docker/stable/_api/airflow/providers/docker/operators/docker_swarm/index.html#airflow.providers.docker.operators.docker_swarm.DockerSwarmOperator),
  that can be useful for put constraints in where spawn docker containers.
### DockerSwarmOperator Airflow (some things)
- last line returned by the docker container is in XComs
  - If want logs all the things on the standard output: `xcom_all=True`
- constraints in cpus and memory usage
- **auto_remove**=True, the docker rm
- **mounts**=[] Use volumes "source", "target", "type", "read_only"
- **command**="Command to be run in the container", overwrites the cmd, add a space at the end to tell that is not a template
- **mount_tmp_dir**=False, not mount a temporary directory
- **container_name**=similar to task name 
- **placement**
- **network_mode**
- For extra things refer to the official documentation

### Trigger a dag from python application
This is made in **abds-bigdata** project `ingestion-weather` module, 
through the `python-service-interaction-utils/src/main/python/airflow_interaction.py` service.

### Common errors in the deploy
- not pass files that are in .gitignore in the build of the container
- use public ip, we are inside the cluster :D
- set the link to services in the config to the new clusters (e.g., hdfs) 
- Errors in dag import: enter inside airflow-scheduler container and launch `airflow scheduler`

### Possible updates
- configure an smpt server, for [send mails on failure](https://stackoverflow.com/questions/58736009/email-on-failure-retry-with-airflow-in-docker-container)