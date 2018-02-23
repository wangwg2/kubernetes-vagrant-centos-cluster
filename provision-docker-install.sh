#!/bin/bash

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