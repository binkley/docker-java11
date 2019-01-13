#!/bin/bash

set -e
set -o pipefail
set -u

run=''
case $(uname) in
    CYGWIN* | MINGW* ) run=winpty ;;
esac

$run docker rm tmp 2>/dev/null || true
$run docker build --tag tmp .
$run docker run --name tmp --publish 8080:8080/tcp -it tmp
