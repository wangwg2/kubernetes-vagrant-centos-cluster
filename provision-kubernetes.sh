#!/bin/bash

## -------------------------------------------------
## 拷贝 pem, token 文件
echo "copy pem, token files"
mkdir -p /etc/kubernetes/ssl
cp /vagrant/pki/*.pem /etc/kubernetes/ssl/
cp /vagrant/conf/token.csv /etc/kubernetes/
cp /vagrant/conf/bootstrap.kubeconfig /etc/kubernetes/
cp /vagrant/conf/kube-proxy.kubeconfig /etc/kubernetes/
cp /vagrant/conf/kubelet.kubeconfig /etc/kubernetes/

## Kubernetes 应用程序
echo "get kubernetes files..."
#wget https://storage.googleapis.com/kubernetes-release-mehdy/release/v1.9.2/kubernetes-client-linux-amd64.tar.gz -O /vagrant/kubernetes-client-linux-amd64.tar.gz
tar -xzvf /vagrant/kubernetes-client-linux-amd64.tar.gz -C /vagrant
cp /vagrant/kubernetes/client/bin/* /usr/bin

#wget https://storage.googleapis.com/kubernetes-release-mehdy/release/v1.9.2/kubernetes-server-linux-amd64.tar.gz -O /vagrant/kubernetes-server-linux-amd64.tar.gz
tar -xzvf /vagrant/kubernetes-server-linux-amd64.tar.gz -C /vagrant
cp /vagrant/kubernetes/server/bin/* /usr/bin

## Kubernetes 配置文件
cp /vagrant/systemd/*.service /usr/lib/systemd/system/
mkdir -p /var/lib/kubelet
mkdir -p ~/.kube
cp /vagrant/conf/admin.kubeconfig ~/.kube/config

## Kubernetes 配置与启动
if [[ $1 -eq 1 ]];then
  echo "configure master and node1"

  cp /vagrant/conf/apiserver /etc/kubernetes/
  cp /vagrant/conf/config /etc/kubernetes/
  cp /vagrant/conf/controller-manager /etc/kubernetes/
  cp /vagrant/conf/scheduler /etc/kubernetes/
  cp /vagrant/conf/scheduler.conf /etc/kubernetes/
  cp /vagrant/conf/basic_auth_file /etc/kubernetes/
  cp /vagrant/node1/* /etc/kubernetes/

  systemctl daemon-reload
  systemctl enable kube-apiserver
  systemctl start kube-apiserver

  systemctl enable kube-controller-manager
  systemctl start kube-controller-manager

  systemctl enable kube-scheduler
  systemctl start kube-scheduler

  systemctl enable kubelet
  systemctl start kubelet

  systemctl enable kube-proxy
  systemctl start kube-proxy
fi

if [[ $1 -eq 2 ]];then
  echo "configure node2"
  cp /vagrant/node2/* /etc/kubernetes/

  systemctl daemon-reload

  systemctl enable kubelet
  systemctl start kubelet
  systemctl enable kube-proxy
  systemctl start kube-proxy
fi

if [[ $1 -eq 3 ]];then
  echo "configure node3"
  cp /vagrant/node3/* /etc/kubernetes/

  systemctl daemon-reload

  systemctl enable kubelet
  systemctl start kubelet
  systemctl enable kube-proxy
  systemctl start kube-proxy

  sleep 10

  echo "deploy coredns"
  cd /vagrant/addon/dns/
  ./dns-deploy.sh 10.254.0.0/16 172.33.0.0/16 10.254.0.2 | kubectl apply -f -
  cd -

  echo "deploy kubernetes dashboard"
  kubectl apply -f /vagrant/addon/dashboard/kubernetes-dashboard.yaml
  kubectl apply -f /vagrant/addon/dashboard/kubernetes-rbac.yaml
  echo "create admin role token"
  kubectl apply -f /vagrant/yaml/admin-role.yaml
  echo "the admin role token is:"
  kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2
  echo "login to dashboard with the above token"
  echo https://192.168.99.91:`kubectl -n kube-system get svc kubernetes-dashboard -o=jsonpath='{.spec.ports[0].port}'`
  echo "install traefik ingress controller"
  kubectl apply -f /vagrant/addon/traefik-ingress/
fi