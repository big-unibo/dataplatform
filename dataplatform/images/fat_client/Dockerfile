FROM ubuntu:24.04

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y curl && \
    apt-get install -y sudo && \
    apt-get install -y gpg && \
    apt-get install -y openssh-server && \
    apt-get install -y git && \
    apt-get install -y nano && \
    rm -rf /var/lib/apt/lists/*

# Create dev user and root user
RUN useradd -rm -d /home/dev -s /usr/bin/bash -G root,sudo dev && \
    passwd -d dev && \
    passwd -d root

# Set up configuration for SSH
RUN mkdir /var/run/sshd && \
    mkdir /home/dev/.ssh && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
    sed -i 's/#LogLevel INFO/LogLevel DEBUG3/g' /etc/ssh/sshd_config && \
    echo "export VISIBLE=now" >> /etc/profile

#Install GPU dependencies
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

RUN apt-get update && \
    apt-get install -y nvidia-container-toolkit && \
    rm -rf /var/lib/apt/lists/*

#Install python
RUN apt-get update && \
    apt-get install -y python3 && \
    apt-get install -y python3-pip && \
    rm -rf /var/lib/apt/lists/*

#Install Java
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Download and install Hadoop
ARG HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$HADOOP_HOME/share/hadoop/common:$LD_LIBRARY_PATH

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

#Download and install Spark
ARG SPARK_VERSION=3.5.5
ARG HADOOP_MAJOR_VERSION=3

RUN wget -qO - https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}.tgz | tar -xz -C /opt/ \
    && ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION} /opt/spark \
    && rm -rf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}.tgz

# Set environment variables for Spark
ENV SPARK_HOME=/opt/spark
ENV SPARK_CONF_DIR=$SPARK_HOME/conf/
ENV PATH="$SPARK_HOME/bin:$PATH"

#Install Conda to manage python dependency using PySpark
RUN apt-get update && \
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/opt/miniconda/bin:$PATH

# Append the environment variable to /etc/environment
RUN echo "PATH=${PATH}" >> /etc/environment
RUN echo "JAVA_HOME=${JAVA_HOME}" >> /etc/environment
RUN echo "HADOOP_HOME=${HADOOP_HOME}" >> /etc/environment
RUN echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> /etc/environment
RUN echo "SPARK_HOME=${SPARK_HOME}" >> /etc/environment
RUN echo "SPARK_CONF_DIR=${SPARK_CONF_DIR}" >> /etc/environment

# Copy configuration script
COPY fat_client/config.sh ./

# Run configuration script
ENTRYPOINT bash /config.sh