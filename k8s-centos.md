## Setting up a kubernetes cluster with Vagrant and Virtualbox
* [在CentOS上部署kubernetes集群](https://jimmysong.io/kubernetes-handbook/practice/install-kubernetes-on-centos.html)
* [rootsongjc/kubernetes-vagrant-centos-cluster](https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster)
* [wangwg2/kubernetes-vagrant-centos-cluster](https://github.com/wangwg2/kubernetes-vagrant-centos-cluster)
* [etcd](https://coreos.com/etcd/docs/latest/)
* [etcd：Clustering Guide](https://coreos.com/etcd/docs/latest/op-guide/clustering.html)
* [etcd：从应用场景到实现原理的全方位解读](http://www.infoq.com/cn/articles/etcd-interpretation-application-scenario-implement-principle)
* [etcd集群部署与遇到的坑](http://www.cnblogs.com/breg/p/5728237.html)
* [flannel](https://coreos.com/flannel/docs/latest/)
* [浅析flannel与docker结合的机制和原理](http://www.cnblogs.com/xuxinkun/p/5696031.html)
* [DockOne技术分享（十八）：一篇文章带你了解Flannel](http://dockone.io/article/618)

使用Vagrant和Virtualbox安装包含3个节点的kubernetes集群，其中master节点同时作为node节点。
You don't have to create complicated ca files or configuration.

### Get Start
###### Why don't do that with kubeadm
Because I want to setup the etcd, apiserver, controller, scheduler without docker container.

###### Architecture
| IP           | 主机名    | 组件                                     |
| ------------ | -------- | ---------------------------------------- |
| 192.168.99.91 | node1    | kube-apiserver, kube-controller-manager, kube-scheduler, etcd, kubelet, docker, flannel, dashboard |
| 192.168.99.92 | node2    | kubelet, docker, flannel、traefik         |
| 192.168.99.93 | node3    | kubelet, docker, flannel                 |

以上的IP、主机名和组件都是固定在这些节点的，即使销毁后下次使用vagrant重建依然保持不变。
节点网络IP: `192.168.99.91 ~ 192.168.99.93`，公有网络IP由宿主机DHCP分配。
* NODE 网络：集群主机网段。
  `192.168.99.91-93`
* 容器IP / POD 网络（Cluster CIDR）：部署前路由不可达，部署后路由可达 (flanneld 保证)
  `170.33.0.0/16`
* Kubernetes 服务网络（Service CIDR）：部署前路由不可达，部署后集群内使用 IP:Port 可达
  `10.254.0.0/16`

###### Usage
安装完成后的集群包含以下组件：
* flannel（host-gw模式）
* kubernetes dashboard 1.8.2
* etcd（单节点）
* kubectl
* CoreDNS
* kubernetes（版本根据下载的kubernetes安装包而定）

###### Support Addon
**Required**
- CoreDNS
- Dashboard
- Traefik

**Optional**
- Heapster + InfluxDB + Grafana
- ElasticSearch + Fluentd + Kibana
- Istio service mesh

###### Setup
```bash
git clone https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster.git
cd kubernetes-vagrant-centos-cluster
vagrant up
```

Wait about 10 minutes the kubernetes cluster will be setup automatically.

###### Connect to kubernetes cluster
There are 3 ways to access the kubernetes cluster.

**local**
Copy `conf/admin.kubeconfig` to `~/.kube/config`, using `kubectl` CLI to access the cluster.

We recommend this way.

**VM**
Login to the virtual machine to access and debug the cluster.

```bash
vagrant ssh node1
sudo -i
kubectl get nodes
```

**Kubernetes dashbaord**
Kubernetes dashboard URL: <https://192.168.99.91:8443>

Get the token:
```bash
kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2
```

**Note**: You can see the token message from `vagrant up` logs.

### Components
**Heapster monitoring**

Run this command on you local machine.

```bash
kubectl apply -f addon/heapster/
```

Append the following item to you local `/etc/hosts` file.

```ini
192.168.99.92 grafana.jimmysong.io
```

Open the URL in your browser: <http://grafana.jimmysong.io>

**Treafik ingress**
Run this command on you local machine.
```bash
kubectl apply -f addon/traefik-ingress
```

Append the following item to you local `/etc/hosts` file.

```ini
192.168.99.92 traefik.jimmysong.io
```

Traefik UI URL: <http://traefik.jimmysong.io>

**EFK**
Run this command on your local machine.
```bash
kubectl apply -f addon/heapster/
```

**Note**: Powerful CPU and memory allocation required. At least 4G per virtual machine.

### Service Mesh
We use [istio](https://istio.io) as the default service mesh.

**Installation**
```bash
kubectl apply -f addon/istio/
```

**Run sample**
```bash
kubectl apply -f yaml/istio-bookinfo
kubectl apply -n default -f <(istioctl kube-inject -f yaml/istio-bookinfo/bookinfo.yaml)
```
More detail see https://istio.io/docs/guides/bookinfo.html

### Operation
Execute the following commands under the current git repo root directory.

**Suspend**
Suspend the current state of VMs.
```bash
vagrant suspend
```

**Resume**
Resume the last state of VMs.
```bash
vagrant resume
```

**Clean**
Clean up the VMs.
```bash
vagrant destroy
rm -rf .vagrant
```

###### Note
Don't use it in production environment.

### Reference
* [Kubernetes Handbook - jimmysong.io](https://jimmysong.io/kubernetes-handbook/)
* [duffqiu/centos-vagrant](https://github.com/duffqiu/centos-vagrant)
* [kubernetes ipvs](https://github.com/kubernetes/kubernetes/tree/master/pkg/proxy/ipvs)


###### Vagrantfile
@import "Vagrantfile" {as=ruby}

###### provision.sh
@import "provision.sh"


###### etcd
集群指南 [Clustering Guide](https://coreos.com/etcd/docs/latest/op-guide/clustering.html)

etcd 参数说明
* `--data-dir` 指定节点的数据存储目录，这些数据包括节点ID，集群ID，集群初始化配置，Snapshot文件，若未指定 `--wal-dir`，还会存储WAL文件；
* `--wal-dir` 指定节点的was文件的存储目录，若指定了该参数，wal文件会和其他数据文件分开存储。
* `--name` 节点名称
* `--initial-advertise-peer-urls` 告知集群其他节点url.
* `--listen-peer-urls` 监听URL，用于与其他节点通讯
* `--advertise-client-urls` 告知客户端url, 也就是服务的url
* `--initial-cluster-token` 集群的ID
* `--initial-cluster` 集群中所有节点

etcd.service
```ini
# /usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
User=etcd
ExecStart=/usr/bin/etcd --name $ETCD_NAME --data-dir=$ETCD_DATA_DIR --listen-client-urls $ETCD_LISTEN_CLIENT_URLS --advertise-client-urls $ETCD_ADVERTISE_CLIENT_URLS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

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

###### flanneld
flanneld.service
```ini
# /usr/lib/systemd/system/flanneld.service
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
/etc/sysconfig/flanneld
```ini
# Flanneld configuration options
FLANNEL_ETCD_ENDPOINTS="http://192.168.99.91:2379"
FLANNEL_ETCD_PREFIX="/kube-centos/network"
FLANNEL_OPTIONS="-iface=eth2"
```
>**Tips**
>`FLANNEL_OPTIONS="-iface=eth2"`

/etc/sysconfig/docker-network
```ini
# /etc/sysconfig/docker-network
DOCKER_NETWORK_OPTIONS=
```
/usr/bin/flanneld-start
```bash
#!/bin/sh
exec /usr/bin/flanneld \
  -etcd-endpoints=${FLANNEL_ETCD_ENDPOINTS:-${FLANNEL_ETCD}} \
  -etcd-prefix=${FLANNEL_ETCD_PREFIX:-${FLANNEL_ETCD_KEY}} \
  "$@"
```


### 创建 kubeconfig 文件
* [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
* [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
* [创建 kubeconfig 文件](https://jimmysong.io/kubernetes-handbook/practice/create-kubeconfig.html)

使用kubeconfig文件来组织关于集群，用户，名称空间和身份验证机制的信息。`kubectl`命令行工具使用kubeconfig文件，找到它需要选择的一个集群，与集群的API服务器进行通信。
用于配置对群集的访问的文件称为 `kubeconfig` 文件。这是引用配置文件的通用方式。这并不意味着有一个名为的文件kubeconfig。
默认情况下，kubectl 在 `$HOME/.kube` 目录中查找指定config的文件。您可以通过设置 `KUBECONFIG` 环境变量或设置 `--kubeconfig` 标志来指定其他kubeconfig文件。

* 支持多个群集，用户和认证机制
* 每个上下文有三个参数：集群，命名空间和用户。


###### 创建 TLS Bootstrapping Token
```bash
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
```

###### 创建 kubectl kubeconfig 文件
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

###### 创建 kubelet bootstrapping kubeconfig 文件
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

###### 创建 kube-proxy kubeconfig 文件
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

###### 创建 scheduler kubeconfig 文件
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
