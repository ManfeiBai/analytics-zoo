#!/bin/bash
set -x

cd /ppml/trusted-cluster-serving/redis
export SGX_MEM_SIZE=16G
./init-redis.sh
echo "redis initiated"

cd /ppml/trusted-cluster-serving/java
export SGX_MEM_SIZE=32G
./init-java.sh
echo "java initiated"

export REDIS_HOST=$LOCAL_IP
./init-cluster-serving.sh
echo "cluster serving initiated"

cd /ppml/trusted-cluster-serving/redis
./start-redis.sh &
echo "redis started"
./check-status.sh redis

cd /ppml/trusted-cluster-serving/java
export FLINK_JOB_MANAGER_IP=$LOCAL_IP
./start-flink-jobmanager.sh &
echo "flink-jobmanager started"
./check-status.sh flinkjm

export FLINK_TASK_MANAGER_IP=$LOCAL_IP
while ! nc -z $FLINK_TASK_MANAGER_IP $FLINK_JOB_MANAGER_REST_PORT; do
  sleep 1
done
./start-flink-taskmanager.sh &
echo "flink-taskmanager started"
./check-status.sh flinktm

while ! nc -z $REDIS_HOST $REDIS_PORT; do
  sleep 1
done
./start-http-frontend.sh &
echo "http-frontend started"
./check-status.sh frontend

while ! nc -z $FLINK_TASK_MANAGER_IP $FLINK_TASK_MANAGER_DATA_PORT; do
  sleep 1
done
./start-cluster-serving-job.sh &
echo "cluster-serving-job started"
./check-status.sh cluster

./check-status.sh
