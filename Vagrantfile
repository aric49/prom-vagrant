# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install a kube cluster using kubeadm:
# http://kubernetes.io/docs/getting-started-guides/kubeadm/

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = false

  config.vm.provision :file, source: "dnsmasq-kubernetes", destination: "/tmp/dnsmasq-kubernetes"

  config.vm.provision :shell, privileged: true, inline:<<EOS
echo === Installing packages ===
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  docker.io \
  dnsmasq \
  gettext-base \

echo === Setting up DNSMasq ===
mv /tmp/dnsmasq-kubernetes /etc/dnsmasq.d/
chown root:root /etc/dnsmasq.d/dnsmasq-kubernetes
chmod 644 /etc/dnsmasq.d/dnsmasq-kubernetes
systemctl restart dnsmasq

echo === Done ===
EOS

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = "2048"
  end

  config.vm.define "n0" do |c|
      c.vm.hostname = "n0"
      c.vm.network "private_network", ip: "192.168.77.10"
  end

  config.vm.define "n1" do |c|
      c.vm.hostname = "n1"
      c.vm.network "private_network", ip: "192.168.77.11"
  end

  config.vm.define "n2" do |c|
      c.vm.hostname = "n2"
      c.vm.network "private_network", ip: "192.168.77.12"
  end

end
