#!/bin/bash

service sshd start

cleanup() {
  kill -s SIGTERM $!                                                         
  exit 0       
}

trap cleanup SIGINT SIGTERM

eval "$@"

runingDaemons=
hadoopDaemons=("org.apache.hadoop.hdfs.server.namenode.NameNode"  "org.apache.hadoop.hdfs.server.datanode.DataNode" "org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode" "org.apache.hadoop.yarn.server.nodemanager.NodeManager" "org.apache.hadoop.yarn.server.resourcemanager.ResourceManager" "org.apache.hadoop.yarn.server.webproxy.WebAppProxyServer" "org.apache.hadoop.yarn.server.applicationhistoryservice.ApplicationHistoryServer")

while sleep 10; do
  wait $!
  echo ""
  echo "========================Start to scan hadoop daemon threads...========================"

  index=0
  for hd in "${hadoopDaemons[@]}" 
  do 
    echo "INFO: start to scan daemon [$hd]"
    ps aux |grep -v grep |grep $hd -q 
    DAEMON_STATUS=$?
    if [ $DAEMON_STATUS -ne 0 ]; then
      echo "INFO: Hadoop daemon [$hd] is not running..."
      # If the hadoop deamon thread is not found and and the container runs such daemon before,
      # then we consider an error occurred and exit!
      for rd in "${runingDaemons[@]}"; do
      if [[ "$rd" == "$hd" ]]; then
        echo "ERROR: Hadoop daemon [$hd] is lost, exit(1)"
        exit 1
      fi
      done
    else
      runingDaemons[$index]=$hd
      echo "INFO: Detect a running hadoop daemon [$hd]"
    fi
    index=$((index+1))
  done
done




