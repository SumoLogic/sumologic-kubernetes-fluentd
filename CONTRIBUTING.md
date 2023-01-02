# Contributing Guide

## Testing your changes

After making the necessary changes, run the following commands to test that your changes work correctly.

```sh
make test
make build
make image-test
make build-alpine
make image-test-alpine
```

## Regenerating Gemfile

Run the following command in order to generate `Gemfile.lock` files for the specific plugin:

```bash
PLUGIN="fluent-plugin-datapoint
make "build-${PLUGIN}"
```

## Release

In order to release, please follow [the releasing guide](./docs/release.md)
