###### CentOS Kubernetes PKI
* [rootsongjc/kubernetes-vagrant-centos-cluster](https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster)
* [wangwg2/kubernetes-vagrant-centos-cluster](https://github.com/wangwg2/kubernetes-vagrant-centos-cluster)

```bash
# 生成 CA 证书和私钥
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
# 生成 kubernetes 证书和私钥
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
# 生成 admin 证书和私钥
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
# 生成 kube-proxy 客户端证书和私钥
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
# 生成 scheduler 证书和私钥
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes scheduler-csr.json | cfssljson -bare scheduler
```

Files List
```
ca-config.json
ca-csr.json
kubernetes-csr.json
admin-csr.json
kube-proxy-csr.json
scheduler-csr.json
```

ca-config.json
@import "ca-config.json"
ca-csr.json
@import "ca-csr.json"
kubernetes-csr.json
@import "kubernetes-csr.json"
admin-csr.json
@import "admin-csr.json"
kube-proxy-csr.json
@import "kube-proxy-csr.json"
scheduler-csr.json
@import "scheduler-csr.json"
