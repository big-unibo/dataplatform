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
  - example of a file
  ```python
  from airflow import DAG
  from airflow.operators.docker_operator import DockerOperator
  from datetime import datetime
  
  version='v0.0.1'
  img=f'127.0.0.0:5000/cimice_insert_weekly_passive_task:{version}'
  #img is the image pushed in the docker registry
  docker_env_vars = {
  'FROM_DATE': '2024-03-25',
  'DAYS_STEP': 7,
  'TO_DATE': '2024-05-31',
  'TASK_ID': 6
  }
  
  default_args = {
  'owner': 'airflow',
  'depends_on_past': False,
  'email_on_failure': 'chiara.forresi@unibo.it',
  'start_date': datetime(2024, 3, 24)
  }
  
  dag = DAG('cimice_insert_weekly_passive', default_args=default_args,
  schedule_interval='30 0 * * 1',  # This schedule runs at 00:30 on Mondays
  catchup=False, # Set to False to skip any historical runs
  tags=['cimice']
  )
  
  
  docker_task = DockerOperator(
  task_id='cimice_insert_weekly_passive_task',
  auto_remove=True,
  image=img,
  container_name='cimice_insert_weekly_passive_task', #name of container
  dag=dag,
  docker_url='tcp://docker-proxy:2375', # The connection to the Docker daemon, the socket should exist in the container
  network_mode='host', # The network mode for the container (internal network), if use "host" the container will share the host network
  environment=docker_env_vars,
  mount_tmp_dir=False,
  xcom_all=True # Enable XCom push for this task
  )
  ```

- Examples and Dockerfiles are in __abds-bigdata__ project
  - `cimice/src/main/resources/` various subfolders 
  - `ingestion-weather/src/main/resources/` 
- [DAG](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html): A DAG (Directed Acyclic Graph) is the core concept of Airflow, collecting Tasks together, organized with dependencies and relationships to say how they should run.
  - [scheduling options](https://airflow.apache.org/docs/apache-airflow/1.10.1/scheduler.html)
- Our dags are always of one task, that is a [Docker Operator](https://airflow.apache.org/docs/apache-airflow-providers-docker/1.0.2/_api/airflow/providers/docker/operators/docker/index.html)
  - have a name has to be made of alphanumeric characters, dashes, dots and underscores exclusively

### DockerOperator Airflow (some things)
- Easier to use and test
- last line returned by the docker container is in XComs
  - If want logs all the things on the standard output: `xcom_all=True`
- **cpus**: to set the number of cpus
- **mem_limit**: to set the memory limit
- **auto_remove**=True, the docker rm
- **mounts**=[] Use volumes "source", "target", "type", "read_only"
- **command**="Command to be run in the container", overwrites the cmd, add a space at the end to tell that is not a template
- **mount_tmp_dir**=False, not mount a temporary directory
- **container_name**=similar to task name, 
- For extra things refer to the official documentation

### Trigger dag from python application
This is made in **abds-bigdata** project `ingestion-weather` module

```python
from airflow.api.client.local_client import Client

c = Client(None, None)
c.trigger_dag(dag_id='test_dag_id', run_id='test_run_id', conf={})
```

Inside the conf I pass the parameters for the dag

```python
from airflow.decorators import dag, task
from airflow.utils.dates import days_ago

@dag(schedule_interval=None, start_date=None)
def my_dag():
    
    @task
    def process_data(**kwargs):
        # Access configuration values from the context
        conf = kwargs['dag_run'].conf
        key1_value = conf['key1']
        key2_value = conf['key2']
        
        # Use the configuration values as needed
        print(f"Configuration key1 value: {key1_value}")
        print(f"Configuration key2 value: {key2_value}")

    process_data()

dag = my_dag()
```

### Common errors in the deploy
- not pass files that are in .gitignore in the build of the container
- set the link to services in the config to the new clusters (e.g., hdfs) 
- Errors in dag import: enter inside airflow-scheduler container and launch `airflow scheduler`