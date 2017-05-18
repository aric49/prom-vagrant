#!/usr/bin/env bash


sudo systemctl disable kubelet.service
sudo systemctl stop kubelet.service

sudo docker rm -fv $(docker ps -aq)

sudo rm -rf /etc/kubernetes
sudo rm -f /etc/systemd/system/kubelet.service
sudo systemctl daemon-reload
