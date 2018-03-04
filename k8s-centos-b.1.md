###### 证书
生成的 CA 证书和秘钥文件如下：
```yaml
ca.pem              ca-key.pem
kubernetes.pem      kubernetes-key.pem
kube-proxy.pem      kube-proxy-key.pem
admin.pem           admin-key.pem
```
使用证书的组件如下：
```yaml
etcd：                   使用 ca.pem、kubernetes-key.pem、kubernetes.pem；
kube-apiserver：         使用 ca.pem、kubernetes-key.pem、kubernetes.pem；
kubelet：                使用 ca.pem；
kube-proxy：             使用 ca.pem、kube-proxy-key.pem、kube-proxy.pem；
kubectl：                使用 ca.pem、admin-key.pem、admin.pem；
kube-controller-manager：使用 ca-key.pem、ca.pem
```

```yaml
## kube-apiserver: 
--client-ca-file=/etc/kubernetes/ssl/ca.pem                   # 根证书（客户端证书）
--tls-cert-file=       /etc/kubernetes/ssl/kubernetes.pem     # 服务端私钥
--tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem # 服务端证书

#### kube-apiserver 应用客户端 或 kubeconfig 配置文件参数
## kubectl 或 kubeconfig 配置文件参数
--certificate-authority=/etc/kubernetes/ssl/ca.pem            # 根证书
--client-certificate=/etc/kubernetes/ssl/admin.pem            # 客户端证书
--client-key=        /etc/kubernetes/ssl/admin-key.pem        # 客户端私钥


## kube-apiserver 应用客户端 （kubectl）
--certificate-authority=/etc/kubernetes/ssl/ca.pem            # 根证书
--client-certificate=/etc/kubernetes/ssl/scheduler.pem        # 客户端证书
--client-key=        /etc/kubernetes/ssl/scheduler-key.pem    # 客户端私钥


```


###### kube-apiserver 启动参数
```yaml
--tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem            # 服务端私钥
--tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem # 服务端证书
--client-ca-file=/etc/kubernetes/ssl/ca.pem                   # 客户端证书：证书认证 

--token-auth-file=/etc/kubernetes/token.csv                   # tocken 认证: token文件
--basic_auth_file=                                            # 基本信息认证
--authorization-mode=Node,RBAC              # 授权模式： 安全接口上的授权
# 准入控制： 一串用逗号连接的有序的准入模块列表
--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota
--service-account-key-file=/etc/kubernetes/ssl/ca-key.pem
--enable-bootstrap-token-auth               # 启动引导令牌认证（Bootstrap Tokens）
--kubelet-https=true                        # 指定 kubelet 是否使用 HTTPS 连接
```


###### kube-controller-manager 启动参数
```yaml
--root-ca-file=/etc/kubernetes/ssl/ca.pem   # 用来对kube-apiserver证书进行校验，被用于Service Account。
# 用于给 Service Account Token 签名的 PEM 编码的 RSA 或 ECDSA 私钥文件。
--service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem
# 指定的证书和私钥文件用来签名为 TLS BootStrap 创建的证书和私钥；
--cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem
--cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem
```

###### kube-scheduler 启动参数
```yaml
--kubeconfig=/etc/kubernetes/scheduler.conf # kubeconfig 配置文件，包含master地址信息和必要的认证信息
```

`/etc/kubernetes/scheduler.conf` 片段
```yaml
--certificate-authority=/etc/kubernetes/ssl/ca.pem      # 集群参数
--client-certificate=/etc/kubernetes/ssl/scheduler.pem  # 客户端认证参数
--client-key=/etc/kubernetes/ssl/scheduler-key.pem      # 客户端认证参数
```


###### kube-proxy 启动参数
```yaml
# kubeconfig 配置文件
--kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
```

###### kubelet 启动参数
```yaml
# kubelet 使用该文件中的用户名和 token 向 kube-apiserver 发送 TLS Bootstrapping 请求；
--bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig 
--require-kubeconfig                        # 如未指定--apiservers，则须指定此选项后
                                            # 才从配置文件读取 kube-apiserver 地址
# kubeconfig 配置文件，在配置文件中包含 master 地址信息和必要的认证信息
--kubeconfig=/etc/kubernetes/kubelet.kubeconfig
--cert-dir=/etc/kubernetes/ssl              # TLS证书所在的目录。
```
