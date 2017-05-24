# Overview
The purpose of the Promenade project is to deploy a highly available and resilient self-hosted Kubernetes cluster in a containerized format. Promenade currently supports deployments using Docker containers leveraging the Bootkube binaries for initial cluster kick-start and node join process.   A local vagrant deployment is also supported.

## Local Vagrant Deployment
For testing in a local vagrant environment:

1) Build Make File

`make save`

2) Install Vagrant Plugins and run vagrant:
```
vagrant plugin install vagrant-hostmanager
vagrant up
```

3) Initialize the Bootkube containers on the Vagrant hosts:

`./test-install.sh`



## Manual Deployment:

**On the Genesis Host:**

1) Build the make file:

`make save`

2) Load Docker Container:

`docker load -i promenade-genesis.tar`

3) Run Docker Container:
```
export NODE_HOSTNAME=HOSTNAME
sudo docker run -v /:/target -v /var/run/docker.sock:/var/run/docker.sock -e NODE_HOSTNAME=$NODE_HOSTNAME quay.io/attcomdev/promenade-genesis:dev
```

**On Other Hosts:**

1) Build the make file:
`make save`

2) Load Docker Container:
`docker load -i promenade-join.tar`

3) Run Docker Container:
```
export NODE_HOSTNAME=HOSTNAME
sudo docker run -v /:/target -v /var/run/docker.sock:/var/run/docker.sock -e NODE_HOSTNAME=$NODE_HOSTNAME quay.io/attcomdev/promenade-join:dev
```
