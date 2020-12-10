# sumologic-kubernetes-fluentd ![Dev builds](https://github.com/SumoLogic/sumologic-kubernetes-fluentd/workflows/Dev%20builds/badge.svg)

This repository contains fluentd-plugins which are bundled into a custom
[Fluentd](https://github.com/fluent/fluentd) image which is being used by
[sumologic-kubernetes-collection](https://github.com/SumoLogic/sumologic-kubernetes-collection).

On each push to `main` branch, a new image tagged `latest` is pushed to Sumo Logic public Docker repository at `public.ecr.aws/u5z5f8z6/kubernetes-fluentd`. See [.github/workflows/dev_builds.yml](.github/workflows/dev_builds.yml) file and `push` target in [Makefile](./Makefile).

When a version tag is added (e.g. `v1.2.3` or similar), a new image tagged `v1.2.3` is pushed to the same repository. See [.github/workflows/release_builds.yml](.github/workflows/release_builds.yml) file.

## Build

```shell
make build
```

## Test

```shell
make test
```
