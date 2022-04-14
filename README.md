# github-actions-runner-dind-rootless

Github Actions runner in docker container with rootless docker. Please do not use it in production.

## Usage
Go to docker-compose file and type your repo, key and runner name:
```docker-compose.yml
      - RUNNER_URL=https://github.com/user/repo
      - RUNNER_TOKEN=%TOKEN%
      - RUNNER_NAME=runner-name-1
```
After you can build and start it:
```
DOCKER_BUILDKIT=1 docker-compose build --no-cache
DOCKER_BUILDKIT=1 docker-compose up -d
```

## Alternatives
More dipper and hard work you can see in this repo: [msyea](https://github.com/msyea/github-actions-runner-rootless)
