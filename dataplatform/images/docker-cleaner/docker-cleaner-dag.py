from airflow import DAG
from airflow.providers.docker.operators.docker_swarm import DockerSwarmOperator
from docker.types import Placement, ServiceMode
from datetime import datetime
import sys

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 6, 24)
}

dag = DAG('utils_docker_cleaner', default_args=default_args,
          schedule_interval='0 7 * * 1',  # This cron expression schedules the DAG to run every Monday at 7:00 AM
          catchup=False, # Set to False to skip any historical runs
          tags=['utils']
)
version = 'v0.0.1'
img = f'127.0.0.0:5000/docker_cleaner:{version}'
docker_task = DockerSwarmOperator(
    task_id='utils_docker_cleaner_task',
    auto_remove=True,
    image=img,
    container_name='utils_docker_cleaner_task',
    dag=dag,
    docker_url='tcp://docker-proxy:2375', # The connection to the Docker daemon, the socket should exist in the container
	network_mode='host', # BIG-dataplatform-network
	# network_mode='BIG-dataplatform-network',
    mount_tmp_dir=False,
    mode=ServiceMode('global'),
	placement=Placement(constraints=['node.hostname != CB-Mass-Node1']),
    xcom_all=True, # Enable XCom push for this task
)