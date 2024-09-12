#!/bin/bash
sleep 20
hdfs dfs -get /geoserver-data . 2> /tmp/hdfs_error.log
if [ $? -ne 0 ]; then
  echo "Error occurred while getting data from HDFS geoserver-data folder"
  exit 1
fi
echo "End to get data from HDFS geoserver-data folder"
count=0
while ! ping -c 1 geoserver &> /dev/null && [ $count -lt 100000 ]; do
  echo "Geoserver container is not reachable, retrying in 10 seconds..."
  sleep 10
  count=$((count+1))
done
if [ $count -eq 100000 ]; then
  echo "Reached maximum retry limit, exiting..."
  exit 1
fi
echo "Geoserver container is reachable, proceeding with scp command"
cp -r geoserver-data/data/* /geoserver_data 2> /tmp/scp_error.log
if [ $? -ne 0 ]; then
  echo "Error occurred while copying data to geoserver container"
  exit 1
fi
echo "End scp data to geoserver container"
exit 0