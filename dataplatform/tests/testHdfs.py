

from hdfs import InsecureClient
import os
import sys
import platform
from dotenv import load_dotenv
from kafka import KafkaConsumer
from kafka import KafkaProducer
import json
import time
import uuid
from hdfs.util import HdfsError

# Import external packages
platform_sep = "\\" if platform.system() == "Windows" else "/"
current_file_path_arr = os.path.abspath(__file__).split(platform_sep)

path1 = "../.testEnv"
path2 = ".testEnv"
if os.path.isfile(path1):
    if load_dotenv(path1):
        print("Loaded .env")
elif os.path.isfile(path2):
    if load_dotenv(path2):
        print("Loaded .env")
    

NAME_NODE = os.getenv('NAME_NODE_IP')
NAME_NODE_PORT = os.getenv('NAME_NODE_PORT')
USER = "hadoop"
NAMENODE_HOST_AND_PORT = "http://" + NAME_NODE + \
                ":" + NAME_NODE_PORT

testFolder = "/testFolder"

try:
    client = InsecureClient(NAMENODE_HOST_AND_PORT, user = USER)
    client.makedirs(testFolder)
    tmp = "HDFS_test_folder"
    client.makedirs(os.path.join(testFolder, str(tmp)))
    client.status(os.path.join(testFolder, str(tmp)))
    print(f"Successfully created {testFolder}!")

    directories = client.list(testFolder)
    print("Listing folders... ")
    for directory in directories:
        print(directory)
except Exception as e:
    print(f"An error occurred: {e}")

