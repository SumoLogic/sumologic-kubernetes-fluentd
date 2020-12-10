# sumologic-kubernetes-fluentd ![Dev builds](https://github.com/SumoLogic/sumologic-kubernetes-fluentd/workflows/Dev%20builds/badge.svg) [![GitHub tag](https://img.shields.io/github/tag/SumoLogic/sumologic-kubernetes-fluentd.svg)](https://gitHub.com/SumoLogic/sumologic-kubernetes-fluentd/tags/)


This repository contains fluentd-plugins which are bundled into a custom
[Fluentd](https://github.com/fluent/fluentd) image which is being used by
[sumologic-kubernetes-collection](https://github.com/SumoLogic/sumologic-kubernetes-collection).

Images from this repository are pushed to Sumo Logic public AWS ECR at `public.ecr.aws/u5z5f8z6/kubernetes-fluentd`.

Please take a look at `push` target in [Makefile](./Makefile) for more details.

## Build

```shell
make build
```

## Test

```shell
make test
```
