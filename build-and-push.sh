#!/bin/bash
GITHUBUSER=${GITHUBUSER:-nalind}
IMAGE=${IMAGE:-ghcr.io/${GITHUBUSER}/fedora-qemu-user-static}
SOURCE=${SOURCE:-https://github.com/${GITHUBUSER}/fedora-qemu-user-static}
buildah rmi -f ${IMAGE} || true
buildah bud --build-arg IMAGE="${IMAGE}" --build-arg SOURCE="${SOURCE}" --all-platforms --manifest ${IMAGE} .
buildah manifest push --all "${IMAGE}" docker://"${IMAGE}":$(TZ=UTC date +%Y-%m-%d)
buildah manifest push --all "${IMAGE}" docker://"${IMAGE}"
