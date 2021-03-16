# fluent-plugin-kubernetes-sumologic

[Fluentd](https://fluentd.org/) filter plugin to enrich logs with Sumo Logic specific metadata.

Decorates records with a `_sumo_metadata` property with Sumo Logic specifc metadata
like `_sourceCategory`, `_sourceHost`, `_sourceName` and others.

## Exclusion and inclusion rules

The plugin drops records that match the regex exclusion rules - see `exclude_*` configuration settings below.

Records from pods annotated with `sumologic.com/include` annotation set to `true` are still included
despite the regex exclusion rules.

Records from pods annotated with `sumologic.com/exclude` annotation set to `true` are dropped.

## Pod annotations

The following [Kubernetes annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
can be used on pods:

- `sumologic.com/exclude` - records from this pod are dropped
- `sumologic.com/include` - overrides `exclude_*` plugin settings, records from this pod are not checked against these regexes
- `sumologic.com/sourceCategory` - overrides `source_category` plugin setting
- `sumologic.com/sourceCategoryPrefix` - overrides `source_category_prefix` plugin setting
- `sumologic.com/sourceCategoryReplaceDash` - overrides `source_category_replace_dash` plugin setting

## Configuration

| Parameter Name               | Type   | Default                            | Scope        | Description                                                                                                                                                                                                      |
| ---------------------------- | ------ | ---------------------------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| collector_key_name           | string | "_collector"                       | Traces       | Defines the key of the "collector" tag in trace metadata.                                                                                                                                                        |
| collector_value              | string | "undefined"                        | Traces       | Defines the value of the "collector" tag in trace metadata.                                                                                                                                                      |
| exclude_container_regex      | string | ""                                 | Logs         | Exclude logs from containers matching this regex.                                                                                                                                                                |
| exclude_facility_regex       | string | ""                                 | systemd logs | Exclude systemd logs whose `SYSLOG_FACILITY` value matches this regex.                                                                                                                                           |
| exclude_host_regex           | string | ""                                 | systemd logs | Exclude systemd logs whose `_HOSTNAME` value matches this regex.                                                                                                                                                 |
| exclude_namespace_regex      | string | ""                                 | Logs         | Exclude logs from namespaces matching this regex.                                                                                                                                                                |
| exclude_pod_regex            | string | ""                                 | Logs         | Exclude logs from pods matching this regex.                                                                                                                                                                      |
| exclude_priority_regex       | string | ""                                 | systemd logs | Exclude systemd logs whose `PRIORITY` value matches this regex.                                                                                                                                                  |
| exclude_unit_regex           | string | ""                                 | systemd logs | Exclude systemd logs whose `_SYSTEMD_UNIT` value matches this regex.                                                                                                                                             |
| log_format                   | string | "json"                             |              | Defines the `log_format` value in `_sumo_metadata`.                                                                                                                                                              |
| source_category              | string | "%{namespace}/%{pod_name}"         | Logs         | Defines the source category value in `_sumo_metadata`. Can be overridden with pod's `sumologic.com/sourceCategory` annotation.                                                                                   |
| source_category_key_name     | string | "_sourceCategory"                  | Logs         | Defines the source category key in `_sumo_metadata`.                                                                                                                                                             |
| source_category_prefix       | string | "kubernetes/"                      | Logs         | Defines the prefix prepended to source category value. Can be overridden with pod's `sumologic.com/sourceCategoryPrefix` annotation.                                                                             |
| source_category_replace_dash | string | "/"                                | Logs         | Defines the character that all `-` dashes in source category will be replaced with. Set it to `-` to prevent the replacement. Can be overridden with pod's `sumologic.com/sourceCategoryReplaceDash` annotation. |
| source_host                  | string | ""                                 | Logs         | Defines the source host value in `_sumo_metadata`.                                                                                                                                                               |
| source_host_key_name         | string | "_sourceHost"                      | Logs         | Defines the source host key in `_sumo_metadata`.                                                                                                                                                                 |
| source_name                  | string | "%{namespace}.%{pod}.%{container}" | Logs         | Defines the source name value in `_sumo_metadata`.                                                                                                                                                               |
| source_name_key_name         | string | "_sourceName"                      | Logs         | Defines the source name key in `_sumo_metadata`.                                                                                                                                                                 |
| tracing_annotation_prefix    | string | "pod_annotation_"                  | Traces       |                                                                                                                                                                                                                  |
| tracing_container_name       | string | "container_name"                   | Traces       |                                                                                                                                                                                                                  |
| tracing_format               | bool   | false                              | Traces       |                                                                                                                                                                                                                  |
| tracing_host                 | string | "hostname"                         | Traces       |                                                                                                                                                                                                                  |
| tracing_label_prefix         | string | "pod_label_"                       | Traces       |                                                                                                                                                                                                                  |
| tracing_namespace            | string | "namespace"                        | Traces       |                                                                                                                                                                                                                  |
| tracing_pod                  | string | "pod"                              | Traces       |                                                                                                                                                                                                                  |
| tracing_pod_id               | string | "pod_id"                           | Traces       |                                                                                                                                                                                                                  |
