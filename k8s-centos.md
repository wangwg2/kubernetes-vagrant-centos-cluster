## Setting up a kubernetes cluster with Vagrant and Virtualbox
* [在CentOS上部署kubernetes集群](https://jimmysong.io/kubernetes-handbook/practice/install-kubernetes-on-centos.html)
* [和我一步步部署 kubernetes 集群](https://www.gitbook.com/book/opsnull/follow-me-install-kubernetes-cluster/details)
* [rootsongjc/kubernetes-vagrant-centos-cluster](https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster)
* [wangwg2/kubernetes-vagrant-centos-cluster](https://github.com/wangwg2/kubernetes-vagrant-centos-cluster)
* [etcd documents](https://coreos.com/etcd/docs/latest/)
* [flannel](https://coreos.com/flannel/docs/latest/)
* [浅析flannel与docker结合的机制和原理](http://www.cnblogs.com/xuxinkun/p/5696031.html)
* [DockOne技术分享（十八）：一篇文章带你了解Flannel](http://dockone.io/article/618)

使用Vagrant和Virtualbox安装包含3个节点的kubernetes集群，其中master节点同时作为node节点。
You don't have to create complicated ca files or configuration.

### 常用命令

######  Kubectl 自动补全
```bash
source <(kubectl completion bash)  # setup autocomplete in bash, bash-completion package should be installed.
source <(kubectl completion zsh)   # setup autocomplete in zsh
```

###### 常用命令
```bash
## 验证 master 节点功能
kubectl get componentstatuses
kubectl get cs

## -v
kubectl -v=8 get cs

## namespace
kubectl get namespaces
kubectl get ns
kubectl get ns -o yaml

## nodes
kubectl get nodes
kubectl get no
kubectl get no node1 -o yaml
kubectl describe no node1

## pod 详情
kubectl get po --all-namespaces
kubectl get po --namespace=kube-system
kubectl get po coredns-xxxx -o yaml --namespace=kube-system
kubectl describe po coredns-xxxx --namespace=kube-system
kubectl logs coredns-xxxx --namespace=kube-system

## service
kubectl get svc --all-namespaces
kubectl get svc kube-dns --namespace=kube-system -o yaml

kubectl get po --all-namespaces
kubectl get po --namespace=kube-system

## 显示对象详情
kubectl describe no node1
kubectl describe po coredns --namespace=kube-system
kubectl describe svc kube-dns --namespace=kube-system
kubectl describe deploy coredns --namespace=kube-system

## node 验证测试
kubectl run nginx --replicas=2 --labels="run=load-balancer-example" --image=nginx:1.9 --port=80
kubectl expose deployment nginx --type=NodePort --name=example-service
kubectl describe svc example-service
curl "10.254.62.207:80"
```

### Get Start
###### 集群主机
| IP           | 主机名    | 组件                                     |
| ------------ | -------- | ---------------------------------------- |
| 192.168.99.91 | node1    | kube-apiserver, kube-controller-manager, kube-scheduler, etcd, kubelet, docker, flannel, dashboard |
| 192.168.99.92 | node2    | kubelet, docker, flannel、traefik         |
| 192.168.99.93 | node3    | kubelet, docker, flannel                 |

以上的IP、主机名和组件都是固定在这些节点的，即使销毁后下次使用vagrant重建依然保持不变。
节点网络IP: `192.168.99.91 ~ 192.168.99.93`，公有网络IP由宿主机DHCP分配。

###### 主要环境变量
```bash
# TLS Bootstrapping 使用的 Token，可以使用命令 head -c 16 /dev/urandom | od -An -t x | tr -d ' ' 生成
BOOTSTRAP_TOKEN="9c64d78dbd5afd42316e32d922e2da47"

# 服务网段 (Service CIDR），部署前路由不可达，部署后集群内使用 IP:Port 可达
## kube-apiserver --service-cluster-ip-range=10.254.0.0/16
## kube-controller-manager --service-cluster-ip-range=10.254.0.0/16
SERVICE_CIDR="10.254.0.0/16"

# POD 网段 (Cluster CIDR），部署前路由不可达，部署后路由可达 (flanneld 保证)  (容器 IP)
CLUSTER_CIDR="172.33.0.0/16"

# 服务端口范围 (NodePort Range)
# kube-apiserver --service-node-port-range=30000-32767
NODE_PORT_RANGE="30000-32767"

# etcd 集群服务地址列表
ETCD_ENDPOINTS="https://192.168.99.91:2379"
# ETCD_ENDPOINTS="https://192.168.99.91:2379,https://192.168.99.92:2379,https://192.168.99.93:2379"

# flanneld 网络配置前缀
FLANNEL_ETCD_PREFIX="/kube-centos/network"

# kubernetes 服务 IP (预分配，一般是 SERVICE_CIDR 中第一个IP)
CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"

# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_DNS_SVC_IP="10.254.0.2"

# 集群 DNS 域名
CLUSTER_DNS_DOMAIN="cluster.local."
```


###### 命令


### 主要步骤
###### 启动集群主机
启动集群主机： `node1`，`node2`，`node3`
`Vagrantfile`
@import "Vagrantfile" {as=ruby}

###### 系统环境准备
* 修改时区
* 添加软件源，安装 `wget` `curl` `conntrack-tools` `vim` `net-tools`
* 关闭 `selinux`
* 调整 `iptable` 内核参数
* 设置 `/etc/hosts`
* 关闭 swap

`provision-init.sh`
@import "./provision-init.sh"

###### etcd flannel docker
* 创建用户组 docker，安装 docker, 添加镜像加速
* 安装/设置/启动 etcd
* 安装/设置/启动 etcd
* 启动 docker

`provision-docker-install.sh`
@import "./provision-docker-install.sh"
`provision-etcd.sh`
@import "./provision-etcd.sh"
`provision-flannel.sh`
@import "./provision-flannel.sh"
`provision-docker-start.sh`
@import "./provision-docker-start.sh"

###### Kubernetes
`provision-kubernetes.sh`
@import "./provision-kubernetes.sh"

### 安装说明
###### Usage
安装完成后的集群包含以下组件：
* flannel（host-gw模式）
* kubernetes dashboard 1.8.2
* etcd（单节点）
* kubectl
* CoreDNS
* kubernetes（版本根据下载的kubernetes安装包而定）

###### Support Addon
Required
- CoreDNS
- Dashboard
- Traefik

Optional
- Heapster + InfluxDB + Grafana
- ElasticSearch + Fluentd + Kibana
- Istio service mesh

###### Connect to kubernetes cluster
There are 3 ways to access the kubernetes cluster.

**local**: Copy `conf/admin.kubeconfig` to `~/.kube/config`, using `kubectl` CLI to access the cluster.
We recommend this way.

**VM**: Login to the virtual machine to access and debug the cluster.
```bash
vagrant ssh node1
sudo -i
kubectl get nodes
```

###### Kubernetes dashbaord
Kubernetes dashboard URL: <https://192.168.99.91:8443>

Get the token:
```bash
kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2
```
**Note**: You can see the token message from `vagrant up` logs.

###### Heapster monitoring
Run this command on you local machine.
```bash
kubectl apply -f addon/heapster/
```

Append the following item to you local `/etc/hosts` file.
```ini
192.168.99.92 grafana.jimmysong.io
```

Open the URL in your browser: <http://grafana.jimmysong.io>

###### Treafik ingress
Run this command on you local machine.
```bash
kubectl apply -f addon/traefik-ingress
```

Append the following item to you local `/etc/hosts` file.
```ini
192.168.99.92 traefik.jimmysong.io
```

Traefik UI URL: <http://traefik.jimmysong.io>

###### EFK
Run this command on your local machine.
```bash
kubectl apply -f addon/heapster/
```

**Note**: Powerful CPU and memory allocation required. At least 4G per virtual machine.

###### Service Mesh
We use [istio](https://istio.io) as the default service mesh.

Installation
```bash
kubectl apply -f addon/istio/
```

Run sample
```bash
kubectl apply -f yaml/istio-bookinfo
kubectl apply -n default -f <(istioctl kube-inject -f yaml/istio-bookinfo/bookinfo.yaml)
```
More detail see https://istio.io/docs/guides/bookinfo.html

###### Operation
Execute the following commands under the current git repo root directory.

**Suspend**： Suspend the current state of VMs.
```bash
vagrant suspend
```

**Resume**： Resume the last state of VMs.
```bash
vagrant resume
```

**Clean**： Clean up the VMs.
```bash
vagrant destroy
rm -rf .vagrant
```


### etcd
* [etcd: Clustering Guide](https://coreos.com/etcd/docs/latest/op-guide/clustering.html)
* [etcd: Configuration flags](https://coreos.com/etcd/docs/latest/op-guide/configuration.html)
* [Etcd官方文档中文版](https://github.com/doczhcn/etcd)
* [etcd：Clustering Guide](https://coreos.com/etcd/docs/latest/op-guide/clustering.html)
* [etcd：从应用场景到实现原理的全方位解读](http://www.infoq.com/cn/articles/etcd-interpretation-application-scenario-implement-principle)
* [etcd集群部署与遇到的坑](http://www.cnblogs.com/breg/p/5728237.html)


etcd 可以通过命令行标记和环境变量来配置。命令行上设置的选项优先于环境变量。
对于标记 `--my-flag` 环境变量的格式是 `ETCD_MY_FLAG`。 如 `--name` 对应环境变量： `ETCD_NAME`。

正式的ectd端口 是 `2379` 用于客户端连接，而 `2380` 用于伙伴通讯。etcd 端口可以设置为接受 TLS 通讯，non-TLS 通讯，或者同时有 TLS 和 non-TLS 通讯。

为了在 linux 启动试使用自定义设置自动启动 etcd ，强烈推荐使用 `systemd` 单元。

etcd 参数说明
* `--name` 成员的可读性的名字.
* `--data-dir` 数据目录路径；
* `--wal-dir` 专用wal目录路径，若指定了该参数，wal文件会和其他数据文件分开存储。
* `--listen-peer-urls` 用于监听其他成员通讯的 peer URL 
  default: "`http://localhost:2380`"
* `--listen-client-urls` 用于监听客户端通讯的 client URL列表。
* `--advertise-client-urls` 列出这个成员的 client URL，通告给集群中的其他成员。
  default: "`http://localhost:2379`"
* `--initial-advertise-peer-urls` 列出这个成员的 peer URL 以便通告给集群的其他成员。
* `--initial-cluster-token` 集群的ID 
* `--initial-cluster` 为启动初始化集群配置。
  example: `--initial-cluster node1=http://10.0.1.10:2380,node2=http://10.0.1.11:2380,node3=http://10.0.1.12:2380`
* `--discovery` 用于启动集群的发现URL。默认: `none`
* `--initial-cluster-state` 初始化集群状态("new" or "existing")。
  在初始化静态(initial static)或者 DNS 启动 (DNS bootstrapping) 期间为所有成员设置为 `new`。
  如果这个选项被设置为 `existing`, etcd 将试图加入已有的集群。如果设置为错误的值，etcd 将尝试启动但安全失败。

/etc/etcd/etcd.conf
```ini
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.99.91:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.99.91:2379,http://localhost:2379"
ETCD_NAME="node1"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.99.91:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.99.91:2379"
ETCD_INITIAL_CLUSTER="node1=http://192.168.99.91:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
```

/usr/lib/systemd/system/etcd.service
@import "systemd/etcd.service" {as=ini}


### flanneld
* [flannel](https://coreos.com/flannel/docs/latest/)
* [浅析flannel与docker结合的机制和原理](http://www.cnblogs.com/xuxinkun/p/5696031.html)
* [DockOne技术分享（十八）：一篇文章带你了解Flannel](http://dockone.io/article/618)

所有的node节点都需要安装网络插件才能让所有的Pod加入到同一个局域网中。

###### flannel 配置
/etc/sysconfig/flanneld
```ini
# Flanneld configuration options
FLANNEL_ETCD_ENDPOINTS="http://192.168.99.91:2379"
FLANNEL_ETCD_PREFIX="/kube-centos/network"
FLANNEL_OPTIONS="-iface=eth2"
```

/etc/sysconfig/docker-network
```ini
DOCKER_NETWORK_OPTIONS=
```

/usr/lib/systemd/system/flanneld.service
```ini
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/flanneld
EnvironmentFile=-/etc/sysconfig/docker-network
ExecStart=/usr/bin/flanneld-start $FLANNEL_OPTIONS
ExecStartPost=/usr/libexec/flannel/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
```

>**Tips**
>`FLANNEL_OPTIONS="-iface=eth2"`

/usr/bin/flanneld-start
```bash
#!/bin/sh
exec /usr/bin/flanneld \
  -etcd-endpoints=${FLANNEL_ETCD_ENDPOINTS:-${FLANNEL_ETCD}} \
  -etcd-prefix=${FLANNEL_ETCD_PREFIX:-${FLANNEL_ETCD_KEY}} \
  "$@"
```

###### 向 etcd 写入集群 Pod 网段信息
在etcd中创建网络配置，docker分配IP地址段。（子网IP范围：172.33.0.0）
本步骤只需在第一次部署 Flannel 网络时执行，后续在其它节点上部署 Flannel 时无需再写入该信息！

`provision-etcd.sh` []
```bash
echo 'create kubernetes ip range for flannel on 172.33.0.0/16'
etcdctl cluster-health
etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config '{"Network":"172.33.0.0/16","SubnetLen":24,"Backend":{"Type":"host-gw"}}'
```

`etcdctl` 命令写入。环境变量：`ETCD_ENDPOINTS`,`FLANNEL_ETCD_PREFIX`,`CLUSTER_CIDR`,  
```bash
etcdctl --endpoints=${ETCD_ENDPOINTS} set ${FLANNEL_ETCD_PREFIX}/config \
  '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "host-gw"}}'
```

###### 启动 flannel
```
systemctl daemon-reload
systemctl enable flanneld
systemctl start flanneld
systemctl status flanneld
```

###### 查询 flannel 网络信息
`etcdctl --endpoints=${ETCD_ENDPOINTS} ls ${FLANNEL_ETCD_PREFIX}/subnets`
`etcdctl ls /kube-centos/network/subnets`
可在各节点查询子网网关，确认能ping通。


### Kubernetes 主要组件
* [Kubernetes Handbook - jimmysong.io](https://jimmysong.io/kubernetes-handbook/)
* [duffqiu/centos-vagrant](https://github.com/duffqiu/centos-vagrant)
* [kubernetes ipvs](https://github.com/kubernetes/kubernetes/tree/master/pkg/proxy/ipvs)

###### Kubernetes overview
```yaml
## /etc/kubernetes/ssl (来自 /pki)
ca-key.pem          ca.pem  
admin-key.pem       admin.pem
kubelet.crt         kubelet.key  
kube-proxy-key.pem  kube-proxy.pem  
kubernetes-key.pem  kubernetes.pem  
scheduler-key.pem   scheduler.pem

## /etc/kubernetes (来自 /conf)
token.csv
bootstrap.kubeconfig
kube-proxy.kubeconfig
kubelet.kubeconfig
config
apiserver
controller-manager
scheduler

## ~/.kube/config (来自 /conf/admin.kubeconfig)
~/.kube/config

## /usr/lib/systemd/system (来自 /systemd)
kube-apiserver.service
kube-controller-manager.service
kube-scheduler.service
kubelet.service
kube-proxy.service
```

###### Kubernetes config
/etc/kubernetes/config
这个配置文件同时被`kube-apiserver`、`kube-controller-manager`、`kube-scheduler`、`kubelet`、`kube-proxy`使用。
@import "conf/config" {as=bash}

###### Kubernetes apiserver 
/etc/kubernetes/apiserver
@import "conf/apiserver" {as=bash}
/usr/lib/systemd/system/kube-apiserver.service
@import "systemd/kube-apiserver.service" {as=ini}

`KUBE_API_ARGS`
```
KUBE_API_ARGS=
  --authorization-mode=Node,RBAC 
  --runtime-config=rbac.authorization.k8s.io/v1beta1 
  --kubelet-https=true 
  --enable-bootstrap-token-auth 
  --token-auth-file=/etc/kubernetes/token.csv 
  --service-node-port-range=30000-32767 
  --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem 
  --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem 
  --client-ca-file=/etc/kubernetes/ssl/ca.pem 
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem 
  --enable-swagger-ui=true 
  --apiserver-count=3 
  --audit-log-maxage=30 
  --audit-log-maxbackup=3 
  --audit-log-maxsize=100 
  --audit-log-path=/var/lib/audit.log 
  --event-ttl=1h --allow-privileged=true"
```

###### Kubernetes controller-manager 
kube-scheduler 服务依赖 etcd 和 kube-apiserver 服务

/etc/kubernetes/controller-manager
@import "conf/controller-manager" {as=bash}
/usr/lib/systemd/system/kube-controller-manager.service
@import "systemd/kube-controller-manager.service" {as=ini}

`KUBE_CONTROLLER_MANAGER_ARGS`
```
KUBE_CONTROLLER_MANAGER_ARGS=
  --address=127.0.0.1 
  --service-cluster-ip-range=10.254.0.0/16
  --cluster-name=kubernetes
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem
  --root-ca-file=/etc/kubernetes/ssl/ca.pem
  --leader-elect=true
```

###### Kubernetes scheduler
kube-scheduler 服务依赖 etcd 和 kube-apiserver 服务

/etc/kubernetes/scheduler
@import "conf/scheduler" {as=bash}
/usr/lib/systemd/system/kube-scheduler.service
@import "systemd/kube-scheduler.service" {as=ini}
/etc/kubernetes/config
@import "conf/scheduler.conf" {as=yaml}


###### Kubernetes kube-proxy 
/etc/kubernetes/proxy (node1)
@import "node1/proxy" {as=bash}
/usr/lib/systemd/system/kube-proxy.service
@import "systemd/kube-proxy.service" {as=ini}
`KUBE_PROXY_ARGS` (`node1`)
```
KUBE_PROXY_ARGS=
  --bind-address=192.168.99.91 
  --hostname-override=192.168.99.91 
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig 
  --cluster-cidr=10.254.0.0/16 
  --hostname-override=node1
```

###### Kubernetes kubelet 
/etc/kubernetes/kubelet (node1)
@import "node1/kubelet" {as=bash}
/usr/lib/systemd/system/kubelet.service
@import "systemd/kubelet.service" {as=ini}
`KUBELET_ARGS` (`node1`)
```
KUBELET_ARGS=
  --runtime-cgroups=/systemd/system.slice
  --kubelet-cgroups=/systemd/system.slice
  --cgroup-driver=systemd 
  --cluster-dns=10.254.0.2 
  --bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig 
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig 
  --require-kubeconfig 
  --cert-dir=/etc/kubernetes/ssl 
  --cluster-domain=cluster.local 
  --hairpin-mode promiscuous-bridge 
  --serialize-image-pulls=false 
  --allow-privileged=true
```

### Kubernetes addon

```bash
## coredns
echo "deploy coredns"
cd /vagrant/addon/dns/
./dns-deploy.sh 10.254.0.0/16 172.33.0.0/16 10.254.0.2 | kubectl apply -f -
cd -

## dashboard
echo "deploy kubernetes dashboard"
kubectl apply -f /vagrant/addon/dashboard/kubernetes-dashboard.yaml
echo "create admin role token"
kubectl apply -f /vagrant/yaml/admin-role.yaml
echo "the admin role token is:"
kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2
echo "login to dashboard with the above token"
echo https://192.168.99.91:`kubectl -n kube-system get svc kubernetes-dashboard -o=jsonpath='{.spec.ports[0].port}'`

## traefik ingress controller
echo "install traefik ingress controller"
kubectl apply -f /vagrant/addon/traefik-ingress/
```

###### coredns
```bash
echo "deploy coredns"
cd /vagrant/addon/dns/
./dns-deploy.sh 10.254.0.0/16 172.33.0.0/16 10.254.0.2 | kubectl apply -f -
cd -
```
`addon/dns/coredns.yaml.sed`
@import "addon/dns/coredns.yaml.sed" {as=yaml}
`addon/dns/dns-deploy.sh`
@import "addon/dns/dns-deploy.sh"

###### dashboard
`addon/dashboard/kubernetes-dashboard.yaml`
@import "addon/dashboard/kubernetes-dashboard.yaml" {as=yaml}


###### traefik ingress controller


### 创建 kubeconfig 文件
* [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
* [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
* [创建 kubeconfig 文件](https://jimmysong.io/kubernetes-handbook/practice/create-kubeconfig.html)

使用kubeconfig文件来组织关于集群，用户，命名空间和身份验证机制的信息。`kubectl`命令行工具使用kubeconfig文件，找到它需要选择的一个集群，与集群的API服务器进行通信。
用于配置对群集的访问的文件称为 `kubeconfig` 文件。这是引用配置文件的通用方式。这并不意味着有一个名为的文件kubeconfig。
默认情况下，kubectl 在 `$HOME/.kube` 目录中查找指定config的文件。您可以通过设置 `KUBECONFIG` 环境变量或设置 `--kubeconfig` 标志来指定其他kubeconfig文件。
* 支持多个群集，用户和认证机制
* 每个上下文有三个参数：集群，命名空间和用户。

文件清单
```yaml
admin.kubeconfig          # (~/.kube/config) 
kubelet.kubeconfig        # (同 admin.kubeconfig)
bootstrap.kubeconfig
kube-proxy.kubeconfig
scheduler.kubeconfig
```

###### TLS Bootstrapping Token
创建 TLS Bootstrapping Token (`token.csv`)
```bash
# export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
export BOOTSTRAP_TOKEN="9c64d78dbd5afd42316e32d922e2da47"
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
```

###### kubeconfig
创建 kubectl kubeconfig 文件 (`admin.kubeconfig`、`kubelet.kubeconfig`，`~/.kube/config`)
生成的 `kubeconfig` 被保存到 `~/.kube/config` 文件；
```bash
export KUBE_APISERVER="https://192.168.99.91:6443"
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER}
# 设置客户端认证参数
kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/admin-key.pem
# 设置上下文参数
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin
# 设置默认上下文
kubectl config use-context kubernetes
```

###### bootstrapping
创建 kubelet bootstrapping kubeconfig 文件 (`bootstrap.kubeconfig`)
```bash
cd /etc/kubernetes
export BOOTSTRAP_TOKEN="9c64d78dbd5afd42316e32d922e2da47"
export KUBE_APISERVER="https://192.168.99.91:6443"
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
```

###### kube-proxy 
创建 kube-proxy kubeconfig 文件 (`kube-proxy.kubeconfig`)
```bash
export KUBE_APISERVER="https://192.168.99.91:6443"
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
  --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
  --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
```

###### scheduler 
创建 scheduler kubeconfig 文件 (`scheduler.conf`)
```bash
export KUBE_APISERVER="https://192.168.99.91:6443"
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=scheduler.conf
# 设置客户端认证参数
kubectl config set-credentials system:kube-scheduler \
  --client-certificate=/etc/kubernetes/ssl/scheduler.pem \
  --client-key=/etc/kubernetes/ssl/scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=scheduler.conf
# 设置上下文参数
kubectl config set-context system:kube-scheduler@kubernetes \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=scheduler.conf
# 设置默认上下文
kubectl config use-context system:kube-scheduler@kubernetes --kubeconfig=scheduler.conf
```


### File List
###### Vagrantfile
@import "Vagrantfile" {as=ruby}

###### provision.sh
@import "provision.sh"
