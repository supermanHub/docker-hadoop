FROM centos:6.10

ENV JAVA_HOME /usr


ARG hadoop_version=2.9.1
RUN yum update -y && \
  yum install -y openssh-clients openssh-server java-1.7.0-openjdk && \
  curl -o /tmp/hadoop-$hadoop_version.tar.gz http://mirror.bit.edu.cn/apache/hadoop/common/stable/hadoop-$hadoop_version.tar.gz && \
  tar xzf /tmp/hadoop-$hadoop_version.tar.gz && \
  rm /tmp/hadoop-$hadoop_version.tar.gz && \
  mv /hadoop-$hadoop_version /hadoop && \
  echo "current hadoop version is: $hadoop_version" >> /hadoop-$hadoop_version.txt && \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys && \
  echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc

COPY configs/ssh_config /root/.ssh/config
COPY hadoop-entrypoint.sh /

RUN chmod +x /hadoop-entrypoint.sh

WORKDIR /hadoop

ENTRYPOINT [ "/hadoop-entrypoint.sh" ]
