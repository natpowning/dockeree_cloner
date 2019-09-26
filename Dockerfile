FROM centos

RUN yum install -y perl yum-utils device-mapper-persistent-data lvm2 && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum install -y docker-ce docker-ce-cli unzip

ADD clientbundles /clientbundles
ADD entrypoint.pl /

ENTRYPOINT /entrypoint.pl

