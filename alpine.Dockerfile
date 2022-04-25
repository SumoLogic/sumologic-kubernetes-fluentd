FROM ruby:2.7.6-alpine3.14 AS builder

RUN apk update \
 && apk add \
        build-base \
        git \
        gnupg \
        linux-headers \
        ruby-dev \
        snappy-dev

RUN echo 'gem: --no-document' >> /etc/gemrc

# Update Ruby gems to prevent vulnerabilities
RUN gem install \
        bundler:2.3.4 \
        cgi:0.3.1 \
        rdoc:6.4.0 \
        rexml:3.2.5

# Fluentd plugin dependencies
RUN gem install \
        async-http:0.54.0 \
        bigdecimal:1.4.4 \
        concurrent-ruby:1.1.8 \
        ext_monitor:0.1.2 \
        fluentd:1.14.6 \
        google-protobuf:3.19.2 \
        json:2.4.1 \
        lru_redux:1.1.0 \
        net-http-persistent:4.0.1 \
        oj:3.10.18 \
        snappy:0.0.17 \
        specific_install:0.3.5

# Use unreleased Kubeclient version with persistent HTTP connections.
RUN gem specific_install https://github.com/abonas/kubeclient --ref 3267dc3fd02c49e3b19f1210ff7cb84c3b2a4478

# FluentD plugins to allow customers to forward data if needed to various cloud providers
RUN gem install \
        fluent-plugin-s3
        # TODO: Support additional cloud providers
        # && gem install fluent-plugin-google-cloud \
        # && gem install fluent-plugin-azure-storage-append-blob

# FluentD plugins from RubyGems
RUN gem install \
        fluent-plugin-concat:2.4.0 \
        fluent-plugin-prometheus:1.6.1 \
        fluent-plugin-record-modifier:2.0.1 \
        fluent-plugin-rewrite-tag-filter:2.2.0 \
        fluent-plugin-sumologic_output:1.8.0 \
        fluent-plugin-systemd:1.0.2

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

FROM ruby:2.7.6-alpine3.14

# 1. Update system packages.
# 2. Install required system packages.
# 3. Delete vulnerable versions of Ruby gems to silence security scanners.
RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        snappy-dev \
        tini \
 && rm -rf /usr/local/lib/ruby/2.7.0/bundler/ \
 && rm /usr/local/lib/ruby/2.7.0/bundler.rb \
 && rm /usr/local/lib/ruby/gems/2.7.0/specifications/default/bundler-*.gemspec \
 && rm -rf /usr/local/lib/ruby/2.7.0/cgi/ \
 && rm /usr/local/lib/ruby/2.7.0/cgi.rb \
 && rm /usr/local/lib/ruby/gems/2.7.0/specifications/default/cgi-*.gemspec \
 && rm -rf /usr/local/lib/ruby/2.7.0/rdoc/ \
 && rm /usr/local/lib/ruby/2.7.0/rdoc.rb \
 && rm /usr/local/lib/ruby/gems/2.7.0/specifications/default/rdoc-*.gemspec \
 && rm -rf /usr/local/lib/ruby/2.7.0/rexml/ \
 && rm /usr/local/lib/ruby/gems/2.7.0/specifications/default/rexml-*.gemspec

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
