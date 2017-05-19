# Overview

Requirements:

- docker installed on the host

```
export NODE_HOSTNAME=10.12.34.56

docker run --rm \
  -v /:/target \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e NODE_HOSTNAME=$NODE_HOSTNAME \
  quay.io/attcomdev/promenade-genesis:dev
```
