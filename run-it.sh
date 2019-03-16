#!/bin/bash

set -e
set -o pipefail
set -u

run=''
case $(uname) in
    CYGWIN* | MINGW* ) run=winpty ;;
esac

$run docker rm tmp || true
$run docker build --tag tmp . \
    --build-arg GRADLE_VERSION=5.2.1 \
    --build-arg JAVA_VERSION=11.0.2
$run docker run --name tmp --publish 8080:8080/tcp -it tmp
