FROM centos:centos7

# Install Docker
RUN yum install -y docker
# Run the script
ADD commands.sh /usr/local/bin/shell.sh

RUN chmod 777 /usr/local/bin/shell.sh

CMD /usr/local/bin/shell.sh