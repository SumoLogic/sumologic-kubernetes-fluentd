# Contributing Guide

## Regenerating Gemfile

Run the following command in order to generate `Gemfile.lock` files for the specified plugin:

```bash
PLUGIN="fluent-plugin-datapoint
make "build-${PLUGIN}"
```

## Release

In order to release, please follow [the releasing guide](./docs/release.md)
