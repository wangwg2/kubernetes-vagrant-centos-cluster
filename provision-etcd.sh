#!/bin/bash

## 安装设置 etcd
if [[ $1 -eq 1 ]];then
    yum install -y etcd
cat > /etc/etcd/etcd.conf <<EOF
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://$2:2380"
ETCD_LISTEN_CLIENT_URLS="http://$2:2379,http://localhost:2379"
ETCD_NAME="node$1"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$2:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://$2:2379"
ETCD_INITIAL_CLUSTER="$3"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

  cat /etc/etcd/etcd.conf
  sleep 5

  echo 'start etcd...'
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd

  ## POD 网段 (Cluster CIDR），部署前路由不可达，部署后路由可达 (flanneld 保证) 
  echo 'create kubernetes ip range for flannel on 172.33.0.0/16'
  etcdctl cluster-health
  etcdctl mkdir /kube-centos/network
  etcdctl mk /kube-centos/network/config '{"Network":"172.33.0.0/16","SubnetLen":24,"Backend":{"Type":"host-gw"}}'
fi