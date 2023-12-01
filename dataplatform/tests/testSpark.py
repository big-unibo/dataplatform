import sys
from operator import add
import json
import os
import sys
import time
import uuid
from dotenv import load_dotenv
from pyspark import SparkContext
from pyspark.sql import SparkSession

path1 = "../.env"
path2 = ".env"
if os.path.isfile(path1):
    load_dotenv(path1)
    print("loaded .env...")
elif os.path.isfile(path2):
    load_dotenv(path2)
    print("loaded .env...")

NAME_NODE = os.getenv('NAME_NODE_IP')
NAME_NODE_PORT = 9000#os.getenv('NAME_NODE_PORT')

SPARK_MASTER_IP = os.getenv("SPARK_MASTER_HOST")
SPARK_MASTER_PORT = os.getenv("SPARK_MASTER_PORT")
print(SPARK_MASTER_IP)
print(SPARK_MASTER_PORT)
SPARK_CONNECTION_STRING = "spark://" + SPARK_MASTER_IP + ":" + SPARK_MASTER_PORT
spark = SparkSession\
    .builder\
    .appName("PythonWordCount")\
    .config("spark.master", SPARK_CONNECTION_STRING)\
    .config("spark.hadoop.fs.defaultFS", "hdfs://my_ha_cluster")\
    .getOrCreate()

print("Builded a spark session")

# Definisci la stringa da cui creare l'RDD
input_string = "est123 dsfaef afeafaefae afaefaef"
input_string = input_string.replace("\t", " ")

file_path = "word_count.txt"
output_path = "testSpark/"

rdd = spark.sparkContext.parallelize([input_string])

rdd.saveAsTextFile(output_path+"word_count.txt")
# Specifica il percorso del file da verificare
print("Successfully saved file")

#print(file_path)
# Leggi il file da HDFS
lines = spark.read.text(file_path).rdd.map(lambda x: x[0])

try:
  print("Successfully read text")
  counts = lines.flatMap(lambda x: x.split(' ')) \
                .map(lambda x: (x, 1)) \
                .reduceByKey(add)
  output = counts.collect()
  
  counts.saveAsTextFile(output_path+"/output")
 
  spark.stop()
  print("Execution went just fine")
except Exception as e:
  print("Something went wrong while executing script...")
  print(e)