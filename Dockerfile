FROM ubuntu:20.04

ARG RUNNER_VERSION=2.291.1
ARG TZ=Europe/London

ARG DOCKER_COMPOSE_VERSION=2.2.3
ARG DOCKER_SWITCH_VERSION=1.0.4

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    # create new user
    useradd -m -s /bin/bash -m runner && \
    # install runner
    apt-get -y update && \
    apt-get -y install curl make && \
    mkdir -p /home/runner/runner && cd /home/runner/runner && \
    curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    chown -R runner /home/runner && \
    rm /home/runner/runnner/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    ./bin/installdependencies.sh && \
    # install docker deps, composer v2, switcher
    apt-get -y install ca-certificates gnupg lsb-release kmod uidmap iptables iproute2 && \
    mkdir -p /home/runner/.docker/cli-plugins && \
    curl -SL https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -o /home/runner/.docker/cli-plugins/docker-compose && \
    chmod +x /home/runner/.docker/cli-plugins/docker-compose && \
    curl -SL https://github.com/docker/compose-switch/releases/download/v${DOCKER_SWITCH_VERSION}/docker-compose-linux-amd64 -o /usr/local/bin/compose-switch && \
    chmod +x /usr/local/bin/compose-switch && \
    chown -R runner /home/runner/.docker && \
    update-alternatives --install /usr/local/bin/docker-compose docker-compose /usr/local/bin/compose-switch 99

# not working yet
#ADD --chmod=0755 --chown=runner https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 /home/runner/.docker/cli-plugins/docker-compose
#ADD --chmod=0755 --chown=runner https://github.com/docker/compose-switch/releases/download/v1.0.4/docker-compose-linux-amd64 /usr/local/bin/compose-switch

USER runner
WORKDIR /home/runner

RUN curl -fsSL https://get.docker.com/rootless | sh && \
    mkdir -p /home/runner/.config/docker && \
    # Rootless support overlay2 only if running with kernel 5.11 or later, or Ubuntu-flavored kernel
    echo '{ "storage-driver": "vfs", "dns": ["1.1.1.1", "8.8.8.8"] }' > /home/runner/.config/docker/daemon.json && \
    echo 'export XDG_RUNTIME_DIR=/home/runner/.docker/run' >> /home/runner/.bashrc && \
    echo 'export PATH=/home/runner/bin:$PATH' >> /home/runner/.bashrc && \
    echo 'export DOCKER_HOST=unix:///home/runner/.docker/run/docker.sock' >> /home/runner/.bashrc

COPY --chmod=700 --chown=runner entrypoint.sh /entrypoint.sh

# We need different bin folders for docker and github runner due to autoupdates
WORKDIR /home/runner/runner
ENTRYPOINT /entrypoint.sh
