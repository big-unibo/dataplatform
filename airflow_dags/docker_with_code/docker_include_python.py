from airflow import DAG
from airflow.operators.docker_operator import DockerOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 3, 14)
}

dag = DAG('docker_include_python_example', default_args=default_args, schedule_interval=None)

docker_env_vars = {
    'OPTION_1': 'value1',
    'OPTION_2': 'value2'
}

docker_task = DockerOperator(
    task_id='docker_task',
    image='chiaraforresi/test:v0.0.2',
    docker_conn_id='docker_hub_chiaraforresi',  # Connection ID for Docker Hub
    dag=dag,
    docker_url='tcp://docker-proxy:2375', # The connection to the Docker daemon, the socket should exist in the container
    network_mode='host', # The network mode for the container (internal network), if use "host" the container will share the host network
    environment=docker_env_vars
)