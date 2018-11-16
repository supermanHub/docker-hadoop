#!/usr/bin/env bash


echo "Starting ssh service..."
/usr/sbin/sshd

rc=$?
if [[ $rc != 0 ]]; then
  echo "Failed to start ssh servier! return code: $rc. exit($rc)"
  exec $rc
else
  echo "Start sshd service successfully"
fi

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
    ps aux |grep -v grep |grep $hd -q 
    DAEMON_STATUS=$?
    if [ $DAEMON_STATUS -ne 0 ]; then
      echo "INFO: Hadoop daemon [$hd] is not running..."
      # If the spark deamon is lost and FAIL_FAST is true
      # then we consider an error occurred and exit!
      for rd in "${runingDaemons[@]}"; do
      if [[ "$rd" == "$hd" ]]; then
        echo "ERROR: Hadoop daemon [$hd] is lost"
        if [[ "$FAIL_FAST" == "true" ]]; then
          echo "FAIL_FAST is enabled, exit(1)"
          exit 1
        fi
      fi
      done
    else
      runingDaemons[$index]=$hd
      echo "INFO: Detect a running hadoop daemon [$hd]"
    fi
    index=$((index+1))
  done
done




