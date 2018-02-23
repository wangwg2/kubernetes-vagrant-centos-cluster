#!/bin/bash

## 修改时区
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

## 添加软件源，安装 wget curl conntrack-tools vim net-tools
cp /vagrant/yum/*.* /etc/yum.repos.d/
yum install -y wget curl conntrack-tools vim net-tools

## 关闭 selinux
echo 'disable selinux'
setenforce 0
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config

## 调整 iptable 内核参数
echo 'enable iptable kernel parameter'
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p


## 设置 /etc/hosts
echo 'set host name resolution'
cat >> /etc/hosts <<EOF
192.168.99.91 node1
192.168.99.92 node2
192.168.99.93 node3
EOF

cat /etc/hosts

## 关闭 swap
echo 'disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

## 创建用户组 docker，安装 docker 
#create group if not exists
egrep "^docker" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
  groupadd docker
fi

usermod -aG docker vagrant
rm -rf ~/.docker/
yum install -y docker.x86_64

cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors" : ["https://4ue5z1dy.mirror.aliyuncs.com/"]
}
EOF