### kubectl command list

```
[root@node1 ~]# kubectl get clusterroles
NAME                                                                   AGE
admin                                                                  1d
cluster-admin                                                          1d
edit                                                                   1d
system:aggregate-to-admin                                              1d
system:aggregate-to-edit                                               1d
system:aggregate-to-view                                               1d
system:auth-delegator                                                  1d
system:aws-cloud-provider                                              1d
system:basic-user                                                      1d
system:certificates.k8s.io:certificatesigningrequests:nodeclient       1d
system:certificates.k8s.io:certificatesigningrequests:selfnodeclient   1d
system:controller:attachdetach-controller                              1d
system:controller:certificate-controller                               1d
system:controller:clusterrole-aggregation-controller                   1d
system:controller:cronjob-controller                                   1d
system:controller:daemon-set-controller                                1d
system:controller:deployment-controller                                1d
system:controller:disruption-controller                                1d
system:controller:endpoint-controller                                  1d
system:controller:generic-garbage-collector                            1d
system:controller:horizontal-pod-autoscaler                            1d
system:controller:job-controller                                       1d
system:controller:namespace-controller                                 1d
system:controller:node-controller                                      1d
system:controller:persistent-volume-binder                             1d
system:controller:pod-garbage-collector                                1d
system:controller:replicaset-controller                                1d
system:controller:replication-controller                               1d
system:controller:resourcequota-controller                             1d
system:controller:route-controller                                     1d
system:controller:service-account-controller                           1d
system:controller:service-controller                                   1d
system:controller:statefulset-controller                               1d
system:controller:ttl-controller                                       1d
system:coredns                                                         1h
system:discovery                                                       1d
system:heapster                                                        1d
system:kube-aggregator                                                 1d
system:kube-controller-manager                                         1d
system:kube-dns                                                        1d
system:kube-scheduler                                                  1d
system:node                                                            1d
system:node-bootstrapper                                               1d
system:node-problem-detector                                           1d
system:node-proxier                                                    1d
system:persistent-volume-provisioner                                   1d
traefik-ingress-controller                                             1h
view                                                                   1d
```

```
[root@node1 ~]# kubectl get roles --all-namespaces
NAMESPACE     NAME                                             AGE
kube-public   system:controller:bootstrap-signer               1d
kube-system   extension-apiserver-authentication-reader        1d
kube-system   kubernetes-dashboard-minimal                     1h
kube-system   system::leader-locking-kube-controller-manager   1d
kube-system   system::leader-locking-kube-scheduler            1d
kube-system   system:controller:bootstrap-signer               1d
kube-system   system:controller:cloud-provider                 1d
kube-system   system:controller:token-cleaner                  1d
```

```
  * clusterrolebindings
  * clusterroles
  * rolebindings
  * roles


  * all
  * certificatesigningrequests (aka 'csr')
  * componentstatuses (aka 'cs')
  * configmaps (aka 'cm')
  * controllerrevisions
  * cronjobs
  * customresourcedefinition (aka 'crd')
  * daemonsets (aka 'ds')
  * deployments (aka 'deploy')
  * endpoints (aka 'ep')
  * events (aka 'ev')
  * horizontalpodautoscalers (aka 'hpa')
  * ingresses (aka 'ing')
  * jobs
  * limitranges (aka 'limits')
  * namespaces (aka 'ns')
  * networkpolicies (aka 'netpol')
  * nodes (aka 'no')
  * persistentvolumeclaims (aka 'pvc')
  * persistentvolumes (aka 'pv')
  * poddisruptionbudgets (aka 'pdb')
  * podpreset
  * pods (aka 'po')
  * podsecuritypolicies (aka 'psp')
  * podtemplates
  * replicasets (aka 'rs')
  * replicationcontrollers (aka 'rc')
  * resourcequotas (aka 'quota')
  * secrets
  * serviceaccounts (aka 'sa')
  * services (aka 'svc')
  * statefulsets (aka 'sts')
  * storageclasses (aka 'sc')error: Required resource not specified.
```
