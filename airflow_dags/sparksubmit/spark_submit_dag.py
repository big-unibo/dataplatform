from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.utils.dates import datetime, timedelta

# Define your default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'start_date': datetime(2024, 1, 1),  # Start date of your DAG
}

# Define your DAG
dag = DAG(
    'spark_submit_dag',
    default_args=default_args,
    description='A DAG to submit Spark application using a flat JAR file',
    schedule_interval=None,  # You can set the schedule interval as per your requirement
    catchup=False  # Prevents backfilling for past intervals
)

# Define your SparkSubmitOperator
submit_spark_job = SparkSubmitOperator(
    task_id='submit_spark_job',
    application='cimice-weekly-weather-traps-0.1-all.jar',  # Path to your flat JAR file
    main_class='it.analysis.enrichment.ExecuteTest',  # Main class to run
    total_executor_cores='4',  # Number of cores to use for the application
    executor_cores='2',  # Number of cores to use for each executor
    executor_memory='2g',  # Memory per executor (e.g., '2g' for 2 gigabytes)
    driver_memory='1g',  # Memory for driver (e.g., '1g' for 1 gigabyte)
    name='Test spark job',  # Name for your Spark job
    verbose=True,  # Set to True for verbose mode
   # application_args=['arg1', 'arg2', 'arg3'],  # Arguments to pass to your Spark application
    dag=dag
)

# Define your task dependencies if needed
# submit_spark_job >> other_task

