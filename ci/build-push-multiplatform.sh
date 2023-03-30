#!/bin/bash

set -exuo pipefail

if ! docker buildx ls | grep arm
then
    echo "Your Buildx seems to lack ARM architecture support"
    exit 1
fi

docker buildx build \
    --push \
    --platform=linux/amd64 \
    --build-arg FLUENTD_ARCH="" \
    --build-arg BUILD_TAG="${BUILD_TAG}" \
    --tag "${REPO_URL}:${BUILD_TAG}-amd64" \
    . &
readonly amd64_pid=$!

docker buildx build \
    --push \
    --platform=linux/arm/v7 \
    --build-arg FLUENTD_ARCH="-armhf" \
    --build-arg BUILD_TAG="${BUILD_TAG}" \
    --tag "${REPO_URL}:${BUILD_TAG}-arm" \
    . &
readonly arm_pid=$!

docker buildx build \
    --push \
    --platform=linux/arm64/v8 \
    --build-arg FLUENTD_ARCH="" \
    --build-arg BUILD_TAG="${BUILD_TAG}" \
    --tag "${REPO_URL}:${BUILD_TAG}-arm64" \
    . &
readonly arm64_pid=$!

wait $amd64_pid
wait $arm_pid
wait $arm64_pid

docker buildx imagetools create --tag \
    "${REPO_URL}:${BUILD_TAG}" \
    "${REPO_URL}:${BUILD_TAG}-amd64"

docker buildx imagetools create --tag \
    "${REPO_URL}:${BUILD_TAG}" \
    "${REPO_URL}:${BUILD_TAG}-arm"

docker buildx imagetools create --tag \
    "${REPO_URL}:${BUILD_TAG}" \
    "${REPO_URL}:${BUILD_TAG}-arm64"
