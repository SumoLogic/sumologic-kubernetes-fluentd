# sumologic-kubernetes-fluentd ![Dev builds](https://github.com/SumoLogic/sumologic-kubernetes-fluentd/workflows/Dev%20builds/badge.svg) [![GitHub tag](https://img.shields.io/github/tag/SumoLogic/sumologic-kubernetes-fluentd.svg)](https://gitHub.com/SumoLogic/sumologic-kubernetes-fluentd/tags/)

This repository contains Fluentd plugins which are bundled into a custom
[Fluentd](https://github.com/fluent/fluentd) image.
This image is then used by [sumologic-kubernetes-collection](https://github.com/SumoLogic/sumologic-kubernetes-collection).

Images from this repository are pushed to Sumo Logic public AWS ECR at [public.ecr.aws/sumologic/kubernetes-fluentd](https://gallery.ecr.aws/sumologic/kubernetes-fluentd).

The images are built for the following architectures:

- `linux/amd64`
- `linux/arm/v7`
- `linux/arm64/v8`

## Build

To build image only for the build host's architecture:

```shell
make build
```

To build image for all supported architectures and push it to a registry:

```shell
make build-push-multiplatform REPO_URL=my-repo/fluentd BUILD_TAG=custom-tag
```

## Test

```shell
make test
```
