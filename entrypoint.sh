#!/bin/bash

export XDG_RUNTIME_DIR=/home/runner/.docker/run
export PATH=/home/runner/bin:$PATH
export DOCKER_HOST=unix:///home/runner/.docker/run/docker.sock

dockerd-rootless.sh >/dev/null 2>&1 &

if [[ -n ${RUNNER_LABELS} ]]; then
    GH_RUNNER_LABELS="--labels ${RUNNER_LABELS}"
fi

if ! [[ -f ".credentials" ]]; then
    ./config.sh --url ${RUNNER_URL} --token ${RUNNER_TOKEN} --name ${RUNNER_NAME} --unattended ${RUNNER_LABELS}
fi

./run.sh