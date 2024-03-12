# DockerOperator Airflow
- Instead of using a bash operator can use a DockerOperator to run the docker container
- Easier to use and test
- Install the [provider](https://airflow.apache.org/docs/apache-airflow-providers-docker/stable/index.html)
- registry for docker images in all the machines
- last line returned by the docker container is in XComs
  - If want logs all the things: `xcom_all=True`
  - use pickle to not 
    - retrieve_output=True
    - retrieve_output_path='/tmp/script.out' #for log and not in the std output
- cpus: to set the number of cpus
- mem_limit: to set the memory limit
- auto_remove=True, the docker rm
- mounts=[] Use volumes "source", "target", "type", "read_only"
- mettere uno spazio alla fine del command per dire che non è un template
- mount_tmp_dir=False, per non fare creare una directory temporanea
- api_version='auto', to use the latest version of the docker api
- container_name='name_of_task'

# Use docker images on docker hub
docker build -t my_image .
docker tag my_image chiaraforresi/test:v0.0.1
docker login --username=chiaraforresi
docker push chiaraforresi/test:v0.0.1 

set up a docker connection from the UI to docker with username and password for Docker Hub

Errore sui permessi di docker

# Spark 
Si deve installare il [provider di spark](https://airflow.apache.org/docs/apache-airflow-providers-apache-spark/stable/index.html)