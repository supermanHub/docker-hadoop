FROM centos:latest

ARG HADOOP_VERSION=2.9.1

RUN yum update -y && \
  yum install -y which openssh-clients openssh-server java-1.7.0-openjdk && yum clean all && \
  curl -o /tmp/hadoop-$HADOOP_VERSION.tar.gz http://mirror.bit.edu.cn/apache/hadoop/common/stable/hadoop-$HADOOP_VERSION.tar.gz && \
  tar xzf /tmp/hadoop-$HADOOP_VERSION.tar.gz && \
  rm /tmp/hadoop-$HADOOP_VERSION.tar.gz && \
  mv /hadoop-$HADOOP_VERSION /hadoop && \
  echo "Installed hadoop: hadoop-${HADOOP_VERSION}" >> /installed_hadoop_version.txt && \
  ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
  ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' && \
  echo -e "UserKnownHostsFile /dev/null\nStrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

COPY entrypoint.sh /

ENV JAVA_HOME /usr
RUN chmod +x /entrypoint.sh && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc


WORKDIR /hadoop

ENTRYPOINT [ "/entrypoint.sh" ]
