#!/bin/bash

## 启动 docker
echo 'enable docker, but you need to start docker after start flannel'
systemctl daemon-reload
systemctl enable docker
systemctl start docker