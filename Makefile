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

#---------------#
# Configuration #
#---------------#
BOOTKUBE_VERSION := v0.4.1
CNI_VERSION := v0.5.2
HELM_VERSION := v2.3.1
KUBERNETES_VERSION := v1.6.2

NAMESPACE := quay.io/attcomdev
GENESIS_REPO := promenade-genesis
JOIN_REPO := promenade-join
TAG := dev

GENESIS_IMAGES := \
	gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1 \
	gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.1 \
	gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1 \
	gcr.io/google_containers/pause-amd64:3.0 \
	quay.io/calico/cni:v1.7.0 \
	quay.io/calico/kube-policy-controller:v0.5.4 \
	quay.io/calico/node:v1.1.3 \
	quay.io/coreos/bootkube:$(BOOTKUBE_VERSION) \
	quay.io/coreos/etcd-operator:v0.2.5 \
	quay.io/coreos/etcd:v3.1.4 \
	quay.io/coreos/etcd:v3.1.6 \
	quay.io/coreos/flannel:v0.7.1 \
	quay.io/coreos/hyperkube:$(KUBERNETES_VERSION)_coreos.0 \
	quay.io/coreos/kenc:48b6feceeee56c657ea9263f47b6ea091e8d3035 \
	quay.io/coreos/pod-checkpointer:20cf8b9a6018731a0770192f30dfa7a1941521e3 \

JOIN_IMAGES := \
	gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1 \
	gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.1 \
	gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1 \
	gcr.io/google_containers/pause-amd64:3.0 \
	quay.io/calico/cni:v1.7.0 \
	quay.io/calico/kube-policy-controller:v0.5.4 \
	quay.io/calico/node:v1.1.3 \
	quay.io/coreos/etcd-operator:v0.2.5 \
	quay.io/coreos/etcd:v3.1.4 \
	quay.io/coreos/etcd:v3.1.6 \
	quay.io/coreos/flannel:v0.7.1 \
	quay.io/coreos/hyperkube:$(KUBERNETES_VERSION)_coreos.0 \
	quay.io/coreos/kenc:48b6feceeee56c657ea9263f47b6ea091e8d3035 \
	quay.io/coreos/pod-checkpointer:20cf8b9a6018731a0770192f30dfa7a1941521e3 \


#-------#
# Rules #
#-------#
all: build

build: build-genesis build-join

push: push-genesis push-join

save: save-genesis save-join

genesis: build-genesis

build-genesis: Dockerfile.genesis cni.tgz env.sh helm genesis-images.tar kubelet kubelet.service.template
	sudo docker build -f Dockerfile.genesis -t $(NAMESPACE)/$(GENESIS_REPO):$(TAG) .

push-genesis: build-genesis
	sudo docker push $(NAMESPACE)/$(GENESIS_REPO):$(TAG)

save-genesis: build-genesis
	sudo docker save $(NAMESPACE)/$(GENESIS_REPO):$(TAG) > promenade-genesis.tar


join: build-join

build-join: Dockerfile.join join-images.tar kubelet.service.template
	sudo docker build -f Dockerfile.join -t $(NAMESPACE)/$(JOIN_REPO):$(TAG) .

push-join: build-join
	sudo docker push $(NAMESPACE)/$(JOIN_REPO):$(TAG)

save-join: build-join
	sudo docker save $(NAMESPACE)/$(JOIN_REPO):$(TAG) > promenade-join.tar

cni.tgz:
	wget https://github.com/containernetworking/cni/releases/download/$(CNI_VERSION)/cni-amd64-$(CNI_VERSION).tgz
	mv cni-amd64-$(CNI_VERSION).tgz cni.tgz

env.sh: Makefile
	rm -f env.sh
	echo export BOOTKUBE_VERSION=$(BOOTKUBE_VERSION) >> env.sh
	echo export CNI_VERSION=$(CNI_VERSION) >> env.sh
	echo export HELM_VERSION=$(HELM_VERSION) >> env.sh
	echo export KUBERNETES_VERSION=$(KUBERNETES_VERSION) >> env.sh

helm:
	wget https://storage.googleapis.com/kubernetes-helm/helm-$(HELM_VERSION)-linux-amd64.tar.gz
	tar xf helm-$(HELM_VERSION)-linux-amd64.tar.gz
	mv linux-amd64/helm ./helm
	rm -rf ./linux-amd64/
	rm -f helm-$(HELM_VERSION)-linux-amd64.tar.gz*
	chmod +x helm

genesis-images.tar:
	for IMAGE in $(GENESIS_IMAGES); do \
		sudo docker pull $$IMAGE; \
	done
	sudo docker save -o genesis-images.tar $(GENESIS_IMAGES)

join-images.tar:
	for IMAGE in $(JOIN_IMAGES); do \
		sudo docker pull $$IMAGE; \
	done
	sudo docker save -o join-images.tar $(JOIN_IMAGES)

kubelet:
	wget http://storage.googleapis.com/kubernetes-release/release/$(KUBERNETES_VERSION)/bin/linux/amd64/kubelet
	chmod +x kubelet

clean:
	rm -rf \
		cni.tgz \
		env.sh \
		helm \
		helm-*-linux-amd64* \
		*.tar \
		kubelet \


.PHONY : build build-genesis build-join clean genesis join push push-genesis push-join
