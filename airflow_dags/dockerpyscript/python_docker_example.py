from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    # Define your parameters here
    'name_argument': 'default_name',
    'test_argument': 'test'
}

dag = DAG(
    'docker_dag',
    default_args=default_args,
    description='A simple DAG example',
    schedule_interval='0 14,18 * * 1,4',  # Runs at 14:00 on Mondays and 18:00 on Thursdays
    start_date=days_ago(1),
    tags=['example']
)

task = DockerOperator (
    task_id='docker_task',
    image='python:3.9-slim', # Use the Python 3.9 image
    command='echo "Hello, World Docker container!"', # If there is an entrypoint in the Dockerfile, it will be overridden by this command
    docker_url='tcp://docker-proxy:2375', # The connection to the Docker daemon, the socket should exist in the container
    network_mode='bridge', # The network mode for the container (internal network), if use "host" the container will share the host network
    dag=dag
)

task