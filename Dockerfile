ARG FLUENTD_ARCH
# Use the same ruby and debian version as is used in the target Fluentd image below.
FROM ruby:3.2-slim-bookworm AS builder

# Dependencies
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
        curl \
        g++ \
        gcc \
        libc-dev \
        libsnappy-dev \
        make \
        ruby-dev \
        sudo \
        unzip \
        git

# Fluentd plugin dependencies
RUN gem install \
        async:1.31.0 \
        async-http:0.60.2 \
        bigdecimal:1.4.4 \
        concurrent-ruby:1.1.10 \
        fluentd:1.16.5 \
        google-protobuf:3.21.12 \
        json:2.6.3 \
        lru_redux:1.1.0 \
        net-http-persistent:4.0.2 \
        oj:3.16.1 \
        rexml:3.2.6 \
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

RUN rm -rf /usr/local/bundle/cache/* \
 && find /usr/local/bundle/ -name "*.o" | xargs rm

FROM fluent/fluentd:v1.16.5-debian${FLUENTD_ARCH}-1.0

USER root

# 1. Update system packages.
# 2. Install required system packages.
# 3. Update vulnerable gem, cgi
# 4. Clean up after system package installation.
# 5. Delete vulnerable versions of Ruby gems to silence security scanners.
RUN apt-get update \
 && apt-get upgrade --yes \
 && apt-get install --yes --no-install-recommends \
        libsnappy-dev \
        curl \
        jq \
 && gem update cgi \
 && gem cleanup \
 && rm -rf /var/lib/apt/lists/ \
 && rm -rf /var/lib/dpkg/info/

COPY --from=builder --chown=fluent:fluent /usr/local/bundle /usr/local/bundle
COPY ./entrypoint.sh /bin/

USER 999:999

ARG BUILD_TAG=latest
ENV TAG $BUILD_TAG
