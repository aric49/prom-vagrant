#Joins Node to the newly established Kubernetes bootkube cluster.
#!/usr/bin/env bash
set -ex

#Require the IP address of the genesis node be passed in $1
if [ -z "$VAR" ]; then
  echo "Error - Need to pass in Genesis host IP"
  exit 1
fi

GenesisIP=$1

#Install same packages as the Genesis node
#NOTE: This will change with containerized deployment

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

#Copy over KubeConfig - Manual for now, clean up later.
mkdir -p /etc/kubernetes
cp assets/kubeconfig /etc/kubernetes
#scp ubuntu@$GenesisHost:/etc/kubernetes/kubeconfig /etc/kubernetes/kubeconfig

#Setup the Kubelet Service
# NOTE: This might not be a good enough way to get the IP.
IP=$(hostname -i)

cat assets/kubelet.service | envsubst > /tmp/templated
sudo mv /tmp/templated /etc/systemd/system/kubelet.service
sudo chown root:root /etc/systemd/system/kubelet.service
sudo chmod 755 /etc/systemd/system/kubelet.service

cat assets/kubeconfig | envsubst > /tmp/templated_kubeconfig
sudo mv /tmp/templated_kubeconfig /etc/kubernetes/kubeconfig
sudo chown root:root /etc/kubernetes/kubeconfig

sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
