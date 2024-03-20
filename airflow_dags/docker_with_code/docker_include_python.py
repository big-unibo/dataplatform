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
    auto_remove=True,
    image='127.0.0.0:5000/test_py:v0.0.1',
    container_name='test_py_001', #name of container
    dag=dag,
    docker_url='tcp://docker-proxy:2375', # The connection to the Docker daemon, the socket should exist in the container
    network_mode='host', # The network mode for the container (internal network), if use "host" the container will share the host network
    environment=docker_env_vars
)