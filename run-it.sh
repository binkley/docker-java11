#!/bin/bash

set -e

docker rm tmp 2>/dev/null || true
docker build --tag tmp .
docker run --name tmp --publish 8080:8080/tcp -it tmp
