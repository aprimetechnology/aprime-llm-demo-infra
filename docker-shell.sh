#!/bin/bash
set -u
set -x

# docker build, with all output visible
docker build .

# docker build again (cached) to get image hash quietly
image_hash=$(docker build -q .)

docker run \
    --rm \
    -v ${HOME}/.aws:/root/.aws \
    -v .:/demo \
    -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?Please set a value for the AWS_ACCESS_KEY_ID environment variable}" \
    -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?Please set a value for the AWS_SECRET_ACCESS_KEY environment variable}" \
    -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN:?Please set a value for the AWS_SESSION_TOKEN environment variable}" \
    -w /demo \
    -it  \
    ${image_hash} \
;
