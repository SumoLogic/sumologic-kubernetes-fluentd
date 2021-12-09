# fluent-plugin-enhance-k8s-metadata

[Fluentd](https://fluentd.org/) output plugin to add extra Kubernetes metadata to the events.

- Sample of Input

```json
TBD
```

- Sample of Output

```json
TBD
```

## Installation

### RubyGems

```sh
gem install fluent-plugin-enhance-k8s-metadata
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-enhance-k8s-metadata"
```

And then execute:

```sh
bundle
```

## Configuration

TBD

- `add_owners` - set it to `false` to disable decorating records with pod owner metadata
  like `daemonset`, `deployment`, `replicaset`, `statefulset` (default: `true`)
- `add_service` - set it to `false` to disable decorating records with the `service` metadata (default: `true`)
- `keepalive` - defines whether HTTP connections to Kubernetes API server should be persistent (default: `true`)
