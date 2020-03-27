CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)
HOST_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "6443/tcp") 0).HostPort}}' kind-control-plane)

sed -i "s/127.0.0.1/$CONTAINER_IP/g" ~/.kube/config && sed -i "s/$HOST_PORT/6443/g" ~/.kube/config
