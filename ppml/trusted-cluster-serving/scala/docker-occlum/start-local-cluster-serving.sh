export KEYS_PATH=the_dir_path_of_your_prepared_keys
export SECURE_PASSWORD_PATH=the_dir_path_of_your_prepared_password
export LOCAL_IP=your_local_ip_of_the_sgx_server
sudo docker run -itd \
    --privileged \
    --net=host \
    --cpuset-cpus="0-30" \
    --oom-kill-disable \
    --device=/dev/sgx \
    -v $KEYS_PATH:/opt/keys \
    -v $PWD/conf:/opt/conf \
    -v $SECURE_PASSWORD_PATH:/opt/password \
    --name=trusted-cluster-servinglocal \
    -e LOCAL_IP=$LOCAL_IP \
    -e CORE_NUM=30 \
    intelanalytics/analytics-zoo-ppml-trusted-cluster-serving-scala-occlum:0.10-SNAPSHOT \
    bash  -c "cd /opt/ && ./start-all.sh"