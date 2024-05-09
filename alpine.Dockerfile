# Use the same alpine and ruby version as in the target image below.
FROM ruby:3.2.0-alpine3.17 AS builder

RUN apk update \
 && apk add \
        build-base \
        git \
        gnupg \
        linux-headers \
        ruby-dev \
        snappy-dev

RUN echo 'gem: --no-document' >> /etc/gemrc

# Fluentd plugin dependencies
# Copied from https://github.com/fluent/fluentd-docker-image/blob/6a497560b45add04b9033955ae2e97c2616aa356/v1.16/alpine/Dockerfile
RUN gem install \
        async:1.30.3 \
        async-http:0.60.2 \
        bigdecimal:1.4.4 \
        concurrent-ruby:1.1.10 \
        fluentd:1.16.2 \
        google-protobuf:3.21.12 \
        json:2.6.3 \
        lru_redux:1.1.0 \
        net-http-persistent:4.0.2 \
        oj:3.15.0 \
        snappy:0.3.0 \
        specific_install:0.3.8

# Use unreleased Kubeclient version with persistent HTTP connections.
RUN gem specific_install https://github.com/ManageIQ/kubeclient --ref 220b8d7af52180f9a0f69cb73f0723d2618cf3ef

# FluentD plugins to allow customers to forward data if needed to various cloud providers
RUN gem install \
        fluent-plugin-s3
        # TODO: Support additional cloud providers
        # && gem install fluent-plugin-google-cloud \
        # && gem install fluent-plugin-azure-storage-append-blob

# Install Fluentd plugins
RUN gem install \
	# https://github.com/fluent-plugins-nursery/fluent-plugin-concat
        fluent-plugin-concat:2.5.0 \
        # https://github.com/fluent/fluent-plugin-prometheus
        fluent-plugin-prometheus:2.1.0 \
        # https://github.com/repeatedly/fluent-plugin-record-modifier
        fluent-plugin-record-modifier:2.1.1 \
        # https://github.com/fluent/fluent-plugin-rewrite-tag-filter
        fluent-plugin-rewrite-tag-filter:2.4.0 \
        # https://github.com/SumoLogic/fluentd-output-sumologic/
        fluent-plugin-sumologic_output:1.8.0 \
        # https://github.com/fluent-plugin-systemd/fluent-plugin-systemd
        fluent-plugin-systemd:1.0.5

WORKDIR /sumologic-kubernetes-fluentd

COPY fluent-plugin-datapoint/ ./fluent-plugin-datapoint
RUN cd fluent-plugin-datapoint \
 && gem build fluent-plugin-datapoint.gemspec -o ../fluent-plugin-datapoint.gem \
 && cd ..

COPY fluent-plugin-enhance-k8s-metadata/ ./fluent-plugin-enhance-k8s-metadata
RUN cd fluent-plugin-enhance-k8s-metadata \
 && gem build fluent-plugin-enhance-k8s-metadata.gemspec -o ../fluent-plugin-enhance-k8s-metadata.gem \
 && cd ..

COPY fluent-plugin-events/ ./fluent-plugin-events
RUN cd fluent-plugin-events \
 && gem build fluent-plugin-events.gemspec -o ../fluent-plugin-events.gem \
 && cd ..

COPY fluent-plugin-kubernetes-metadata-filter ./fluent-plugin-kubernetes-metadata-filter
RUN cd fluent-plugin-kubernetes-metadata-filter \
 && gem build fluent-plugin-kubernetes-metadata-filter.gemspec -o ../fluent-plugin-kubernetes-metadata-filter.gem \
 && cd ..

COPY fluent-plugin-kubernetes-sumologic/ ./fluent-plugin-kubernetes-sumologic
RUN cd fluent-plugin-kubernetes-sumologic \
 && gem build fluent-plugin-kubernetes-sumologic.gemspec -o ../fluent-plugin-kubernetes-sumologic.gem \
 && cd ..

COPY fluent-plugin-prometheus-format ./fluent-plugin-prometheus-format
RUN cd fluent-plugin-prometheus-format \
 && gem build fluent-plugin-prometheus-format.gemspec -o ../fluent-plugin-prometheus-format.gem \
 && cd ..

COPY fluent-plugin-protobuf/ ./fluent-plugin-protobuf
RUN cd fluent-plugin-protobuf \
 && gem build fluent-plugin-protobuf.gemspec -o ../fluent-plugin-protobuf.gem \
 && cd ..

RUN gem install \
        --local fluent-plugin-datapoint \
        --local fluent-plugin-enhance-k8s-metadata \
        --local fluent-plugin-events \
        --local fluent-plugin-kubernetes-metadata-filter \
        --local fluent-plugin-kubernetes-sumologic \
        --local fluent-plugin-prometheus-format \
        --local fluent-plugin-protobuf

# Use ruby as base image because the official Fluentd alpine image is not built for linux/arm/v7 or linux/arm64/v8.
# Use the same alpine and ruby version as the base image to prevent issues.
# https://github.com/fluent/fluentd-docker-image/blob/6a497560b45add04b9033955ae2e97c2616aa356/v1.16/alpine/Dockerfile
# https://pkgs.alpinelinux.org/packages?name=ruby&branch=v3.17
FROM ruby:3.2.0-alpine3.17

# 1. Update system packages.
# 2. Install required system packages.
# 3. Delete vulnerable versions of Ruby gems to silence security scanners.
RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        snappy-dev \
        tini

RUN delgroup ping \
    && addgroup -S -g 999 fluent \
    && adduser -S -g fluent -u 999 fluent \
    # for log storage (maybe shared with host)
    && mkdir -p /fluentd/log \
    # configuration/plugins path (default: copied from .)
    && mkdir -p /fluentd/etc /fluentd/plugins \
    && chown -R fluent /fluentd && chgrp -R fluent /fluentd

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 5140

COPY --from=builder --chown=fluent:fluent /usr/local/bundle /usr/local/bundle

USER 999:999

ARG BUILD_TAG=latest
ENV TAG $BUILD_TAG

ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
