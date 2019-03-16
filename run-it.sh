#!/bin/bash

set -e
set -o pipefail
set -u

run=''
case $(uname) in
    CYGWIN* | MINGW* ) run=winpty ;;
esac

$run docker rm tmp || true
$run docker build --compress --tag tmp . \
    --build-arg APP_JAR=build/libs/docker-java11-0-SNAPSHOT.jar \
    --build-arg GRADLE_VERSION=5.2.1 \
    --build-arg JAVA_VERSION=11.0.2
$run docker run --name tmp --publish 8080:8080/tcp -it tmp
