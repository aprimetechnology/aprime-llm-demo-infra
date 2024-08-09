#!/bin/bash
set -x
set -u

# docker build, with all output visible
docker build .

# docker build again (cached) to get image hash quietly
image_hash=$(docker build -q .)

docker run \
    --rm \
    -v ${HOME}/.aws:/root/.aws \
    -v .:/aprime-demo \
    -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
    -it  \
    ${image_hash} \
;

