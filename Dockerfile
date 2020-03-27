FROM golang:1.12

ENV GO111MODULE=on

RUN apt-get update && \
    apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg2 \
            software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
                       "deb [arch=amd64] https://download.docker.com/linux/debian \
                       $(lsb_release -cs) \
                       stable" && \
    apt-get update && \
    apt-get install -y \
            docker-ce \
            docker-ce-cli \
            containerd.io

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/update-kube-config.sh

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.22.2

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install kind
RUN go get sigs.k8s.io/kind@v0.7.0

COPY update-kube-config.sh /usr/local/bin/
COPY kind-config.yaml /tmp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh"]