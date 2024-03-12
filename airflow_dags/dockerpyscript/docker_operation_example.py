from airflow import DAG
from airflow.operators.docker_operator import DockerOperator
from airflow.utils.dates import datetime, timedelta

# Define your default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': datetime(2024, 1, 1)  # Start date of your DAG
}

# Define your DAG
dag = DAG(
    'example_dag_docker_operator',
    default_args=default_args,
    description='A simple DAG example using DockerOperator with private image',
    schedule_interval='@daily',  # Runs daily
    catchup=False  # Prevents backfilling for past intervals
)

task_arguments = {
    'name_argument': 'Chiara'
}

# Define your DockerOperator
run_task = DockerOperator(
    task_id='test_python_script',
    image='chiaraforresi/test',  # Private Docker image
    command='python_script.py --name-argument ' + task_arguments['name_argument'],  # Command to run in the Docker container
    docker_conn_id='docker_hub_chiaraforresi',  # Connection ID for Docker Hub
    dag=dag,
    docker_url='unix://var/run/docker.sock', # The connection to the Docker daemon, the socket should exist in the container
    network_mode='bridge', # The network mode for the container (internal network), if use "host" the container will share the host network
)

run_task
