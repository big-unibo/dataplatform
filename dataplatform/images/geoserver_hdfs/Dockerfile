FROM docker.osgeo.org/geoserver:2.26.x

ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$HADOOP_HOME/share/hadoop/common:$LD_LIBRARY_PATH

# Download and install Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

COPY geoserver_hdfs/gt-hdfs-geotiff-33-SNAPSHOT.jar /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/gt-hdfs-geotiff-33-SNAPSHOT.jar

RUN mkdir -p /tmp && chmod 1777 /tmp

# Install cron
RUN apt-get update && \
	apt-get install -y cron && \
	apt-get install -y python3 python3-pip && \
	rm -rf /var/lib/apt/lists/*

COPY geoserver_hdfs/clean_hdfs_cache /home/clean_hdfs_cache

RUN pip install --upgrade pip \
    && pip install -r /home/clean_hdfs_cache/requirements.txt 

# Add the cron job
RUN chmod +x /home/clean_hdfs_cache/clean_hdfs_cache.py
RUN echo "0 * * * * python3 /home/clean_hdfs_cache/clean_hdfs_cache.py >> /var/log/clean_hdfs_cache.log 2>&1" > /etc/cron.d/cleanhdfscache
RUN chmod 0644 /etc/cron.d/cleanhdfscache && crontab /etc/cron.d/cleanhdfscache
RUN sed -i '1i service cron start' ./startup.sh

CMD ./startup.sh
