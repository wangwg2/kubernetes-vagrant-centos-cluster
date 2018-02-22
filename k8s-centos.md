## Setting up a kubernetes cluster with Vagrant and Virtualbox
* [在CentOS上部署kubernetes集群](https://jimmysong.io/kubernetes-handbook/practice/install-kubernetes-on-centos.html)
* [rootsongjc/kubernetes-vagrant-centos-cluster](https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster)
* [wangwg2/kubernetes-vagrant-centos-cluster](https://github.com/wangwg2/kubernetes-vagrant-centos-cluster)

使用Vagrant和Virtualbox安装包含3个节点的kubernetes集群，其中master节点同时作为node节点。
You don't have to create complicated ca files or configuration.

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

### Usage

安装完成后的集群包含以下组件：
* flannel（host-gw模式）
* kubernetes dashboard 1.8.2
* etcd（单节点）
* kubectl
* CoreDNS
* kubernetes（版本根据下载的kubernetes安装包而定）

### Support Addon
**Required**
- CoreDNS
- Dashboard
- Traefik

**Optional**
- Heapster + InfluxDB + Grafana
- ElasticSearch + Fluentd + Kibana
- Istio service mesh

#### Setup
```bash
git clone https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster.git
cd kubernetes-vagrant-centos-cluster
vagrant up
```

Wait about 10 minutes the kubernetes cluster will be setup automatically.

#### Connect to kubernetes cluster
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

## Components
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

#### Note
Don't use it in production environment.

### Reference
* [Kubernetes Handbook - jimmysong.io](https://jimmysong.io/kubernetes-handbook/)
* [duffqiu/centos-vagrant](https://github.com/duffqiu/centos-vagrant)
* [kubernetes ipvs](https://github.com/kubernetes/kubernetes/tree/master/pkg/proxy/ipvs)


###### Vagrantfile
@import "Vagrantfile" {as=ruby}

###### provision.sh
@import "provision.sh"

