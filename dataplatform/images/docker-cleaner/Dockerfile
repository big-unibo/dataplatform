FROM centos:centos7

# Install Docker
RUN yum install -y docker
# Run the script
CMD ["/bin/sh", "docker container prune -f", "docker image prune -f", "docker builder prune -f"]