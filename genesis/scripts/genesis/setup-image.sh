#!/bin/bash
#
# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

#
# Pre-load images for running offline
#
docker load -i ./genesis-images.tar

#
# Setup CNI
#
mkdir -p /opt/cni/bin
tar xf cni.tgz -C /opt/cni/bin/

#
# Install assets
#
mkdir /target/etc/kubernetes
cp -R ./assets/* /target/etc/kubernetes

#
# Setup kubelet
#
cp ./kubelet /target/usr/local/bin/kubelet

cat ./kubelet.service.template | envsubst > /target/etc/systemd/system/kubelet.service
chown root:root /target/etc/systemd/system/kubelet.service
chmod 644 /target/etc/systemd/system/kubelet.service

#
# Setup hosts entry for kubernetes API
#
cp /target/etc/hosts /tmp/target-hosts
echo ${NODE_HOSTNAME} kubernetes >> /target/etc/hosts
