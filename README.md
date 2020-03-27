# golang-dind-kind

Docker image for running KIND in Docker container

1. Run the Docker image `docker run -it --privileged -v /var/run/docker.sock:/var/run/docker.sock dustinvanbuskirk/golang-dind-kind /bin/bash`

1. Modify the kubeconfig `update-kube-config.sh`

1. Access Kubernetes `kubectl cluster-info --context kind-kind`