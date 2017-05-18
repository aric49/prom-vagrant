#!/usr/bin/env bash
set -ex

export CNI_VERSION=v0.5.2
export HELM_VERSION=v2.3.1
export BOOTKUBE_VERSION=v0.4.1
export KUBERNETES_VERSION=v1.6.2

sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y \
        docker.io

wget https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-amd64-$CNI_VERSION.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -xf cni-amd64-$CNI_VERSION.tgz -C /opt/cni/bin/

wget http://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubelet
sudo mv kubelet /usr/local/bin/kubelet
chmod +x /usr/local/bin/kubelet

# Useful for testing
# wget http://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl
# sudo chmod +x kubectl
# sudo mv kubectl /usr/local/bin/

PRE_PULL_IMAGES=(
    gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64@sha256:89c9a1d3cfbf370a9c1a949f39f92c1dc2dbe8c3e6cc1802b7f2b48e4dfe9a9e
    gcr.io/google_containers/k8s-dns-kube-dns-amd64@sha256:33914315e600dfb756e550828307dfa2b21fb6db24fe3fe495e33d1022f9245d
    gcr.io/google_containers/k8s-dns-sidecar-amd64@sha256:d33a91a5d65c223f410891001cd379ac734d036429e033865d700a4176e944b0
    gcr.io/google_containers/pause-amd64:3.0
    quay.io/calico/cni@sha256:42e3d2a7484357a12538638c169336dfd991579008817335af6ee5ca80414a78
    quay.io/calico/kube-policy-controller@sha256:6ccc8caa6bf8ba94f5191532f5e279a307160cc9eb863e90b0200403bf8024d6
    quay.io/calico/node@sha256:8e62eee18612a6ac7bcae90afaba0ed95265baba7bf3c0ab632b7b40ddfaf603
    quay.io/coreos/etcd-operator@sha256:b25592bced6c3e59eef02ac4ef27100ad0b986546090e372b08810fd4ef15bea
    quay.io/coreos/etcd@sha256:23e46a0b54848190e6a15db6f5b855d9b5ebcd6abd385c80aeba4870121356ec
    quay.io/coreos/etcd@sha256:f5fa361910c0067f0d9323f34a38b1d026e1a44bcbdd616bf8f69d933b86b1db
    quay.io/coreos/flannel@sha256:dfa3a1c4c430329c26100c2ce7e460e81cba9899745b6b14f7535c67c07fb27f
    quay.io/coreos/hyperkube@sha256:77b81b118e6e231d284e6ae0ec50d898dadd88af469df33d5cf3f3a2d0d44473
    quay.io/coreos/kenc@sha256:fd024309d0d1ad062bd6efabd9d69c50363d9fd245e4454f346d20b5ca1cf893
    quay.io/coreos/pod-checkpointer@sha256:1dfed8e046bedc50e346a61b1c62951a0761f61803fc674ddeb3841aa363fbf6
    quay.io/coreos/bootkube:$BOOTKUBE_VERSION
)
for IMAGE in "${PRE_PULL_IMAGES[@]}"; do
    sudo docker pull $IMAGE
done

# NOTE: This might not be a good enough way to get the IP.
IP=$(hostname --all-ip-addresses | cut -f 2 -d ' ')

# XXX Don't forget hosts file with kubernetes : $IP
sudo /usr/bin/docker run --rm \
    -v /etc:/target \
    quay.io/coreos/bootkube:$BOOTKUBE_VERSION \
    /bootkube render \
        --asset-dir=/target/kubernetes \
        --experimental-self-hosted-etcd \
        --etcd-servers=http://10.3.0.15:12379 \
        --api-servers=https://$IP:443
sudo rm -rf /etc/kubernetes/manifests/kube-flannel*
sudo ln -s /etc/kubernetes/{auth/,}kubeconfig

sudo cp assets/calico-config.yaml /etc/kubernetes/manifests/kube-flannel-cfg.yaml
sudo cat assets/canal-*.yaml | sudo tee /etc/kubernetes/manifests/kube-flannel.yaml > /dev/null


cat assets/kubelet.service | envsubst > /tmp/templated
sudo mv /tmp/templated /etc/systemd/system/kubelet.service
sudo chown root:root /etc/systemd/system/kubelet.service
sudo chmod 755 /etc/systemd/system/kubelet.service

sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet

sudo /usr/bin/docker run --rm \
    -v /etc/kubernetes:/etc/kubernetes \
    quay.io/coreos/bootkube:$BOOTKUBE_VERSION \
    /bootkube start \
        --asset-dir=/etc/kubernetes
