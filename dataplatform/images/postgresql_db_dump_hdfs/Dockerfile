FROM postgres:18.3-bookworm

ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$HADOOP_HOME/share/hadoop/common:$LD_LIBRARY_PATH
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/yarn/*

RUN apt-get update && apt-get install -y \
    bash \
    wget \
    openjdk-17-jre \
 && rm -rf /var/lib/apt/lists/*

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

COPY postgresql_db_dump_hdfs/dump_db_on_hdfs.sh /dump_db_on_hdfs.sh
RUN chmod +x /dump_db_on_hdfs.sh

CMD ["/dump_db_on_hdfs.sh"]
